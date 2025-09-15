import logging
import schedule
import time
import socket
import Service_parsed_db
import impuls
from os import path
from logging_config import setup_logging
from parsing_cfg import parse_cfg
import psutil


# Проверка компонентов
library_files = ('parsing_cfg.py',
                 'maria.py',
                 'logging_config.py',
                 'Service_parsed_db.py',
                 'impuls.py'
                 )

server_socket = None


if not all(path.exists(name) for name in library_files):
    exit("Ошибка: Отсутствуют необходимые файлы интеграции")

# Инициализация компонентов

# Чтение конфигурации
conf: dict = parse_cfg()

# Инициализация логирования
try:
    setup_logging(maxsize=int(conf.get("LenLog", 100)), countlogs=conf.get('Count_logs_file', 2))
    logger = logging.getLogger('main')
    logging.getLogger('main').setLevel(logging.INFO)

    # Если в config включен Debug=1 режим, то активируем рассширенное логгирование
    if conf.get('Debugы', 0) == 1:
        logging.getLogger().setLevel(logging.DEBUG)
        logging.getLogger('main').setLevel(logging.DEBUG)
        logger.debug(
            "Включено расширенное логгирование. Если это не требуется, то выключите параметр Debug в impuls.cfg")
        print("Включено расширенное логгирование. Если это не требуется, то выключите параметр Debug в impuls.cfg")

    logger.info(f"Сервис запущен")
except Exception as e:
    print("Ошибка конфигурации логирования. Ошибка:", e)
    exit(1)


def find_process_using_port(port):
    """Функция логирования ошибок открытия сокета"""
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

