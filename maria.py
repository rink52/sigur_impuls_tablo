import logging
import mariadb

logger = logging.getLogger('maria')

class Maria:
    def __init__(self, host: str="127.0.0.1", port: int=3305, user: str="root", password: str="", db: str="tc-db-main"):
        try:
            self.conn = mariadb.connect(
                user=user,
                password=password,
                host=host,
                port=port,
                database=db
            )

            # Get Cursor
            self.cursor = self.conn.cursor()
            # print('Maria connected\n')

        except mariadb.Error as e:
            print(f"Ошибка соединения с MariaDB: {e}")
            logger.warning(f"Ошибка соединения с MariaDB: {e}")
            raise


    def __del__(self):
        if self.conn:
            self.conn.close()

    def query(self, query: str):
        try:
            self.cursor.execute(query)
            response = self.cursor.fetchall()
            logger.debug(f"Query: {query}")
            logger.debug(f"Response: {response}")
            return response
        except Exception as e:
            logger.error(f"Error executing query: {e}")
            print(f"Ошибка выполнения запроса: {e}")
            raise

