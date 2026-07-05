*This project has been created as part of the 42 curriculum by mnazar.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to
set up a small infrastructure composed of multiple Docker services running in a
virtual machine. The stack includes NGINX (reverse proxy with TLS), WordPress with
PHP-FPM, and MariaDB, all orchestrated with Docker Compose.


## Instructions

### Prerequisites
- A Linux Virtual Machine (Debian recommended) with Docker and Docker Compose installed
- `make` installed
- Add `127.0.0.1 mnazar.42.fr` to `/etc/hosts` on the VM

### 1. Clone the repository
```bash
git clone <your_repo_url> inception
cd inception
```

### 2. Create the secrets files
These files are not in the repository for security reasons. Create them manually:
```bash
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
printf "your_wp_admin_password\nyour_wp_user_password" > secrets/credentials.txt
```

### 3. Create the .env file
This file is not in the repository. Create it at `srcs/.env`:
```bash
DOMAIN_NAME=mnazar.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_TITLE=Inception
WP_ADMIN_USER=wpmaster
WP_ADMIN_EMAIL=mnazar@student.42abudhabi.ae
WP_USER=wpeditor
WP_USER_EMAIL=editor@student.42abudhabi.ae
```

### 4. Add domain to /etc/hosts
```bash
echo "127.0.0.1 mnazar.42.fr" | sudo tee -a /etc/hosts
```

### 5. Build and run
```bash
make
```

### 6. Access the site
- Website: `https://mnazar.42.fr`
- Admin panel: `https://mnazar.42.fr/wp-admin`


## Resources

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress WP-CLI documentation](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [PID 1 in Docker](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)

### AI Usage

AI (Claude) was used in this project for:
- Debugging: When WordPress was stuck on "Waiting for MariaDB...", AI helped identify
  that `mysqladmin` was not installed in the WordPress container, and suggested adding
  `default-mysql-client` to the Dockerfile to fix it.
- Explaining the difference between Docker concepts (volumes, networks, secrets)
- Suggesting shell script patterns for init scripts (reviewed and tested manually)

AI was mainly used for debugging and to explain theoretical concepts.

### Project Description

This project uses Docker to containerize three services, each built from its own
Dockerfile based on Debian Bookworm. NGINX serves as the only entry point (port 443,
TLS only), WordPress with PHP-FPM runs the website, and MariaDB stores the data.
The services communicate over a custom Docker network and persist data using named
volumes. Docker Compose orchestrates the entire stack.

**Virtual Machines vs Docker**

A Virtual Machine emulates an entire OS on a hypervisor, including its own kernel,
which makes it heavier and slower to start. Docker containers share the host kernel
and isolate only the application environment, making them lightweight, faster to spin
up, and more portable. For this project, Docker allows us to define each service in
its own container with a reproducible configuration.

**Secrets vs Environment Variables**

Environment variables are convenient but can be exposed via `docker inspect` or
leaked into logs. Docker secrets are stored in an in-memory filesystem mounted at
`/run/secrets/` inside the container, making them safer for sensitive data like
passwords. In this project, database passwords and WordPress credentials are passed
via Docker secrets, while non-sensitive configuration (domain name, usernames,
database name) uses environment variables.

**Docker Network vs Host Network**

Host network mode shares the host's network namespace with the container, which
eliminates network isolation and is a security risk. Docker bridge networks create an
isolated virtual network between containers, allowing them to communicate using
service names (e.g., `mariadb`, `wordpress`) while remaining isolated from the host.
This project uses a custom bridge network called `inception`.

**Docker Volumes vs Bind Mounts**

Bind mounts link a host directory directly into the container, which is simple but
ties the container to the host's filesystem layout. Docker named volumes are managed
by Docker and are more portable and easier to back up. This project uses named
volumes backed by `/home/mnazar/data` on the host for WordPress files and the
MariaDB database.
