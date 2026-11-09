# Docker Cheat Sheet

Job-ready one-liners, grouped by category. Replace `<>` placeholders with your values.
Verify any flag with `docker <cmd> --help` — the CLI is ground truth.

## Container Commands

| Command | What it does |
| --- | --- |
| `docker run -it ubuntu bash` | Start a container interactively with a shell |
| `docker run -d --name web -p 8080:80 nginx:1.27` | Start detached, named, publish host 8080 to container 80 |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers, including stopped |
| `docker ps --filter label=com.example.project=flask-stack` | List containers of one project (labels from compose) |
| `docker stop web` | Gracefully stop a container (SIGTERM, then SIGKILL after timeout) |
| `docker start web` / `docker restart web` | Start a stopped container / restart it |
| `docker kill web` | Force-kill (SIGKILL) — tests `restart:` policies |
| `docker rm web` | Remove a stopped container (`-f` forces a running one) |
| `docker exec -it web bash` | Open a shell in a running container (use `sh` on alpine) |
| `docker exec web env` | Print container environment (debug env/config) |
| `docker exec web id` | Check which user the container runs as (non-root check) |
| `docker logs -f --tail 100 web` | Follow the last 100 log lines |
| `docker logs web 2>&1 \| grep -i error` | Search logs for errors |
| `docker inspect web` | Full JSON details: IP, mounts, env, state |
| `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web` | Just the container IP |
| `docker stats` | Live CPU, memory, and network usage per container |
| `docker top web` | Processes running inside the container |
| `docker cp file.txt web:/tmp/` | Copy files between host and container |
| `docker rename web web-v2` | Rename a container |
| `docker update --restart unless-stopped web` | Change restart policy on an existing container |

Example session:

```bash
docker run -d --name web -p 8080:80 nginx:1.27
docker ps
docker exec -it web sh
docker logs --tail 20 web
docker stop web && docker rm web
```

## Image Commands

| Command | What it does |
| --- | --- |
| `docker build -t myapp:1.0 .` | Build `./Dockerfile` and tag the result |
| `docker build -f Dockerfile.multi -t go-hello:multi .` | Build with a non-default Dockerfile |
| `docker build --no-cache -t myapp:1.0 .` | Ignore cache (clean measurement / force fresh) |
| `docker pull nginx:1.27` | Download an image (pin real tags, avoid `latest`) |
| `docker images` | List local images |
| `docker images --digests` | List with content digests (pin-ability check) |
| `docker tag myapp:1.0 user/myapp:1.0` | Add another name/tag to an existing image |
| `docker push user/myapp:1.0` | Push to a registry (requires `docker login` first) |
| `docker login` | Authenticate to Docker Hub (use access token with 2FA) |
| `docker rmi myapp:1.0` | Delete a local image |
| `docker history myapp:1.0` | Show every layer and the command that created it |
| `docker save myapp:1.0 -o myapp.tar` | Export an image to a tar file (`docker load -i` to import) |
| `docker scout quickview myapp:1.0` | Vulnerability/size overview (Desktop feature) |

```bash
docker build -t my-ubuntu:v1 .
docker images my-ubuntu:v1
docker tag my-ubuntu:v1 myuser/my-ubuntu:1.0.0
docker push myuser/my-ubuntu:1.0.0
```

## Volume Commands

| Command | What it does |
| --- | --- |
| `docker volume create pgdata` | Create a named volume |
| `docker volume ls` | List volumes |
| `docker volume inspect pgdata` | Show the host mountpoint and metadata |
| `docker volume rm pgdata` | Delete a volume (fails if a container uses it) |
| `docker volume prune` | Delete ALL unused volumes — destructive, confirm first |
| `docker run -v pgdata:/var/lib/postgresql/data postgres:16` | Mount a named volume (data survives container removal) |
| `docker run -v "$PWD/html:/usr/share/nginx/html" nginx:1.27` | Bind mount a host directory |
| `docker run -v "$PWD/html:/usr/share/nginx/html:ro" nginx:1.27` | Bind mount read-only inside the container |
| `docker run --mount type=bind,src="$PWD/html",dst=/usr/share/nginx/html,readonly nginx:1.27` | Explicit `--mount` syntax, read-only |

