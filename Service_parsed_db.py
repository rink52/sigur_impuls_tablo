import maria
import logging
from textwrap import dedent as format_str

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
    # получение доп. параметров
    script = f"SELECT name, param_idx FROM sideparamtypes WHERE table_id = 0;"

    logger.debug("Запрашиваем значение дополнительных параметров")
    if conf['ParamNum'] not in (1, 2):
        logger.error(f"Параметр 'ParamNum' в файле impuls.cfg имеет некорректное значение.")
        exit(1)
    dbconnect = connect(conf)
    sideparam = {}
    result = dbconnect.query(script)
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
        logger.error(f"Дополнительный параметр хранения позиции в очереди не найден в системе")
        exit(1)

    id_param_gate = [i[1] for i in result if i[0] == f"{conf['NameSideparamGate']}"]
    if id_param_gate:
        sideparam['NameSideparamGate'] = id_param_gate[0]
    else:
        logger.error(f"Дополнительный параметр хранения номера ворот не найден в системе")
        exit(1)

    return sideparam

# получение данных об очереди
def queue_script(conf, sideparam):
    # Если в конфиге указано "ParamNum" = 1, это значит использование `ФИО` в качестве номера (только для личного и служебного транспорта)
    if conf["ParamNum"] == 1:
        queue_script = format_str(f"""
        SELECT 
		    MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamPosition']} THEN spv.VALUE END) AS position,
		    MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamGate']} THEN spv.VALUE END) AS gate,
		    p.NAME AS lprnumber 
        FROM personal p
        JOIN sideparamvalues spv ON p.id = spv.OBJ_ID
        JOIN sideparamtypes spt ON spv.PARAM_IDX = spt.PARAM_IDX
		WHERE spv.TABLE_ID = 0 
		    AND p.`TYPE` = 'EMP'
		    AND (p.`EMP_TYPE` = 'AUTO_PERSONAL' OR p.EMP_TYPE = 'AUTO_OFFICIAL')
            AND spv.VALUE != ''
        GROUP BY p.id
        HAVING MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamPosition']} THEN spv.VALUE END) IS NOT NULL
            AND MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamGate']} THEN spv.VALUE END) IS NOT NULL
            AND p.NAME IS NOT NULL
        ORDER BY position;
        """)

    # Если в конфиге указано "ParamNum" = 2, это значит гос номер хранится в доп. параметре sideparam["NameSideparamNum"].
    elif conf["ParamNum"] == 2:
        queue_script = format_str(f"""
            SELECT 
                MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamPosition']} THEN spv.VALUE END) AS position,
                MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamGate']} THEN spv.VALUE END) AS gate,
                MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamNum']} THEN spv.VALUE END) AS lprnumber
            FROM personal p
            JOIN sideparamvalues spv ON p.id = spv.OBJ_ID
            JOIN sideparamtypes spt ON spv.PARAM_IDX = spt.PARAM_IDX
            WHERE spv.TABLE_ID = 0 
              AND p.EMP_TYPE = 'EMP'
              AND spv.VALUE != ''
            GROUP BY p.id
            HAVING 
                MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamPosition']} THEN spv.VALUE END) IS NOT NULL
                AND MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamGate']} THEN spv.VALUE END) IS NOT NULL
                AND MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamNum']} THEN spv.VALUE END) IS NOT NULL
            ORDER BY position; 
        """)

    return queue_script.strip().replace("\n", " ")

def queue(conf, sideparam):
    dbconnect = connect(conf)
    response = {}
    script = queue_script(conf, sideparam)
    result = dbconnect.query(script)
    print(f"Результат: {result}")
    logger.debug(f"result_request_DB: {result}")
    if result:
        response = {position: [lprnumber, gate] for position, gate, lprnumber in result}

    return response


