import locale
import os
import subprocess
import sys
import threading
import time
from datetime import datetime


class ScriptMonitor:
    def __init__(self, script_path, ping_timeout=60, check_interval=10):
        self.script_path = script_path
        self.ping_timeout = ping_timeout
        self.check_interval = check_interval
        self.process = None
        self.last_ping = datetime.now()
        self.stop_event = threading.Event()
        self.ping_lock = threading.Lock()
        self.venv_python_executable = None

        # Автоматическое определение кодировки системы
        self.encoding = self.detect_system_encoding()

        # Проверка и активация виртуального окружения
        if not self.ensure_venv_activated():
            print(f"[{datetime.now()}] КРИТИЧЕСКАЯ ОШИБКА: Не удалось активировать виртуальное окружение!")
            input("Нажмите Enter для выхода...")
            sys.exit(1)

    def ensure_venv_activated(self):
        """Проверяет и активирует виртуальное окружение"""
        # Проверяем, активировано ли уже виртуальное окружение
        in_venv = (
                hasattr(sys, 'real_prefix') or
                (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix) or
                os.environ.get('VIRTUAL_ENV') is not None
        )

        if in_venv:
            print(f"[{datetime.now()}] Виртуальное окружение уже активировано: {sys.prefix}")
            return True

        # Пытаемся найти и активировать виртуальное окружение
        venv_path = self.find_venv()
        if venv_path:
            print(f"[{datetime.now()}] Найдено виртуальное окружение: {venv_path}")
            return self.activate_venv(venv_path)

        print(f"[{datetime.now()}] Виртуальное окружение не найдено.")
        return False

    def detect_system_encoding(self):
        """Определяет кодировку системы"""
        try:
            encoding = locale.getpreferredencoding()
            if encoding:
                return encoding
        except:
            pass

        try:
            if sys.platform.startswith('win'):
                import ctypes
                kernel32 = ctypes.windll.kernel32
                return 'cp1251' if kernel32.GetConsoleOutputCP() == 1251 else 'cp866'
            else:
                return 'utf-8'
        except:
            return 'utf-8'

    def find_venv(self):
        """Пытается найти виртуальное окружение в типичных местах"""
        # Определяем базовый путь (рабочая директория или временная папка EXE)
        if getattr(sys, 'frozen', False):
            base_dir = os.path.dirname(sys.executable)
        else:
            base_dir = os.path.dirname(os.path.abspath(__file__))

        possible_paths = [
            os.path.join(base_dir, 'venv'),
            os.path.join(base_dir, '.venv'),
            os.path.join(base_dir, 'env'),
            os.path.join(base_dir, '.env'),
            os.path.join(os.path.dirname(base_dir), 'venv'),
            os.path.join(os.path.dirname(base_dir), '.venv'),
        ]

        for path in possible_paths:
            if os.path.exists(path) and os.path.isdir(path):
                # Проверяем, что это действительно venv
                if (os.path.exists(os.path.join(path, 'pyvenv.cfg')) or
                        (sys.platform.startswith('win') and
                         os.path.exists(os.path.join(path, 'Scripts', 'python.exe'))) or
                        (not sys.platform.startswith('win') and
                         os.path.exists(os.path.join(path, 'bin', 'python')))):
                    return os.path.abspath(path)

        return None

    def activate_venv(self, venv_path):
        """Активирует виртуальное окружение для текущего процесса"""
        try:
            if sys.platform.startswith('win'):
                # Для Windows
                python_executable = os.path.join(venv_path, 'Scripts', 'python.exe')
                # Добавляем Scripts в PATH
                scripts_path = os.path.join(venv_path, 'Scripts')
                if scripts_path not in os.environ['PATH']:
                    os.environ['PATH'] = scripts_path + os.pathsep + os.environ['PATH']
            else:
                # Для Unix-систем
                python_executable = os.path.join(venv_path, 'bin', 'python')
                # Добавляем bin в PATH
                bin_path = os.path.join(venv_path, 'bin')
                if bin_path not in os.environ['PATH']:
                    os.environ['PATH'] = bin_path + os.pathsep + os.environ['PATH']

            # Проверяем существование интерпретатора Python в venv
            if not os.path.exists(python_executable):
                print(f"[{datetime.now()}] Ошибка: Python интерпретатор не найден в {python_executable}")
                return False

            # Сохраняем путь к интерпретатору как атрибут экземпляра
            self.venv_python_executable = python_executable

            # Устанавливаем переменную окружения VIRTUAL_ENV
            os.environ['VIRTUAL_ENV'] = venv_path

            return True

        except Exception as e:
            print(f"[{datetime.now()}] Ошибка при активации venv: {e}")
            return False

    def start_script(self):
        """Запускает скрипт с использованием интерпретатора из venv (если найден)"""
        if self.process and self.process.poll() is None:
            self.process.terminate()
            self.process.wait()

        # Используем интерпретатор из venv, если он доступен
        python_executable = self.venv_python_executable or sys.executable

        self.process = subprocess.Popen(
            [python_executable, "-u", self.script_path, "--launcher-dir", self.launcher_dir],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=False,
            bufsize=0
        )

        with self.ping_lock:
            self.last_ping = datetime.now()

    def monitor_output(self):
        """Читает вывод скрипта и обновляет last_ping с правильной кодировкой"""
        while not self.stop_event.is_set() and self.process.poll() is None:
            line_bytes = self.process.stdout.readline()
            if line_bytes:
                try:
                    line = line_bytes.decode(self.encoding).strip()
                except UnicodeDecodeError:
                    try:
                        line = line_bytes.decode('utf-8').strip()
                    except UnicodeDecodeError:
                        try:
                            line = line_bytes.decode('cp1251').strip()
                        except UnicodeDecodeError:
                            line = line_bytes.decode('cp866', errors='replace').strip()

                print(f"[{datetime.now()}] Основной скрипт: {line}")
                if "Keep Alive" in line:
                    with self.ping_lock:
                        self.last_ping = datetime.now()

    def check_health(self):
        """Проверяет состояние скрипта с синхронизацией"""
        while not self.stop_event.is_set():
            time.sleep(self.check_interval)

            if self.process is None or self.process.poll() is not None:
                print(f"[{datetime.now()}] Скрипт завершился, перезапускаем...")
                self.start_script()
                threading.Thread(target=self.monitor_output, daemon=True).start()
                continue

            with self.ping_lock:
                time_since_ping = (datetime.now() - self.last_ping).total_seconds()

            if time_since_ping > self.ping_timeout:
                print(f"[{datetime.now()}] Пинг не получен {time_since_ping:.1f} сек, перезапускаем...")
                self.start_script()
                threading.Thread(target=self.monitor_output, daemon=True).start()

    def run(self):
        """Основной цикл мониторинга"""
        self.start_script()
        threading.Thread(target=self.monitor_output, daemon=True).start()
        self.check_health()

    def shutdown(self):
        """Корректное завершение"""
        self.stop_event.set()
        if self.process and self.process.poll() is None:
            self.process.terminate()
            self.process.wait()


if __name__ == "__main__":
    # Определяем базовый путь в зависимости от режима запуска
    if getattr(sys, 'frozen', False):
        # Если запущено как EXE то берем временную папку и папку запуска EXE
        base_path = sys._MEIPASS
        launcher_dir = os.path.dirname(sys.executable)
    else:
        # Запущено как скрипт - используем директорию скрипта
        base_path = os.path.dirname(os.path.abspath(__file__))
        launcher_dir = base_path

    script_path = os.path.join(base_path, "main.py")

    if not os.path.exists(script_path):
        print("Ошибка: файл main.py не найден!")
        print("Доступные файлы в директории:")
        for item in os.listdir(base_path):
            print(f"  - {item}")
        sys.exit(1)

    monitor = ScriptMonitor(script_path, ping_timeout=60, check_interval=10)
    monitor.launcher_dir = launcher_dir

    try:
        monitor.run()
    except KeyboardInterrupt:
        print("\nЗавершение работы монитора...")
        monitor.shutdown()