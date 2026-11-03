FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl python3 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app.py .

EXPOSE 8000

CMD ["python3", "-m", "http.server", "8000"]
