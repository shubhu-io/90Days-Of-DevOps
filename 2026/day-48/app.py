from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(message="Hello from the capstone app v1.1!"), 200


@app.get("/health")
def health():
    return jsonify(status="ok"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
