import logging
import socket
import struct
import time
from datetime import datetime

from parsing_cfg import parse_cfg

logger = logging.getLogger(__name__)

buffer_size = 128

# Таблица CRC
CrcTable = [
    0, 94, 188, 226, 97, 63, 221, 131, 194, 156, 126, 32, 163, 253, 31, 65,
    157, 195, 33, 127, 252, 162, 64, 30, 95, 1, 227, 189, 62, 96, 130, 220,
    35, 125, 159, 193, 66, 28, 254, 160, 225, 191, 93, 3, 128, 222, 60, 98,
    190, 224, 2, 92, 223, 129, 99, 61, 124, 34, 192, 158, 29, 67, 161, 255,
    70, 24, 250, 164, 39, 121, 155, 197, 132, 218, 56, 102, 229, 187, 89, 7,
    219, 133, 103, 57, 186, 228, 6, 88, 25, 71, 165, 251, 120, 38, 196, 154,
    101, 59, 217, 135, 4, 90, 184, 230, 167, 249, 27, 69, 198, 152, 122, 36,
    248, 166, 68, 26, 153, 199, 37, 123, 58, 100, 134, 216, 91, 5, 231, 185,
    140, 210, 48, 110, 237, 179, 81, 15, 78, 16, 242, 172, 47, 113, 147, 205,
    17, 79, 173, 243, 112, 46, 204, 146, 211, 141, 111, 49, 178, 236, 14, 80,
    175, 241, 19, 77, 206, 144, 114, 44, 109, 51, 209, 143, 12, 82, 176, 238,
    50, 108, 142, 208, 83, 13, 239, 177, 240, 174, 76, 18, 145, 207, 45, 115,
    202, 148, 118, 40, 171, 245, 23, 73, 8, 86, 180, 234, 105, 55, 213, 139,
    87, 9, 235, 181, 54, 104, 138, 212, 149, 203, 41, 119, 244, 170, 72, 22,
    233, 183, 85, 11, 136, 214, 52, 106, 43, 117, 151, 201, 74, 20, 246, 168,
    116, 42, 200, 150, 21, 75, 169, 247, 182, 232, 10, 84, 215, 137, 107, 53
]

# Определяем коды ошибок ответов от табло
code_error = {0: "define_ecOK",  # нет ошибок
              1: "define_ecBadCommand",  # несуществующая команда
              2: "define_ecParamError",  # неверные параметры команды
              3: "define_ecExecuteError"  # невозможно выполнить команду
              }


# Функция для расчета контрольной суммы (CS)
def calculate_checksum(data):
    cs1 = 0
    cs2 = 0
    for byte in data:
        cs1 = CrcTable[cs1 ^ byte]
        cs2 += ~byte
    cslo = cs1 & 0xFF  # cslo (младшие) должен быть 8-битным
    cshi = cs2 & 0x3F  # cshi (старшие) должен быть 6-битным
    return cslo, cshi


def CS2word(cslo, cshi):
    """ Функция кодирования контрольной суммы для вставки в пакет, а также длины пакета"""
    return (0x8080 | cslo | (((cslo << 1) & 0x100)) | (cshi << 9))


def encode_data_for_decoded_pack(src_data):
    """ Функция кодирования данных для передачи """
    encoded_data = bytearray()
    for byte in src_data:
        b = byte ^ 0x80  # инвертируем старший бит
        if b < 0x20 or b == 0x7F:  # проверям условие соответствия
            encoded_data.append(0x7F)
            encoded_data.append(b | 0x80)
        else:
            encoded_data.append(b)
    return encoded_data


def make_full_packet(src_addr: int, dst_addr: int, pid: int, cmd: int, flags: int, status: int, data_len: int, data):
    """ Функция для формирования полного пакета """
    # Структура заголовка
    header = struct.pack('<HHBBBBH', src_addr, dst_addr, pid, cmd, flags, status, data_len)
    # Склеиваем заголовок с данными
    if data is None:
        full_data = header
    else:
        full_data = header + data
    cslo, cshi = calculate_checksum(full_data)  # Подсчет младших и старших байт для контрольной суммы
    checksum = CS2word(cslo, cshi)  # Контрольная сумма
    packet_len = len(full_data)  # Длина пакета
    lo_len = packet_len & 0xFF  # младшие байты длины
    hi_len = (packet_len >> 8) & 0xFF  # старшие байты длины
    # Создаем и заполняем структуру полного пакета
    full_packet = bytearray()
    full_packet.append(0x02)  # Start byte
    full_packet.extend(struct.pack('<H', CS2word(lo_len, hi_len)))
    full_packet.extend(encode_data_for_decoded_pack(full_data))
    full_packet.extend(struct.pack('<H', checksum))
    full_packet.append(0x03)  # End byte
    return full_packet


