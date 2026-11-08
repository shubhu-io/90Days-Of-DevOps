# slim base: small but already Debian-glibc based, so psycopg2-binary works
FROM python:3.12-slim

# run as non-root for safety
RUN groupadd --system app && useradd --system --gid app app

WORKDIR /app

# install deps first for layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

USER app

EXPOSE 5000

CMD ["python", "app.py"]
