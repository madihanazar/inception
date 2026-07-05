# User Documentation — Inception

## Services Provided by the Stack

This project runs three services, each in its own Docker container:

- **NGINX** — The only entry point to the infrastructure. Handles HTTPS connections
  on port 443 using TLSv1.2/TLSv1.3 and forwards requests to WordPress.
- **WordPress + PHP-FPM** — The content management system that runs the website.
- **MariaDB** — The database that stores all WordPress data (posts, users, settings).

## Starting and Stopping the Project

**Start the project:**
```bash
make
```

**Pause the containers (keeps data):**
```bash
make stop
```


**Start stopped containers again (resume instantly):**
```bash
make start
```
Resumes the containers that were stopped with `make stop`. No rebuild needed.


**Stop and remove containers (keeps data in volumes):**
```bash
make down
```

**Restart the containers:**
```bash
make restart
```

**Clean (remove containers and Docker artifacts, keeps data on host):**
```bash
make clean
```
Stops everything and removes unused Docker images, containers, and networks to
free up space. The persistent data in `/home/mnazar/data/` is kept.


**Full clean (remove everything including data):**
```bash
make fclean
```
Does everything `make clean` does AND deletes all persistent data in
`/home/mnazar/data/`. 


## Accessing the Website and Admin Panel

Make sure `127.0.0.1 mnazar.42.fr` is in your `/etc/hosts` file.

- **Website:** `https://mnazar.42.fr`
- **Administration panel:** `https://mnazar.42.fr/wp-admin`

Since the site uses a self-signed certificate, your browser will show a security
warning. Click "Advanced" and proceed to continue.

## Locating and Managing Credentials

Credentials are stored locally in the `secrets/` directory at the root of the project.
These files are never committed to Git.

| File | Contents |
|------|----------|
| `secrets/credentials.txt` | Line 1: WordPress admin password, Line 2: WordPress user password |
| `secrets/db_password.txt` | MariaDB user password |
| `secrets/db_root_password.txt` | MariaDB root password |

The usernames and emails are defined in `srcs/.env`.

To view a credential, read the file directly on the host:
```bash
cat secrets/<filename>.txt
```

To change a password, edit the corresponding file and rebuild the project with:
```bash
make re
```

## Checking That Services Are Running Correctly

**List running containers:**
```bash
docker ps
```
All three containers (`nginx`, `wordpress`, `mariadb`) should show status `Up`.

**Check logs of a service:**
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```


**Test the website responds:**
```bash
curl -k https://mnazar.42.fr
```

**To check the SSL/TLS connection:**
```bash
curl -kv https://mnazar.42.fr 2>&1 | grep "SSL connection\|TLS"
```

**Verify the WordPress users exist:**
```bash
docker exec wordpress wp user list --allow-root --path=/var/www/html
```

**To show the databases:**
```bash
docker exec mariadb mysql -u wpuser -pwppass -e "SHOW DATABASES;"
```
**To check the named volumes:**
```bash
docker volume ls
ls /home/mnazar/data/wordpress
ls /home/mnazar/data/mariadb
```

**Data persists after restart:**
```bash
make down
make
docker exec wordpress wp post list --allow-root --path=/var/www/html
```