def decode_upper_level_packet(packet):
    """Декодируем пакет для получения результата"""
    if packet[0] == 0x02 and packet[-1] == 0x03:
        packet = packet[3:-3]
        decoded = bytearray()
        skip_next = False
        for i in range(len(packet)):
            if skip_next:
                skip_next = False
                continue
            if packet[i] == 0x7F:
                decoded.append(packet[i + 1] ^ 0x80)
                skip_next = True
            else:
                decoded.append(packet[i] ^ 0x80)
        return decoded
    return None


def parse_packet(decoded_pack):
    pid = decoded_pack[4]
    cmd = decoded_pack[5]
    flags = decoded_pack[6]
    status = decoded_pack[7]
    data = None
    if cmd != 1 and cmd != 4:
        data = decoded_pack[10:]
    logger.debug(f"Ответ из входящего пакета: pid: {pid}, cmd: {cmd}, flags: {flags}, status: {status}, data: {data}")
    return pid, cmd, flags, status, data


def check_incoming_packet(socket=None, sended_packets=None):
    approve_packet = False
    encoded_pack, clientaddress = socket.recvfrom(buffer_size)
    decoded_pack = decode_upper_level_packet(encoded_pack)
    result = parse_packet(decoded_pack)
    logger.debug(f"Sended_packets: {sended_packets}")
    if sended_packets is not None:
        if sended_packets.get(result[0]) and result[3] == 0:
            logger.debug(f"Получили ответ. Удаляем пакет {sended_packets.get(result[0])} из sended_packets.")
            del sended_packets[result[0]]
            approve_packet = True
    return result, approve_packet


    #______________________________________________
    #___Обработка пактов в зависимости от задачи___

def test_connection(socket, conf):
    """Тест связи с табло"""
    try:
        while True:
            logger.debug(f"Проверка связи с табло. IP: {conf['IPDst']} Port: {conf['PortDst']}")
            src_addr = 0x0000
            dst_addr = conf.get("DstAddr", 1)
            pid = 0
            cmd = 0x01
            flags = 0x02  # игнорируем pid
            status = 0x80
            DataLen = 0
            data = None
            packet = make_full_packet(src_addr, dst_addr, pid, cmd, flags, status, DataLen, data)
            socket.sendto(packet, (conf.get("IPDst"), conf.get("PortDst")))

            for _ in range(50):
                try:
                    result, approve = check_incoming_packet(socket=socket, sended_packets=None)
                    if result[1] == 1 and result[3] == 0:
                        logger.debug("Соединение с табло активно")
                        print("Соединение с табло активно")
                        return True
                except BlockingIOError:
                    time.sleep(0.5)
                    continue  # если в буфере пакетов нет, то игнорируем

            logger.error(f"Нет ответа от табло")
            time.sleep(5)

    except ConnectionResetError:
        print("Ошибка соединения")
        logger.error(
            f"Удаленный хост {conf['IPDst']}:{conf['PortDst']} принудительно разорвал существующее подключение. Проверьте корректность указанных данных для подключения")
        time.sleep(5)
        test_connection(socket, conf)


def set_bright(socket, conf):
    """Установка яркости"""
    src_addr = 0x0000
    dst_addr = conf.get("DstAddr")
    pid = 0
    cmd = 0x02
    flags = 0x02  # игнорируем pid
    status = 0x80
    DataLen = 1
    data = struct.pack('B', conf.get("Brightness", 5))
    packet = make_full_packet(src_addr, dst_addr, pid, cmd, flags, status, DataLen, data)
    socket.sendto(packet, (conf.get("IPDst"), conf.get("PortDst")))


    for _ in range(10):
        try:
            result, approve = check_incoming_packet(socket=socket, sended_packets=None)
            if result[1] == 2:
                if result[3] == 0:
                    logger.debug("Ярксть настроена корректно")
                    print("Ярксть настроена корректно")
                    return
                else:
                    logger.debug(f"При попытке установки яркости получена ошибка {code_error[result[3]]}")
                    continue
            else:
                continue
        except BlockingIOError:
            # если в сокете пакетов нет то игнорируем
            time.sleep(0.2)
            continue
    logger.debug("Не удалось настроить яркость.")
    print("Не удалось настроить яркость.")


def time_set(socket, conf):
    """Установка времени на табло"""
    src_addr = 0x0000
    dst_addr = conf.get("DstAddr")
    pid = 0
    cmd = 0x03
    flags = 0x02  # игнорируем pid
    status = 0x80
    DataLen = 6
    date = datetime.now().strftime("%S-%M-%H-%d-%m-%y").split("-")
    data = struct.pack('<BBBBBB', int(date[0]), int(date[1]), int(date[2]), int(date[3]), int(date[4]), int(date[5]))
    packet = make_full_packet(src_addr, dst_addr, pid, cmd, flags, status, DataLen, data)
    socket.sendto(packet, (conf.get("IPDst"), conf.get("PortDst")))

    for _ in range(10):
        try:
            result, approve = check_incoming_packet(socket=socket, sended_packets=None)
            if result[1] == 3:
                if result[3] == 0:
                    logger.debug("Время настроено корректно")
                    print("Время настроено корректно")
                    return
                else:
                    logger.debug(f"При попытке установки времени получена ошибка {code_error[result[3]]}")
                    continue
            else:
                continue
        except BlockingIOError:
            # если в сокете пакетов нет то игнорируем
            time.sleep(0.5)
            continue
    logger.debug("Не удалось настроить время.")
    print("Не удалось настроить время.")


