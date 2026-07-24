import locale
import os
import subprocess
import sys
import threading
import time
import traceback
from datetime import datetime
import signal
import ctypes

# Явный импорт библиотек для корректной упаковки PyInstaller
import schedule
import psutil
import mariadb
import logging.handlers

# --- Проверка аргументов ---
def is_debug_mode():
    return '-debug' in sys.argv or '--debug' in sys.argv

# --- Показ/скрытие консоли (только Windows) ---
def toggle_console(show=False):
    if sys.platform.startswith('win'):
        console_handle = ctypes.windll.kernel32.GetConsoleWindow()
        if console_handle != 0:
            if show:
                ctypes.windll.user32.ShowWindow(console_handle, 1)  # SW_SHOWNORMAL
            else:
                ctypes.windll.user32.ShowWindow(console_handle, 0)  # SW_HIDE

# --- Убийство предыдущего экземпляра ---
def kill_existing_process():
    current_pid = os.getpid()
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            info = proc.info
            cmdline = info.get('cmdline') or []

            if '--run-child' in cmdline:
                continue

            name_lower = info['name'].lower() if info['name'] else ''
            is_our_process = 'impuls.exe' in name_lower or (
                        'python' in name_lower and any('launcher.py' in arg for arg in cmdline))

            if is_our_process and info['pid'] != current_pid:
                print(f"[{datetime.now()}] [LAUNCHER] Завершаем предыдущий экземпляр (PID: {info['pid']})...")
                proc.terminate()
                try:
                    proc.wait(timeout=5)
                except psutil.TimeoutExpired:
                    proc.kill()
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass


def get_python_exe(launcher_dir):
    if getattr(sys, 'frozen', False):
        return sys.executable

    if sys.prefix != sys.base_prefix:
        return sys.executable

    for venv_name in ['venv', '.venv', 'env']:
        win_path = os.path.join(launcher_dir, venv_name, 'Scripts', 'python.exe')
        nix_path = os.path.join(launcher_dir, venv_name, 'bin', 'python')
        if os.path.exists(win_path):
            return win_path
        if os.path.exists(nix_path):
            return nix_path

    return sys.executable


