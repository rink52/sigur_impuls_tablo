import os
import logging

from logging.handlers import RotatingFileHandler
from venv import logger


def setup_logging(maxsize=5, countlogs=2, log_dir='logs', log_file='app.log'):
    """Настройка логирования для всего проекта"""

    # Создаем директорию для логов, если её нет
    os.makedirs(log_dir, exist_ok=True)

    # Основной логгер
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # Формат сообщений
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    # Файловый обработчик (ротация по размеру)
    file_handler = RotatingFileHandler(
        filename=os.path.join(log_dir, log_file),
        maxBytes=maxsize * 1024 * 1024,  # максимальный размер лога в MB
        backupCount=countlogs,
        encoding='utf-8'
    )
    file_handler.setFormatter(formatter)

    # Консольный вывод
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    console_handler.setLevel(logging.ERROR)  # В консоль только ERROR и выше

    # Очистка старых обработчиков (на случай повторного вызова)
    for handler in logger.handlers[:]:
        logger.removeHandler(handler)

    # Добавляем обработчики
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    # # Логгер для SQL-запросов (можно отключить в продакшене)
    # logging.getLogger('main').setLevel(logging.DEBUG)


