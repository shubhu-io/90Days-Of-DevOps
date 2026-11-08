import os

import psycopg2
from flask import Flask, jsonify, request

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST", "db")
DB_NAME = os.environ.get("POSTGRES_DB", "notes")
DB_USER = os.environ.get("POSTGRES_USER", "notesuser")
DB_PASS = os.environ.get("POSTGRES_PASSWORD", "notespass")


def get_conn():
    return psycopg2.connect(host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASS)


def init_db():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        "CREATE TABLE IF NOT EXISTS notes (id SERIAL PRIMARY KEY, title TEXT NOT NULL, body TEXT);"
    )
    conn.commit()
    cur.close()
    conn.close()


@app.route("/")
def index():
    return "Notes app running. POST /notes with {title, body}, GET /notes to list.\n"


@app.route("/notes", methods=["GET"])
def list_notes():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT id, title, body FROM notes ORDER BY id;")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify([{"id": r[0], "title": r[1], "body": r[2]} for r in rows])


@app.route("/notes", methods=["POST"])
def add_note():
    data = request.get_json(force=True)
    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO notes (title, body) VALUES (%s, %s) RETURNING id;",
        (data["title"], data.get("body", "")),
    )
    new_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"id": new_id}), 201


@app.route("/health")
def health():
    return "ok\n"


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