class ScriptMonitor:
    def __init__(self, script_path, launcher_dir, ping_timeout=60, check_interval=10):
        self.script_path = script_path
        self.launcher_dir = launcher_dir
        self.ping_timeout = ping_timeout
        self.check_interval = check_interval
        self.process = None
        self.last_ping = datetime.now()
        self.stop_event = threading.Event()
        self.ping_lock = threading.Lock()
        self.stop_flag = os.path.join(self.launcher_dir, "STOP.txt")
        self.encoding = self.detect_system_encoding()
        self.logs_dir = os.path.join(self.launcher_dir, "logs")
        os.makedirs(self.logs_dir, exist_ok=True)
        self.log_file = os.path.join(self.logs_dir, "app.log")

        self.venv_python = get_python_exe(self.launcher_dir)

        signal.signal(signal.SIGTERM, self._signal_handler)
        signal.signal(signal.SIGINT, self._signal_handler)

        self.log_startup_info()

    def log_startup_info(self):
        if is_debug_mode():
            info = (
                f"\n{'=' * 40}\n"
                f"=== ЗАПУСК LAUNCHER (DEBUG) ===\n"
                f"Launcher Version: v3.0\n"
                f"Time: {datetime.now()}\n"
                f"Python: {sys.version.split()[0]}\n"
                f"Executable: {sys.executable}\n"
                f"Frozen: {getattr(sys, 'frozen', False)}\n"
                f"Launcher Dir: {self.launcher_dir}\n"
                f"Working Dir: {os.getcwd()}\n"
                f"Main Path: {self.script_path}\n"
                f"PID: {os.getpid()}\n"
                f"Platform: {sys.platform}\n"
                f"Encoding: {self.encoding}\n"
                f"VENV Python: {self.venv_python}\n"
                f"Command line: {' '.join(sys.argv)}\n"
                f"{'=' * 40}"
            )
        else:
            info = (
                f"\n{'=' * 40}\n"
                f"=== ЗАПУСК LAUNCHER ===\n"
                f"Time: {datetime.now()}\n"
                f"Launcher Dir: {self.launcher_dir}\n"
                f"PID: {os.getpid()}\n"
                f"Platform: {sys.platform}\n"
                f"{'=' * 40}"
            )
        self._log(info, level="info", force_file=True)

    def _log(self, msg, level="info", force_file=False):
        """ Безопасная запись сообщений Launcher в единый файл app.log """
        log_line = f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] [LAUNCHER] [{level.upper()}] {msg}"

        # Вывод в консоль
        if level in ("error", "info") or is_debug_mode():
            print(log_line, flush=True)

        # Запись в общий app.log
        if level in ("error", "info") or is_debug_mode() or force_file:
            try:
                with open(self.log_file, "a", encoding="utf-8") as f:
                    f.write(log_line + "\n")
            except Exception:
                pass  # Безопасный перехват на случай временной блокировки файла другим процессом


    def _signal_handler(self, signum, frame):
        self._log(f"Получен сигнал завершения ({signum})", "info", force_file=True)
        self.shutdown()
        sys.exit(0)

    def detect_system_encoding(self):
        try:
            return locale.getpreferredencoding() or 'utf-8'
        except:
            return 'utf-8'

    def preflight_checks(self):
        if not os.path.exists(self.script_path) and not getattr(sys, 'frozen', False):
            self._log(f"ОШИБКА: Файл {self.script_path} не найден!", "error")
            return False

        cfg_path = os.path.join(self.launcher_dir, "impuls.cfg")
        if not os.path.exists(cfg_path):
            self._log(f"ОШИБКА: Файл конфигурации {cfg_path} не найден!", "error")
            return False

        return True

    def start_script(self):
        if not self.preflight_checks():
            self._log("Pre-flight проверки не пройдены. Ожидание 10с...", "info")
            time.sleep(10)
            return

        if self.process and self.process.poll() is None:
            self._log("Завершение старого процесса перед перезапуском...", "info")
            self.process.terminate()
            try:
                self.process.wait(timeout=3)
            except:
                self.process.kill()

        if getattr(sys, 'frozen', False):
            cmd = [sys.executable, "-u", "--run-child", "--launcher-dir", self.launcher_dir]
        else:
            cmd = [self.venv_python, "-u", self.script_path, "--launcher-dir", self.launcher_dir]

        if is_debug_mode():
            cmd.append("--debug")

        self._log(f"Формируем команду запуска: {cmd}", "debug")

        try:
            if sys.platform.startswith('win'):
                startupinfo = subprocess.STARTUPINFO()
                startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
                startupinfo.wShowWindow = subprocess.SW_HIDE

                self.process = subprocess.Popen(
                    cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                    bufsize=0, cwd=self.launcher_dir,
                    startupinfo=startupinfo, creationflags=subprocess.CREATE_NO_WINDOW
                )
            else:
                self.process = subprocess.Popen(
                    cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                    bufsize=0, cwd=self.launcher_dir
                )

            self._log(f"Скрипт успешно запущен: PID {self.process.pid}", "debug")

            with self.ping_lock:
                self.last_ping = datetime.now()

        except Exception as e:
            self._log(f"КРИТИЧЕСКАЯ ОШИБКА вызова subprocess: {e}\n{traceback.format_exc()}", "error")
            self.process = None

    def monitor_stdout(self):
        while not self.stop_event.is_set():
            if not self.process or self.process.poll() is not None:
                time.sleep(0.1)
                continue

            try:
                line_bytes = self.process.stdout.readline()
                if not line_bytes:
                    time.sleep(0.01)
                    continue

                try:
                    line = line_bytes.decode(self.encoding).rstrip()
                except UnicodeDecodeError:
                    line = line_bytes.decode('utf-8', errors='replace').rstrip()

                # Фильтрация Keep Alive — только обновляем пинг, не засоряем app.log
                if "Keep Alive" in line:
                    with self.ping_lock:
                        self.last_ping = datetime.now()
                else:
                    self._log(f"[STDOUT]: {line}", "debug")

            except (BrokenPipeError, ValueError, OSError):
                time.sleep(0.1)

    def monitor_stderr(self):
        while not self.stop_event.is_set():
            if os.path.exists(self.stop_flag):
                self._log("Найден STOP.txt — завершаем работу...", "info", force_file=True)
                try:
                    os.remove(self.stop_flag)
                except:
                    pass
                self.shutdown()
                break

            if self.process:
                try:
                    line_bytes = self.process.stderr.readline()
                    if line_bytes:
                        try:
                            line = line_bytes.decode(self.encoding).rstrip()
                        except UnicodeDecodeError:
                            line = line_bytes.decode('utf-8', errors='replace').rstrip()

                        self._log(f"[STDERR]: {line}", "error")
                except (BrokenPipeError, ValueError, OSError):
                    pass
            time.sleep(0.2)

    def check_health(self):
        while not self.stop_event.is_set():
            time.sleep(self.check_interval)

            if not self.process:
                self.start_script()
                continue

            exit_code = self.process.poll()
            if exit_code is not None:
                if exit_code == 0:
                    self._log("Приложение завершилось штатно (Код 0). Останавливаем Launcher.", "info", force_file=True)
                    self.shutdown()
                    break
                else:
                    self._log(f"Скрипт упал (Код: {exit_code}) — перезапуск...", "error")
                    self.start_script()
                    continue

            with self.ping_lock:
                since_ping = (datetime.now() - self.last_ping).total_seconds()

            if since_ping > self.ping_timeout:
                self._log(f"Пинг не получен {since_ping:.1f}с — перезапуск зависшего процесса...", "error")
                self.start_script()

    def run(self):
        self.start_script()
        threading.Thread(target=self.monitor_stdout, daemon=True).start()
        threading.Thread(target=self.monitor_stderr, daemon=True).start()
        self.check_health()

    def shutdown(self):
        self.stop_event.set()
        if self.process and self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=3)
            except:
                self.process.kill()


if __name__ == "__main__":
    if '--run-child' in sys.argv:
        import runpy

        try:
            sys.stdout.reconfigure(line_buffering=True)
        except AttributeError:
            pass

        sys.argv.remove('--run-child')
        if '-u' in sys.argv: sys.argv.remove('-u')

        base_path = sys._MEIPASS if getattr(sys, 'frozen', False) else os.path.dirname(os.path.abspath(__file__))
        runpy.run_path(os.path.join(base_path, "main.py"), run_name='__main__')
        sys.exit(0)

    if is_debug_mode():
        toggle_console(show=True)
    else:
        toggle_console(show=False)

    kill_existing_process()

    base_path = sys._MEIPASS if getattr(sys, 'frozen', False) else os.path.dirname(os.path.abspath(__file__))
    launcher_dir = os.path.dirname(sys.executable) if getattr(sys, 'frozen', False) else base_path

    script_path = os.path.join(base_path, "main.py")

    monitor = ScriptMonitor(script_path, launcher_dir=launcher_dir, ping_timeout=60, check_interval=10)

    try:
        monitor.run()
    except KeyboardInterrupt:
        monitor.shutdown()
    except Exception as e:
        monitor._log(f"Глобальная ошибка Launcher: {e}\n{traceback.format_exc()}", "error")
        monitor.shutdown()