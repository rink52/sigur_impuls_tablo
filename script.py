from textwrap import dedent as format_str

# получение доп. параметров
all_sideparam = f"SELECT name, param_idx FROM sideparamtypes WHERE table_id = 0;"

# получение данных об очереди
def queue_script(conf, sideparam):
    # Если в конфиге указано "ParamNum" = 1, это значит использование `ФИО` в качестве номера (только для личного и служебного транспорта)
    if conf["ParamNum"] == 1:
        queue_script = format_str(f"""
        SELECT s.VALUE AS position, p.NAME AS lprnumber 
        FROM personal p
        JOIN sideparamvalues s ON s.OBJ_ID = p.ID
        WHERE s.PARAM_IDX = {sideparam['NameSideparamPosition']}
        AND p.`TYPE` = 'EMP'
        AND s.VALUE != ''
        AND (p.`EMP_TYPE` = 'AUTO_PERSONAL' OR p.EMP_TYPE = 'AUTO_OFFICIAL')
        ORDER BY VALUE;
        """)

    # Если в конфиге указано "ParamNum" = 2, это значит гос номер хранится в доп. параметре sideparam["NameSideparamNum"].
    elif conf["ParamNum"] == 2:
        queue_script = format_str(f"""
        SELECT 
        MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamPosition']} THEN spv.VALUE END) AS position,
        MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamNum']} THEN spv.VALUE END) AS lprnumber
        FROM personal p
        JOIN sideparamvalues spv ON p.id = spv.OBJ_ID
        JOIN sideparamtypes spt ON spv.PARAM_IDX = spt.PARAM_IDX
        WHERE spv.TABLE_ID = 0 AND p.EMP_TYPE= 'EMP'
        GROUP BY p.id
        HAVING MAX(CASE WHEN spv.PARAM_IDX = {sideparam['NameSideparamPosition']} THEN spv.VALUE END) IS NOT NULL
        ORDER BY position;
        """)

    return queue_script.strip().replace("\n", " ")



