import maria
import script
import logging

logger = logging.getLogger(__name__)

def connect(conf):
    dbconnect = maria.Maria(
        host=conf["IPBD"],
        port=conf["PortDB"],
        user=str(conf["LoginDB"]),
        password=str(conf["PasswordDB"]),
        db="tc-db-main"
        )
    return dbconnect

def sideparam(conf):
    logger.debug("Запрашиваем значение дополнительных параметров")
    if conf['ParamNum'] not in (1, 2):
        logger.error(f"Параметр 'ParamNum' в файле impuls.cfg имеет некорректное значение.")
        exit(1)
    dbconnect = connect(conf)
    sideparam = {}
    result = dbconnect.query(script.all_sideparam)
    id_param_number_avto = [i[1] for i in result if i[0] == f"{conf['NameSideparamNum']}"]

    if id_param_number_avto:
        sideparam['NameSideparamNum'] = id_param_number_avto[0]
    else:
        sideparam['NameSideparamNum'] = "NULL"

    if conf['ParamNum'] == 2 and sideparam['NameSideparamNum'] == "NULL":
        print(f"Требуемый дополнительный параметр хранения гос.номера не найден в системе")
        logger.error(f"Требуемый дополнительный параметр, для хранения гос.номера, не найден в системе")
        logger.error(f"Cоздайте в системе параметр с именем '{conf['NameSideparamNum']}' или отключите его использование в файле impuls.cfg")
        exit(1)

    id_param_count = [i[1] for i in result if i[0] == f"{conf['NameSideparamPosition']}"]
    if id_param_count:
        sideparam['NameSideparamPosition'] = id_param_count[0]
    else:
        sideparam['NameSideparamPosition'] = "NULL"
    return sideparam

def queue(conf, sideparam):
    dbconnect = connect(conf)
    response = {}
    queue_script = script.queue_script(conf, sideparam)
    result = dbconnect.query(queue_script)
    print(result)
    if result:
        response = {key: value for key, value in result if value is not None}

    return response

