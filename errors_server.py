import logging
import psutil

logger = logging.getLogger(__name__)

def find_process_using_port(port):
    if port < 0 or port > 65535:
        logger.warning(f"Порт указанный в impuls.cfg: '{port}' не корректный. Порт может быть [0-65535]")
    else:
        for conn in psutil.net_connections():
            if conn.laddr.port == port:
                pid = conn.pid
                process = psutil.Process(pid)
                print(f"Порт {port} занят процессом: PID: {pid}, Имя процесса: {process.name()}, Статус: {conn.status}, Локальный адрес: {conn.laddr.ip}")
                logger.warning(f"Порт {port} занят процессом: PID: {pid}, Имя процесса: {process.name()}, Статус: {conn.status}, Локальный адрес: {conn.laddr.ip}")
    return None