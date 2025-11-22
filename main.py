import random

import mysql.connector
# from pydantic import BaseModel, Field, field_validator


class DB:
    def __init__(self):
        self.mydb = mysql.connector.connect(
            host="localhost", port=3306, user="root", password="example"
        )

    def cursor(self):
        return self.mydb.cursor()

    def commit(self):
        self.mydb.commit()

    def close(self):
        self.mydb.close()


def apply_migration(db: DB):
    cursor = db.cursor()

    # execute schema.sql
    with open("schema.sql", "r") as f:
        sql = f.read()
        statements = [s.strip() for s in sql.split(";") if s.strip()]
        for statement in statements:
            cursor.execute(statement)

    db.commit()


def populate_data(db: DB):
    cursor = db.cursor()

    # execute schema.sql
    with open("dataset.sql", "r") as f:
        sql = f.read()
        statements = [s.strip() for s in sql.split(";") if s.strip()]
        for statement in statements:
            cursor.execute(statement)

    db.commit()

def main():
    db = DB()

    apply_migration(db)

    populate_data(db)

    db.close()


if __name__ == "__main__":
    main()
