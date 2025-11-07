import locale
import os
import subprocess
import sys
import threading
import time
from datetime import datetime
import signal
import ctypes
import psutil

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
    current_exe = sys.executable.lower()
    current_name = os.path.basename(current_exe)

    for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'exe']):
        is_our_process = False
        try:
            info = proc.info
            if not info['cmdline']:
                continue

            is_our_process = 'impuls.exe' in (info['name'].lower() if info['name'] else '')

            if is_our_process and info['pid'] != current_pid:
                print(f"[{datetime.now()}] Завершаем предыдущий экземпляр (PID: {info['pid']})...")
                proc.terminate()
                try:
                    proc.wait(timeout=5)
                except psutil.TimeoutExpired:
                    proc.kill()
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass


# --- Основной код ---
if __name__ == "__main__":
    if is_debug_mode():
        # Режим отладки: показываем консоль
        toggle_console(show=True)
        print("Запущен в режиме отладки (-debug)")
        print("Проверка наличия ранее запущенных экземпляров impuls.exe ...")
    else:
        # Без отладки: скрываем консоль
        toggle_console(show=False)

    # Запускаем логику убийства процесса
    kill_existing_process()
    print('\nВсе чисто, продолжаем работу...\n')

    # --- Остальной код ---
    class ScriptMonitor:
        # (Ваш класс без изменений, но с учётом отладки)
        def __init__(self, script_path, ping_timeout=60, check_interval=10):
            self.script_path = script_path
            self.ping_timeout = ping_timeout
            self.check_interval = check_interval
            self.process = None
            self.last_ping = datetime.now()
            self.stop_event = threading.Event()
            self.ping_lock = threading.Lock()
            self.venv_python_executable = None
            self.launcher_dir = ""
            self.stop_flag = os.path.join(self.launcher_dir, "STOP.txt")
            self.encoding = self.detect_system_encoding()
            if not self.ensure_venv_activated():
                self._log("КРИТИЧЕСКАЯ ОШИБКА: Не удалось активировать виртуальное окружение!")
                if is_debug_mode():
                    input("Нажмите Enter для выхода...")
                sys.exit(1)
            signal.signal(signal.SIGTERM, self._signal_handler)
            signal.signal(signal.SIGINT, self._signal_handler)

        def _log(self, msg):
            # Выводим только если в режиме отладки
            if is_debug_mode():
                print(f"[{datetime.now()}] {msg}")

        def _signal_handler(self, signum, frame):
            self._log(f"Получен сигнал завершения ({signum})")
            self.shutdown()
            sys.exit(0)

        # (Все остальные методы остаются без изменений)
        def ensure_venv_activated(self):
            in_venv = (
                hasattr(sys, 'real_prefix') or
                (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix) or
                os.environ.get('VIRTUAL_ENV')
            )
            if in_venv:
                self._log(f"Виртуальное окружение уже активировано: {sys.prefix}")
                return True

            venv_path = self.find_venv()
            if venv_path:
                self._log(f"Найдено виртуальное окружение: {venv_path}")
                return self.activate_venv(venv_path)
            self._log("Виртуальное окружение не найдено.")
            return False

        def detect_system_encoding(self):
            try:
                return locale.getpreferredencoding() or 'utf-8'
            except:
                pass
            try:
                if sys.platform.startswith('win'):
                    import ctypes
                    cp = ctypes.windll.kernel32.GetConsoleOutputCP()
                    return 'cp1251' if cp == 1251 else 'cp866'
                return 'utf-8'
            except:
                return 'utf-8'

        def find_venv(self):
            if getattr(sys, 'frozen', False):
                base_dir = os.path.dirname(sys.executable)
            else:
                base_dir = os.path.dirname(os.path.abspath(__file__))

            possible = [
                os.path.join(base_dir, 'venv'),
                os.path.join(base_dir, '.venv'),
                os.path.join(base_dir, 'env'),
                os.path.join(os.path.dirname(base_dir), 'venv'),
            ]
            for path in possible:
                if not os.path.isdir(path):
                    continue
                cfg = os.path.join(path, 'pyvenv.cfg')
                win_py = os.path.join(path, 'Scripts', 'python.exe')
                nix_py = os.path.join(path, 'bin', 'python')
                if os.path.exists(cfg) or os.path.exists(win_py) or os.path.exists(nix_py):
                    return os.path.abspath(path)
            return None

        def activate_venv(self, venv_path):
            try:
                if sys.platform.startswith('win'):
                    python_exe = os.path.join(venv_path, 'Scripts', 'python.exe')
                    scripts_path = os.path.join(venv_path, 'Scripts')
                else:
                    python_exe = os.path.join(venv_path, 'bin', 'python')
                    scripts_path = os.path.join(venv_path, 'bin')

                if not os.path.exists(python_exe):
                    self._log(f"Python не найден в venv: {python_exe}")
                    return False

                if scripts_path not in os.environ['PATH']:
                    os.environ['PATH'] = scripts_path + os.pathsep + os.environ['PATH']

                self.venv_python_executable = python_exe
                os.environ['VIRTUAL_ENV'] = venv_path
                return True
            except Exception as e:
                self._log(f"Ошибка активации venv: {e}")
                return False

        def start_script(self):
            if self.process and self.process.poll() is None:
                self.process.terminate()
                try:
                    self.process.wait(timeout=3)
                except:
                    self.process.kill()

            python_exe = self.venv_python_executable or sys.executable
            cmd = [python_exe, "-u", self.script_path, "--launcher-dir", self.launcher_dir]

            try:
                if sys.platform.startswith('win'):
                    startupinfo = subprocess.STARTUPINFO()
                    startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
                    startupinfo.wShowWindow = subprocess.SW_HIDE

                    self.process = subprocess.Popen(
                        cmd,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        bufsize=0,
                        startupinfo=startupinfo,
                        creationflags=subprocess.CREATE_NO_WINDOW
                    )
                else:
                    self.process = subprocess.Popen(
                        cmd,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        bufsize=0
                    )

                self._log(f"Скрипт запущен: PID {self.process.pid}")
                with self.ping_lock:
                    self.last_ping = datetime.now()

            except Exception as e:
                self._log(f"ОШИБКА запуска main.py: {e}")
                self.process = None

        def monitor_output(self):
            while not self.stop_event.is_set():
                if not self.process:
                    time.sleep(0.1)
                    continue
                if self.process.poll() is not None:
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

                    self._log(f"Основной скрипт: {line}")
                    if "Keep Alive" in line:
                        with self.ping_lock:
                            self.last_ping = datetime.now()

                except (BrokenPipeError, ValueError, OSError):
                    time.sleep(0.1)
                    continue

        def check_stop_flag(self):
            while not self.stop_event.is_set():
                if os.path.exists(self.stop_flag):
                    self._log("Найден STOP.txt — завершаем работу...")
                    os.remove(self.stop_flag)
                    self.shutdown()
                    break
                try:
                    line_bytes = self.process.stderr.readline()
                    if not line_bytes:
                        time.sleep(0.01)
                        continue

                    try:
                        line = line_bytes.decode(self.encoding).rstrip()
                    except UnicodeDecodeError:
                        line = line_bytes.decode('utf-8', errors='replace').rstrip()

                    self._log(f"ОШИБКА основного скрипта: {line}")

                except (BrokenPipeError, ValueError, OSError):
                    time.sleep(0.1)
                    continue
                time.sleep(1)

        def check_health(self):
            while not self.stop_event.is_set():
                time.sleep(self.check_interval)
                if not self.process or self.process.poll() is not None:
                    self._log("Скрипт упал или не запущен — перезапускаем...")
                    self.start_script()
                    continue

                with self.ping_lock:
                    since_ping = (datetime.now() - self.last_ping).total_seconds()

                if since_ping > self.ping_timeout:
                    self._log(f"Пинг не получен {since_ping:.1f}с — перезапуск...")
                    self.start_script()

        def run(self):
            self.stop_flag = os.path.join(self.launcher_dir, "STOP.txt")
            self._log("Запуск монитора...")

            self.start_script()

            threading.Thread(target=self.monitor_output, daemon=True).start()
            threading.Thread(target=self.check_stop_flag, daemon=True).start()

            self.check_health()

        def shutdown(self):
            self._log("Остановка монитора...")
            self.stop_event.set()
            if self.process and self.process.poll() is None:
                self.process.terminate()
                try:
                    self.process.wait(timeout=3)
                except:
                    self.process.kill()

    # --- Запуск ---
    if getattr(sys, 'frozen', False):
        base_path = sys._MEIPASS
        launcher_dir = os.path.dirname(sys.executable)
    else:
        base_path = os.path.dirname(os.path.abspath(__file__))
        launcher_dir = base_path

    script_path = os.path.join(base_path, "main.py")
    if not os.path.exists(script_path):
        if is_debug_mode():
            print("ОШИБКА: main.py не найден!")
            print("Файлы в папке:")
            for f in os.listdir(base_path):
                print(f"  - {f}")
        sys.exit(1)

    monitor = ScriptMonitor(script_path, ping_timeout=60, check_interval=10)
    monitor.launcher_dir = launcher_dir

    try:
        monitor.run()
    except KeyboardInterrupt:
        monitor.shutdown()