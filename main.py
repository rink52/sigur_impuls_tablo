import logging
import schedule
import time
import socket
import errors_server
import decode_packet
import Service_parsed_db
import impuls
from os import path
from logging_config import setup_logging
from parsing_cfg import parse_cfg



# Проверка компонентов
library_files = ('parsing_cfg.py',
                 'maria.py',
                 'logging_config.py',
                 'Service_parsed_db.py',
                 'impuls.py',
                 'script.py',
                 'errors_server.py')

if not all(path.exists(name) for name in library_files):
    print("Отсутствуют необходимые файлы интеграции")
    exit(1)

# Инициализация компонентов

    # Чтение конфигурации
conf = parse_cfg()

    # Инициализация логирования
try:
    setup_logging(maxsize=int(conf['LenLog']), countlogs=2)
    logger = logging.getLogger('main')
    logging.getLogger('main').setLevel(logging.INFO)

    # Если в config включен Debug=1 режим, то активируем рассширенное логгирование
    if conf.get('Debug', 0) == 1:
        logging.getLogger().setLevel(logging.DEBUG)
        logging.getLogger('main').setLevel(logging.DEBUG)
        logger.debug("Включено расширенное логгирование. Если это не требуется, то выключите параметр Debug в impuls.cfg")
        print("Включено расширенное логгирование. Если это не требуется, то выключите параметр Debug в impuls.cfg")

    logger.info(f"Сервис запущен")
except Exception as e:
    print("Ошибка конфигурации логирования. Ошибка:", e)
    exit(1)




# Основной блок
try:
    queue_sended = {'1':'2fg3b-bb33','5': 'wqeqww'}
    queue_sending = {}
    sended_packets = {}

    # Получаем список доп. параметров
    sideparam = Service_parsed_db.sideparam(conf)

    def main(server_socket, conf):
        global queue_sent_packets
        global queue_sended
        global sended_packets
        global queue_sending
        pre_queue_sending = {}
        last_key = 0

        impuls.test_connection(server_socket, conf)

        if sended_packets:
            last_key = list(sended_packets.keys())[-1]

        sended_packets.clear()
        queue_sending.clear()

        queue = Service_parsed_db.queue(conf, sideparam)

        # проверяем, что номер в прошлый раз отправлялся с этой же позицией в очереди и пропускаем его
        for key_queue, value_queue in queue.items():
            if value_queue == queue_sended.get(key_queue):
                pre_queue_sending[int(key_queue)] = "NULL"
                continue
            # проверим, что позиция в очереди указана числом
            elif not key_queue.isdigit():
                logger.error(f"Позиция в очереди для номера {value_queue} не число и имеет значение {key_queue}. Игнорируем.")
                continue
            # проверим, что позиция в очереди не больше количества мест на табло
            elif int(key_queue) > conf['NumberRows']:
                logger.info(f"Позиция в очереди для номера {value_queue} ровна {key_queue}, что больше чем указано в 'NumberRows'. Игнорируем.")
                continue
            else:
                # иначе добавляем в очередь отправки
                pre_queue_sending[int(key_queue)] = value_queue
                if len(pre_queue_sending) == conf['NumberRows']:
                    break

        # теперь у нас есть предварительная очередь отправки pre_queue_sending, добавим пустые строки и сформируем готовую очередь отправки
        for index in range(1, conf['NumberRows']+1):
            if pre_queue_sending.get(index):
                queue_sending[index] = pre_queue_sending.get(index)
            else:
                queue_sending[index] = ""
        print('queue_sending', queue_sending)
        print('last key', last_key)
        queue_sended.clear()

        # for position, obj in queue_sending.items():











    # Открываем сокет
    try:
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        server_socket.bind(('0.0.0.0', conf['ServicePort']))
        server_socket.setblocking(False)  # Неблокирующий режим
        logger.debug(f"Сокет открыт на порту: {conf['ServicePort']}")
    except (OSError, OverflowError):
        #Если порт занят, то проверяем кем
        errors_server.find_process_using_port(conf['ServicePort'])
        exit(1)

    # первичная настройка табло
        # проверка связи с табло
    impuls.test_connection(server_socket, conf)
        # настраиваем яркость
    impuls.set_bright(server_socket, conf)
        # настраиваем время
    if conf.get('TimeSync', 0) == 1:
        impuls.time_set(server_socket, conf)
        pass




    # превентивно запускаем main() для формирования первичной очереди
    main(server_socket, conf)
    # ставим задачу, чтобы функция main() запускалась раз в указанныый период
    schedule.every(conf['Period']).seconds.do(main, server_socket, conf)

    while True:
        # print('Keep-Alive')
        # проверяем необходимость запуска функции main, если время не пришло, то ингорируем
        schedule.run_pending()

        # начинаем отправку данных
        try:
            # смотрим есть ли в сокете пакеты
            up_pack, clientaddress = server_socket.recvfrom(impuls.buffer_size)
            print(up_pack.hex())
        except BlockingIOError:
            # если нет то продолжаем ждать
            pass

        time.sleep(1)

except SystemExit:
    logger.info("Выполнение программы остановлено")
except OSError as e:
    logger.error(e)

finally:
    server_socket.close()
    logger.info("Сервис остановлен")