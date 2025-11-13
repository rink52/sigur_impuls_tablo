import ipaddress
import traceback
import os.path
from os import path, makedirs
from datetime import datetime

filename = "impuls.cfg"
if path.exists('logs') and not path.isdir('logs'):
    try:
        os.remove('logs')
    except OSError as e:
        error_msg = f"Не удалось удалить файл 'logs' \n{e}"
        # Логируем в отдельный файл, т.к. logs/ ещё не создан
        with open("startup_error.log", "a", encoding="utf-8") as f:
            f.write(f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - parsing_cfg - INIT - {error_msg}\n")
        exit("Ошибка создания папки 'logs'.")

# Теперь создаём директорию (даже если она уже есть — exist_ok=True гарантирует успех)
makedirs('logs', exist_ok=True)

def parse_cfg(config_path):
    try:
        conf = {}
        with open(config_path, "r", encoding="utf-8") as f:
            while True:
                line = f.readline()
                if not line:
                    break
                if line == "\n":
                    continue
                if "#" not in line:
                    line = line.strip().split("=")
                    line[1] = int(line[1]) if str(line[1]).isdigit() else line[1]
                    conf[line[0]] = line[1]
        check_cfg(conf)
        return conf
    except Exception as e:
        print(e)
        with open("logs/app.log", 'a', encoding='utf-8') as f:
            f.write(
                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - main - ERROR - Ошибка чтения файла конфигурации.\n"
                f"{traceback.format_exc()}\n")
            pass
        print(f"Ошибка чтения файла конфигурации.")


def check_cfg(conf):
    param = {"IPDst": ["str"],
             "PortDst": ["int"],
             "DstAddr": ["int"],
             "ServicePort": ["int"],
             "IPBD": ["str"],
             "PortDB": ["int"],
             "LoginDB": ["int", "str"],
             "PasswordDB": ["int", "str"],
             "Brightness": ["int"],
             "TimeSync": ["int"],
             "Period": ["int"],
             "ParamNum": ["int"],
             "NameSideparamNum": ["int", "str"],
             "NameSideparamPosition": ["int", "str"],
             "NameSideparamGate": ["int", "str"],
             "ColorText": ["int"],
             "FirstStringColorText": ["int"],
             "NumberFont": ["int"],
             "AlignText": ["int"],
             "NumberRows": ["int"],
             "CountSymbolString": ["int"],
             "UseMemory": ["int"],
             "FlashNew": ["int"],
             "CountRepeatedFlash": ["int"],
             "TimeIntervalFlash": ["int"],
             "LenLog": ["int"]}
    correct = True
    param_not_found = ""
    for i in param.keys():
        if i in conf:
            if type(conf.get(i)).__name__ in param.get(i):
                if i in ("IPDst", "IPBD"):
                    if conf.get(i) == "":
                        with open("logs/app.log", 'a', encoding='utf-8') as f:
                            f.write(
                                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - parsing_cfg - ERROR - IP адрес '{i}' не указан в файле конфигурации impuls.cfg.\n")
                        exit(1)
                    try:
                        ipaddress.ip_address(conf.get(i))
                        continue
                    except ValueError:
                        with open("logs/app.log", 'a', encoding='utf-8') as f:
                            f.write(
                                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - parsing_cfg - ERROR - IP адрес '{i}': '{conf.get(i)}' указан неверно в файле конфигурации impuls.cfg.\n")
                        exit(1)
                elif i in ("PortDst", "ServicePort", "PortDB"):
                    port = conf.get(i)
                    if port < 1 or port > 65535:
                        with open("logs/app.log", 'a', encoding='utf-8') as f:
                            f.write(
                                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - parsing_cfg - ERROR - Порт '{i}' указанный в impuls.cfg: '{port}' не корректный. Порт может быть в диапазоне [1-65535]\n")
                        exit(1)
                else:
                    continue
            else:
                correct = False
                param_not_found = param_not_found + ", '" + str(i) + "' - Param type error"
        else:
            correct = False
            param_not_found = param_not_found + ", '" + str(i) + "' - Param not found"
    if correct is False:
        print(f"В конфигурационном файле отсутствуют необходимые параметры {param_not_found}")
        with open("logs/app.log", 'a', encoding='utf-8') as f:
            f.write(
                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - parsing_cfg - ERROR - В конфигурационном файле отсутствуют необходимые параметры{param_not_found}\n")
            pass
    return correct


if __name__ == '__main__':
    conf = parse_cfg(os.path.abspath("impuls.cfg"))
    print(conf)

# __________ create_config ____________
# # IP адрес табло
# IPDst=127.0.0.1
# # Порт табло
# PortDst=5000
# # ID табло
# DstAddr=1
# # Порт сервиса
# ServicePort=12344
# # IP адрес БД Sigur
# IPBD=127.0.0.1
# # Порт БД Sigur
# PortDB=3305
# # Логин доступа к БД Sigur
# LoginDB=root
# # Пароль доступа к БД Sigur
# PasswordDB=
# # Яркость табло (от 1 до 10, где 1 не ярко, 10 очень ярко)
# Brightness=10
# # Синхронизация времени (0 — НЕ требуется, 1 — требуется)
# TimeSync=0
# # Период обновления информации на табло (число в секундах)
# Period=300
# # Место хранения гос.номера авто (1-ФИО, 2-Доп.параметр)
# ParamNum=2
# # Название дополнительного параметра, где хранятся данные о гос.номере авто
# NameSideparamNum=Гос. номер
# # Название дополнительного параметра, где хранятся данные о порядковом номере очереди
# NameSideparamPosition=Позиция в очереди
# # Название дополнительного параметра, где хранятся данные о номере ворот для проезда
# NameSideparamGate=Ворота
# # Цвет отображаемого текста (1- красный, 2 — зеленый, 3 — синий)
# ColorText=1
# # Цвет отображаемого текста в 1 строке (1- красный, 2 — зеленый, 3 — синий)
# FirstStringColorText=1
# # Номер шрифта
# NumberFont=0
# # Выравнивание текста (0 -влево, 1- вправо, 2 — по центру)
# AlignText=0
# # Количество мест в очереди для отображения. Равно количеству строк на табло (число, например 8)
# NumberRows=8
# # Количество символов в строке
# CountSymbolString=13
# # Сохранять ли отображаемые данные в энергонезависимой памяти (0 — нет, 1 — да).
# UseMemory=0
# # Требуется ли эффект мигания информациией на табло в течении 10 секунд после наступления периода синхронизации (0 — нет, 1 — да).
# FlashNew=0
# # количество повторений мигания
# CountRepeatedFlash=60
# # интервал повторений мигания (время отображения и паузы в милисекундах)
# TimeIntervalFlash=100
# # Максимальный размер файла лога (Mb)
# LenLog=100
# Debug=0