# Notes App

A tiny Flask + Postgres notes API, fully Dockerized with Docker Compose.

## What it does
- `GET /` - service info
- `GET /notes` - list all notes as JSON
- `POST /notes` - create a note, JSON body `{"title": "...", "body": "..."}`
- `GET /health` - health endpoint

## How to run
```bash
docker compose up -d --build
curl http://localhost:5000/
curl -X POST http://localhost:5000/notes \
  -H "Content-Type: application/json" \
  -d '{"title": "first", "body": "hello"}'
curl http://localhost:5000/notes
docker compose down
```

## Environment variables (.env)
- `POSTGRES_DB` - database name
- `POSTGRES_USER` - database user
- `POSTGRES_PASSWORD` - database password

The app also reads `DB_HOST` (defaults to the `db` compose service).

## Project layout
- `app.py` - Flask application
- `requirements.txt` - Python dependencies
- `Dockerfile` - multi-stage-optional app image (slim base, non-root user)
- `docker-compose.yml` - app + Postgres with healthcheck, named volume, custom network
- `.env` - DB credentials (do not commit)
- `.dockerignore` - keeps the build context small