Volume vs bind mount rule: databases → named volumes; live dev code/config → bind mounts.

```bash
docker volume create pgdata
docker run -d --name pg -e POSTGRES_PASSWORD=secret -v pgdata:/var/lib/postgresql/data postgres:16
docker volume inspect pgdata
docker rm -f pg && docker volume rm pgdata
```

## Network Commands

| Command | What it does |
| --- | --- |
| `docker network create appnet` | Create a user-defined bridge network (gets embedded DNS) |
| `docker network ls` | List networks |
| `docker network inspect appnet` | Show subnet and connected containers |
| `docker network connect appnet web` | Attach an existing container to a network |
| `docker network disconnect appnet web` | Detach a container from a network |
| `docker run --network appnet ...` | Start a container directly on that network |
| `docker network rm appnet` | Delete an unused network |
| `docker network prune` | Delete all unused networks |

DNS rule: user-defined bridge → container names resolve; default `bridge` → IPs only.

```bash
docker network create my-app-net
docker run -d --name a1 --network my-app-net alpine sleep 3600
docker run -d --name a2 --network my-app-net alpine sleep 3600
docker exec a1 ping -c2 a2        # works by name
docker exec a1 getent hosts a2
docker rm -f a1 a2 && docker network rm my-app-net
```

## Compose Commands

| Command | What it does |
| --- | --- |
| `docker compose config` | Render final YAML with env vars substituted (validate first) |
| `docker compose up -d --build` | Build images and start the stack in the background |
| `docker compose up` | Start in foreground (Ctrl+C stops) |
| `docker compose ps` | Status of the stack's containers |
| `docker compose logs -f` | Follow logs of all services |
| `docker compose logs -f app` | Follow logs for one service |
| `docker compose logs --tail 50 db` | Last 50 lines of one service |
| `docker compose exec app bash` | Shell into a running service |
| `docker compose exec db env \| grep POSTGRES` | Verify env reached the container |
| `docker compose build` / `docker compose pull` | Build / pull images without starting |
| `docker compose stop` / `docker compose start` | Stop (keep) / restart the stack |
| `docker compose restart app` | Restart one service |
| `docker compose up -d --scale web=3` | Scale a service (breaks with fixed `ports:`) |
| `docker compose kill db` | SIGKILL a service (tests `restart:`) |
| `docker compose down` | Stop and remove containers and networks (volumes kept) |
| `docker compose down -v` | Same, and also delete named volumes (data wiped) |
| `docker compose down --rmi all` | Also remove stack images |

Lifecycle memory aid: `stop` keeps everything · `down` removes containers+network · `down -v` also wipes data.

```bash
docker compose config
docker compose up -d --build
docker compose ps
docker compose logs -f
docker compose down
```

## Cleanup Commands

| Command | What it does |
| --- | --- |
| `docker system df` | Disk used by images, containers, volumes, build cache |
| `docker system df -v` | Same, broken down per object |
| `docker system prune` | Remove stopped containers, unused networks, dangling images, cache |
| `docker system prune -a --volumes` | Also remove unused images and volumes (destructive) |
| `docker container prune` | Remove all stopped containers |
| `docker image prune -a` | Remove all images not used by a container |
| `docker volume prune` | Remove all unused volumes (data loss — confirm) |
| `docker network prune` | Remove all unused networks |
| `docker builder prune` | Clear the build cache |
| `docker builder prune -a` | Clear all build cache including in-use layers |

Safe order when disk is full: `df` → `container prune` → `image prune` → `builder prune` → volumes only if sure.

```bash
docker system df
docker container prune
docker image prune
docker builder prune
```

## Dockerfile Instructions