def send_data_for_table_0x05(socket, conf: dict, sended_packets: dict, pid: int, text: str, gate: str,  num_disp: int, data_pack):
    """Отправка информации в текстовые поля табло (0x05)
    Определение номера текстового поля осуществляется в соответствии с его строкой
    без разделения на сегменты "НомерТС и Ворота".
    Вывод текста происходит единой строкой в оба поля через пробелы из расчета 13 символов в строке.
    В случае если нужно вывести номер А111АА111 в позиции 03, то нужно добавить 2 пробела 'A111AA111  03'

    Args:
        socket: Сокет для отправки данных
        conf: Конфигурационный словарь
        sended_packets: Словарь для хранения отправленных пакетов
        pid: ID пакета
        text: Номер строки + Гос.номер
        gate: Номер ворот
        num_disp: Номер дисплея для вывода
    """

    if data_pack is None:
        # Подготовка параметров
        disp = (0x01 << 6) | num_disp
        flags = 0x80 if conf.get("UseMemory") == 1 else 0x00

        # определим нужно ли мигать текстом. Если номер строки 1 и параметр включен, то определяем параметры эффекта.
        if num_disp == 0 and conf.get("FlashNew") == 1:
            effect = 2
            count_repeated = conf.get("CountRepeatedFlash") if str(conf.get("CountRepeatedFlash")).isdigit() else 0
            time_interval = conf.get("TimeIntervalFlash") if str(conf.get("TimeIntervalFlash")).isdigit() else 0
        else:
            # иначе не мигаем
            effect, count_repeated, time_interval = 0, 0, 0

        # Форматирование текста и позиции до CountSymbolString знаков, с учетом что позиция всегда 2-х значная.
        count_symbol_string = conf.get("CountSymbolString")
        if gate.isdigit():
            gate = gate.zfill(2)
        formatted_text = f"{text.ljust(count_symbol_string-2)}{gate}"

        # Определение цвета текста в зависимости от строки
        color = conf.get("FirstStringColorText", 2) if num_disp == 0 else conf.get("ColorText", 1)

        # Логирование
        logger.debug(f"\n display_number: {num_disp} | lpr_number: '{formatted_text}' | Color text: {color}\n")
        if conf.get('Debug', 0) == 1:
            print("-"*71, f"\n display_number: {num_disp} | lpr_number: '{formatted_text}' | Color text: {color}\n", "-"*70)

        # Подготовка данных пакета
        param = struct.pack('<BBBBBBBBB',
                           disp,
                            conf.get("NumberFont", 0),
                            conf.get("AlignText", 0),
                            flags,
                            0,  # Не используется (скорость движения текста)
                            color,
                            effect,
                            count_repeated,
                            time_interval)
        data = param + formatted_text.encode('cp1251')


    else:
        flags = data_pack[2]
        data = data_pack[4]
        formatted_text = text



    # Создание и отправка пакета
    packet = make_full_packet(
        src_addr=0,
        dst_addr=conf["DstAddr"],
        pid=pid,
        cmd=0x05,
        flags=flags,
        status=0x80,
        data_len=len(formatted_text) + 9,
        data=data
    )

    socket.sendto(packet, (conf["IPDst"], conf["PortDst"]))
    sended_packets[pid] = {
        "packet": packet,
        "display": num_disp,
        "text": formatted_text
    }




if __name__ == "__main__":
    # тест вывода информации в первую строку дисплея
    conf: dict = parse_cfg("impuls.cfg")
    sended_packets = {}
    try:
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        server_socket.bind(('0.0.0.0', 0))
        server_socket.setblocking(False)  # Неблокирующий режим

        print("Тест связи с табло")
        test_connection(server_socket, conf)

        print("Тест вывода текста в 1 строку")
        for i in range(conf.get("NumberRows", 8)):
            if i == 0:
                text = '1 aaa1234'
                gate = str(i + 1)
            else:
                text = ''
                gate = ''
            num_disp = i
            pid = i+1
            send_data_for_table_0x05(server_socket, conf, sended_packets, pid, text, gate, num_disp, None)

    except (OSError, OverflowError):
        # Если порт занят, то проверяем кем
        errors_server.find_process_using_port(conf['ServicePort'])
    finally:
        server_socket.close()
