# Developer Documentation — Inception

## Setting Up the Environment From Scratch

### Prerequisites
- A Linux Virtual Machine (Debian recommended)
- Docker Engine and Docker Compose installed
- `make` installed

```bash
sudo apt update
sudo apt install -y docker.io docker-compose make git curl
sudo usermod -aG docker $USER
newgrp docker
```

### 1. Clone the repository
```bash
git clone <your_repo_url> inception
cd inception
```

### 2. Create the secrets files
The `secrets/` directory is not committed to Git. Create it manually:
```bash
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
printf "your_wp_admin_password\nyour_wp_user_password" > secrets/credentials.txt
```

### 3. Create the .env file
The `.env` file is not committed to Git. Create it at `srcs/.env`:
```dotenv
DOMAIN_NAME=mnazar.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_TITLE=Inception
WP_ADMIN_USER=wpmaster
WP_ADMIN_EMAIL=mnazar@student.42abudhabi.ae
WP_USER=wpeditor
WP_USER_EMAIL=editor@student.42abudhabi.ae
```

### 4. Configure the domain
```bash
echo "127.0.0.1 mnazar.42.fr" | sudo tee -a /etc/hosts
```

## Building and Launching the Project

The Makefile wraps all Docker Compose commands. To build images and start everything:
```bash
make
```

This runs:
```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build
```

It creates the data directories, builds the three images from their Dockerfiles, and
starts the containers in detached mode.

## Managing Containers and Volumes

| Command | Description |
|---------|-------------|
| `make` / `make all` | Build and start all containers |
| `make down` | Stop and remove containers |
| `make stop` | Stop containers without removing |
| `make start` | Start stopped containers |
| `make restart` | Restart all containers |
| `make clean` | Stop containers and remove Docker artifacts |
| `make fclean` | Full cleanup including volume data on host |
| `make re` | Full rebuild from scratch |
| `make logs` | Follow all container logs |
| `make ps` | Show container status |

**Enter a running container:**
```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

**Inspect volumes and network:**
```bash
docker volume ls
docker network inspect srcs_inception
```

## Where Project Data Is Stored and How It Persists

The project uses two Docker named volumes, both backed by directories on the host
machine at `/home/mnazar/data/`:

| Volume | Host location | Mounted in container |
|--------|---------------|----------------------|
| `mariadb` | `/home/mnazar/data/mariadb` | `/var/lib/mysql` |
| `wordpress` | `/home/mnazar/data/wordpress` | `/var/www/html` |

Because data is stored on the host, it persists even when containers are stopped or
removed. Running `make down` or `make clean` does not delete this data — the next
`make` will pick up the existing data.

To completely wipe all persistent data:
```bash
make fclean
```

This removes everything in `/home/mnazar/data/`, forcing a fresh database and
WordPress install on the next build.