| Instruction | Purpose |
| --- | --- |
| `FROM` | Base image for a build stage; first instruction in a stage (`FROM golang:1.23 AS builder`) |
| `RUN` | Execute a command at build time; creates a layer (combine + clean caches in one RUN) |
| `COPY` | Copy files from the build context (`COPY --from=builder` copies from another stage; `--chown=` sets owner) |
| `ADD` | Like COPY, but also auto-extracts local tars and downloads URLs (prefer COPY) |
| `WORKDIR` | Set (and create) the working directory for later instructions and the container |
| `ENV` | Environment variable available at build time and in the running container |
| `ARG` | Build-time variable; not present in the running container |
| `EXPOSE` | Documents the port the app listens on; does not publish it (`-p` does) |
| `USER` | Switch to a non-root user for the rest of the build and at runtime |
| `VOLUME` | Declare a mount point for external or anonymous volumes |
| `HEALTHCHECK` | Command Docker runs periodically to mark the container healthy/unhealthy |
| `LABEL` | Metadata (`com.example.project=…`) for filtering/organization |
| `CMD` | Default command and args; overridden by `docker run <image> <cmd>` |
| `ENTRYPOINT` | Fixed executable; `CMD` values become its default arguments |

Minimal production template:

```dockerfile
FROM python:3.12-slim
RUN groupadd --system app && useradd --system --gid app app
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
USER app
EXPOSE 5000
CMD ["python", "app.py"]
```

## Healthcheck & Depends Primer

```yaml
services:
  db:
    image: postgres:16
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 5s
      timeout: 3s
      retries: 10
  web:
    build: .
    depends_on:
      db:
        condition: service_healthy
```

Plain `depends_on: [db]` waits for start only; `condition: service_healthy` waits for the probe.

## Restart Policy Picker

| Policy | Use when |
|---|---|
| `no` | One-shots, debugging |
| `on-failure` | Workers where exit 0 means done |
| `always` | Databases, must-run services |
| `unless-stopped` | App tiers that survive reboots but respect manual stops |

## Compose `.env` Patterns

```bash
# .env (never commit — add to .gitignore)
POSTGRES_PASSWORD=notespass
HOST_PORT=8083
APP_VERSION=dev
```

```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}        # plain substitution
  web:
    ports:
      - "${HOST_PORT}:80"                            # substitution in ports
    environment:
      APP_VERSION: ${APP_VERSION:-dev}               # default when unset
      REQUIRED_KEY: ${REQUIRED_KEY:?set me in .env}  # fail fast when unset
```

```bash
docker compose config        # verify substitution before up
docker compose exec web env | grep APP_VERSION
```

## Tagging Strategy

```bash
docker tag myapp:test myuser/myapp:1.0.0   # immutable release
docker tag myapp:test myuser/myapp:latest  # movable pointer (dev only)
docker push myuser/myapp:1.0.0
docker pull myuser/myapp:1.0.0             # exact, reproducible
docker images --digests | grep myapp       # pin-ability check
```

Rule: deploys pin `:1.0.0` or digests; `:latest` never reaches production.

## Port Mapping Refresher

```bash
docker run -d --name mysite -p 8080:80 my-website:v1   # HOST:CONTAINER
curl http://localhost:8080
docker compose ps     # check the PORTS column when curl fails
```

`EXPOSE` documents; `-p` publishes. `bind: address already in use` = host port taken.

## Five Rules That Prevent Pain

- Pin real base image tags (`nginx:1.27`), never `latest`, for reproducible builds.
- Order Dockerfile instructions from least to most frequently changed for better cache hits.
- Data you care about goes in a named volume or bind mount, never the container writable layer.
- One process per container; use multi-stage builds to keep the final image small.
- `docker compose down -v` deletes your volumes — know when you actually want that.

## Ten-Second Diagnosis

```bash
docker ps -a                          # what exists?
docker logs --tail 50 <name>          # why did it die?
docker inspect <name> | grep -iE 'exit|error|mount|ipaddress'  # state, mounts, IP
docker exec <name> env | sort          # config actually applied?
docker system df                      # disk pressure suspect?
```