# Основной блок
try:
    sended_packets: dict = {}  # Отправленные пакеты на которые еще не вернулся ответ ОК
    last_pid: int = 0  # последний использованный PID пакета (0 - 254)

    # Получаем список доп. параметров
    sideparam = Service_parsed_db.sideparam(conf)


    def main(server_socket, conf: dict):
        global sended_packets
        global last_pid

        pre_queue_sending: dict = {}  # предварительная очередь отправки, полученная из БД
        queue_sending: dict = {}  # Очередь для отправки

        # очистка очереди отправки в новом цикле
        queue_sending.clear()
        sended_packets.clear()

        # получаем очередь отправки из БД
        # queue = {'03': 'фывваа', '2': 'А123АА333', '8': 'B22g54SDf', "2": "AAABBBCCCDDDD"}
        queue = Service_parsed_db.queue(conf, sideparam)

        logger.debug("queue:", queue)
        # проверяем значения на соответствие требованиям отправки
        for key_queue, value_queue in queue.items():
            # проверим, что позиция в очереди указана числом
            if not key_queue.isdigit():
                logger.error(
                    f"Позиция в очереди для номера {value_queue} не число и имеет значение {key_queue}. Игнорируем.")
                continue
            # проверим, что позиция в очереди не больше количества места на табло
            elif int(key_queue) > conf['NumberRows']:
                logger.info(
                    f"Позиция в очереди для номера {value_queue} ровна {key_queue}, что больше чем указано в 'NumberRows'. Игнорируем.")
                continue
            # проверка на отрицательные значения
            elif int(key_queue) < 1:
                logger.info(f"Позиция в очереди для номера {value_queue} ровна {key_queue}, что меньше 1. Игнорируем.")
                continue
            elif len(value_queue) > conf.get('CountSymbolString') - 3:
                logger.info(f"Длина номера превышает длину строки. Номер '{value_queue}' будет обрезан до '{value_queue[:conf.get('CountSymbolString') - 2]}'")
                print(f"Длина номера превышает длину строки. Номер '{value_queue}' будет обрезан до '{value_queue[:conf.get('CountSymbolString') - 2]}'")
                pre_queue_sending[int(key_queue)] = value_queue[:conf.get('CountSymbolString') - 3]
            else:
                # иначе добавляем в очередь отправки
                pre_queue_sending[int(key_queue)] = value_queue

            if len(pre_queue_sending) == conf['NumberRows']:
                break
        # теперь у нас есть предварительная очередь отправки pre_queue_sending

        # добавим пустые строки (для очистки не задействованных строк табло) и сформируем готовую очередь отправки
        for index in range(1, conf['NumberRows'] + 1):
            if pre_queue_sending.get(index):
                queue_sending[index] = pre_queue_sending.get(index)
            else:
                queue_sending[index] = " "

        while True:
            if impuls.test_connection(server_socket, conf):
                break

        for position, obj in queue_sending.items():
            if last_pid == 255:
                last_pid = 0
            last_pid += 1
            display_obj = [None, 0, 1, 2, 3, 4, 5, 6, 7]
            if conf.get('Command', "0x05") == "0x05":
                impuls.send_data_for_table_0x05(server_socket, conf, sended_packets, last_pid, obj, str(position),
                                                display_obj[position], None)
                time.sleep(0.01)


    # Открываем сокет
    try:
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        server_socket.bind(('0.0.0.0', conf.get('ServicePort', 12345)))
        server_socket.setblocking(False)  # Неблокирующий режим
        logger.debug(f"Сокет открыт на порту: {conf.get('ServicePort', 12345)}")
    except (OSError, OverflowError):
        # Если порт занят, то проверяем кем
        find_process_using_port(conf.get('ServicePort', 12345))
        exit("Ошибка при открытии порта связи.")

    # первичная настройка табло
    # проверка связи с табло, ждем явного ответа
    while True:
        if impuls.test_connection(server_socket, conf):
            break

    # настраиваем яркость
    impuls.set_bright(server_socket, conf)
    # настраиваем время
    if conf.get('TimeSync', 0) == 1:
        impuls.time_set(server_socket, conf)


    # Инициализируем планировщик
    job = schedule.every(conf.get("Period", 300)).seconds.do(main, server_socket, conf)

    # превентивно запускаем main() для формирования первичной очереди,
    # так как планировщик запустит функцию только по истечению периода.
    main(server_socket, conf)

    while True:
        # Проверяем необходимость запуска функции main
        schedule.run_pending()


        # получаем время следующего запуска
        next_run = job.next_run.timestamp()

        # Вычисляем оставшееся время до следующего запуска
        time_remaining = next_run - time.time()
        logger.debug(f"До следующего запуска: {time_remaining:.0f} секунд")
        if conf.get('Debug', 0) == 1:
            print("Keep Alive")
            print(f"До следующего запуска: {time_remaining:.0f} секунд")


        check = False
        while True:
            time.sleep(0.5)
            # Проверяем, не пора ли прервать выполнение для нового цикла (остается менее 3 секунд)
            if next_run - time.time() <= 3:
                break
            # Проверяем есть ли пакеты на которые не получили ответов
            elif sended_packets:
                try:
                   impuls.check_incoming_packet(server_socket, sended_packets)
                   continue
                except BlockingIOError:
                    # если в буфере пакетов нет, то сначала ждем возможной доставки и повторно проверяем буфер,
                    # а затем отправляем пакеты заново.
                    if check == False:
                        check = True
                        time.sleep(0.5)
                        continue

                    sended_packets_copy = sended_packets.copy()
                    sended_packets.clear()
                    for pid_pack, param_pack in sended_packets_copy.items():
                        logger.error(f"Не получен ответ на отправленный пакет. PID: {pid_pack} Packet: {param_pack}")
                        data_up_pack = impuls.decode_upper_level_packet(param_pack.get('packet'))
                        data_pack = impuls.parse_packet(data_up_pack)
                        if last_pid == 255:
                            last_pid = 0
                        last_pid += 1
                        impuls.send_data_for_table_0x05(server_socket, conf, sended_packets, last_pid, param_pack.get('text'), "NULL", param_pack.get('display'), data_pack)
                        time.sleep(0.01)
                    sended_packets_copy.clear()
                    time.sleep(0.5)
                    continue
            # если пакетов в sended_packets нет, то на всякий случай очищаем буфер входящих пакетов
            else:
                while True:
                    try:
                        impuls.check_incoming_packet(server_socket, None)
                    except BlockingIOError:
                        break
            break


except SystemExit:
    logger.info("Выполнение программы остановлено")
except OSError as e:
    logger.error(e)
except Exception as e:
    logger.error(f"Неожиданная ошибка: {e}")

finally:
    if server_socket:
        server_socket.close()
    logger.info("Сервис остановлен")
    exit("Сервис остановлен")