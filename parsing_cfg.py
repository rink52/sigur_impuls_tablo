from os import path, remove, rename, makedirs
from datetime import datetime
from textwrap import dedent as format_str

filename = "impuls.cfg"
if path.exists("logs") == False:
    makedirs("logs")


def parse_cfg():
    try:
        conf = {}
        with open(filename, "r", encoding="utf-8") as f:
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
                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - main - ERROR - Ошибка чтения файла конфигурации.\n")
            pass
        print(f"Ошибка чтения файла конфигурации.")
        create_config()


# def check_cfg(conf):
#     param = ["IPDst",
#              "PortDst",
#              "DstAddr",
#              "ServicePort",
#              "IPBD",
#              "PortDB",
#              "LoginDB",
#              "PasswordDB",
#              "Period",
#              "NumberRows",
#              "TwoSegmentString",
#              "AlignText",
#              "TimeSync",
#              "Brightness",
#              "ColorText",
#              "FirstStringColorText",
#              "UseMemory",
#              "FlashNew",
#              "ParamNum",
#              "NameSideparamNum",
#              "NameSideparamPosition",
#              "LenLog"]
#     correct = True
#     param_not_found = ""
#     for i in param:
#         if i in conf:
#             continue
#         else:
#             correct = False
#             param_not_found = param_not_found + "," + str(i)
#     if correct is False:
#         logger.error(f"В конфигурационном файле отсутствуют необходимые параметры: {param_not_found}")
#         create_config()
#         return False
#     else:
#         return True

def check_cfg(conf):
    param = {"IPDst": ["str"],
             "PortDst": ["int"],
             "DstAddr": ["int"],
             "ServicePort": ["int"],
             "IPBD": ["str"],
             "PortDB": ["int"],
             "LoginDB": ["int", "str"],
             "PasswordDB": ["int", "str"],
             "Period": ["int"],
             "NumberRows": ["int"],
             "TwoSegmentString": ["int"],
             "AlignText": ["int"],
             "TimeSync": ["int"],
             "Brightness": ["int"],
             "ColorText": ["int"],
             "FirstStringColorText": ["int"],
             "UseMemory": ["int"],
             "FlashNew": ["int"],
             "ParamNum": ["int"],
             "NameSideparamNum": ["int", "str"],
             "NameSideparamPosition": ["int", "str"],
             "LenLog": ["int"]}
    correct = True
    param_not_found = ""
    for i in param.keys():
        if i in conf:
            if type(conf.get(i)).__name__ in param.get(i):
                continue
            else:
                correct = False
                param_not_found = param_not_found + ", '" + str(i) + "' - Param type error"
        else:
            correct = False
            param_not_found = param_not_found + ", '" + str(i) + "' - Param not found"
    if correct is False:
        print(f"В конфигурационном файле отсутствуют необходимые параметры{param_not_found}")
        with open("logs/app.log", 'a', encoding='utf-8') as f:
            f.write(
                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - parsing_cfg - ERROR - В конфигурационном файле отсутствуют необходимые параметры{param_not_found}\n")
            pass
        create_config()
        return False
    else:
        return True


def create_config():
    content = format_str("""
    # IP адрес табло
    IPDst=0.0.0.0
    # Порт табло
    PortDst=0
    # ID табло
    DstAddr=1
    # Порт сервиса
    ServicePort=12344
    # IP адрес БД Sigur
    IPBD=127.0.0.1
    # Порт БД Sigur
    PortDB=3305
    # Логин доступа к БД Sigur
    LoginDB=root
    # Пароль доступа к БД Sigur
    PasswordDB=password
    # Период обновления информации на табло (число в секундах)
    Period=300
    # Количество мест в очереди для отображения. Равно количеству строк на табло (число, например 8)
    NumberRows=8
    # Строка табло разделена на 2 сегмента (0 - нет, 1 - да)
    TwoSegmentString=1
    # Выравнивание текста (0 -влево, 1- вправо, 2 — по центру)
    AlignText=0
    # Синхронизация времени (0 — НЕ требуется, 1 — требуется)
    TimeSync=0
    # Яркость табло (от 1 до 10, где 1 не ярко, 10 очень ярко)
    Brightness=5
    # Цвет отображаемого текста (1- красный, 2 — зеленый, 3 — синий)
    ColorText=1
    # Цвет отображаемого текста в 1 строке (1- красный, 2 — зеленый, 3 — синий)
    FirstStringColorText=1
    # Сохранять ли отображаемые данные в энергонезависимой памяти (0 — нет, 1 — да).
    UseMemory=1
    # Требуется ли эффект мигания новой информациией на табло в течении 10 секунд после наступления периода синхронизации (0 — нет, 1 — да).
    FlashNew=0
    # Место хранения гос.номера авто (1-ФИО, 2-Доп.параметр)
    ParamNum=2
    # Название дополнительного параметра, где хранятся данные о гос.номере авто
    NameSideparamNum=Гос. номер
    # Название дополнительного параметра, где хранятся данные о порядковом номере очереди
    NameSideparamPosition=Позиция в очереди
    # Максимальный размер файла лога (Mb)
    LenLog=100""").strip()

    if path.exists(filename):
        try:
            with open(filename, 'a', encoding='utf-8'):
                pass
        except IOError:
            with open("logs/app.log", 'a', encoding='utf-8') as f:
                f.write(
                    f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - parsing_cfg - ERROR - Файл {filename} используется в другом приложении. Закройте его и поторите попытку.\n")
            print(f"Файл {filename} используется в другом приложении. Закройте его и поторите попытку")
            exit(1)

        if path.exists(f"{filename}.old"):
            remove(f"{filename}.old")
            rename(filename, f"{filename}.old")

    # Создание и запись в файл
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(content)
        print(f"Файл {filename} пересоздан. Внесите корректные настройки")
    with open("logs/app.log", 'a', encoding='utf-8') as f:
        f.write(
            f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - parsing_cfg - ERROR - Файл {filename} успеншно пересоздан. Внесите корректные настройки.\n")
    exit(1)


if __name__ == '__main__':
    conf = parse_cfg()
    print(conf)
