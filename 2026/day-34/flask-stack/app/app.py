import os
import time

import psycopg2
import redis
from flask import Flask

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST", "db")
DB_NAME = os.environ.get("POSTGRES_DB", "appdb")
DB_USER = os.environ.get("POSTGRES_USER", "appuser")
DB_PASS = os.environ.get("POSTGRES_PASSWORD", "apppass")
REDIS_HOST = os.environ.get("REDIS_HOST", "cache")


def wait_for_db(retries=10, delay=2):
    for attempt in range(retries):
        try:
            conn = psycopg2.connect(
                host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASS
            )
            return conn
        except psycopg2.OperationalError:
            time.sleep(delay)
    raise RuntimeError("database not reachable")


@app.route("/")
def index():
    conn = wait_for_db()
    cur = conn.cursor()
    cur.execute("SELECT version();")
    db_version = cur.fetchone()[0]
    cur.close()
    conn.close()

    r = redis.Redis(host=REDIS_HOST, port=6379)
    r.incr("hits")
    hits = r.get("hits").decode()

    return f"Hello World - DB: {db_version.split(',')[0]} | Redis hits: {hits}\n"


@app.route("/health")
def health():
    return "ok\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
