# Developer Documentation

## Prerequisites

- A virtual machine running a GNU/Linux distro (Ubuntu or Debian prefered)
- Docker and Docker Compose installed
- Your user added to the `docker` group (`sudo usermod -aG docker $USER`)

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and back in for the group change to take effect
```

---

## Repository Structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                        # Credential files — never committed
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env                        # Non-sensitive config — never committed
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── default.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── entrypoint.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       ├── entrypoint.sh
        │       └── template.sql
        └── bonus/
            ├── redis/
            │   ├── Dockerfile
            │   └── conf/
            │       └── redis.conf
            ├── adminer/
            │   ├── Dockerfile
            │   ├── conf/
            │   │   └── www.conf
            │   └── tools/
            │       └── entrypoint.sh
            ├── portainer/
            │   └── Dockerfile
            └── static/
                ├── Dockerfile
                ├── conf/
                │   └── site.conf
                └── www/
                    └── index.html
```

---

## Environment Setup

### 1. Configure the domain

Add the domain to the VM's hosts file so the browser resolves it locally:

```bash
echo "127.0.0.1   mchingi.42.fr" | sudo tee -a /etc/hosts
```

### 2. Create the secrets directory

All passwords are stored as individual files under `secrets/` at the repository root. Create them manually — these files must never be committed to git.

```bash
mkdir -p secrets
echo "your_db_password"      > secrets/db_password.txt
echo "your_root_password"    > secrets/db_root_password.txt
echo "your_admin_password"   > secrets/wp_admin_password.txt
echo "your_user_password"    > secrets/wp_user_password.txt
```

Docker Compose reads these files and mounts them inside containers under `/run/secrets/<name>`. Entrypoint scripts read them at runtime with `cat /run/secrets/<name>` — passwords are never stored in environment variables or image layers.

### 3. Configure the .env file

Create `srcs/.env` with non-sensitive configuration only — no passwords:

```bash
DOMAIN_NAME=mchingi.42.fr
DB_NAME=wordpress
DB_USER=wpuser
WP_ADMIN_USER=0xchg
WP_ADMIN_EMAIL=0xchg@mchingi.42.fr
WP_USER=chingi
WP_USER_EMAIL=chingi@mchingi.42.fr
```

### 4. Create host data directories

The named volumes store data on the host at `/home/<user>/data/`. The Makefile creates these automatically on `make`, but you can also create them manually:

```bash
mkdir -p ~/data/wordpress
mkdir -p ~/data/mariadb
mkdir -p ~/data/portainer
```

---

## Building and Running

All operations are performed from the repository root via the Makefile, which calls Docker Compose internally.

```bash
# Build all images and start all containers (detached)
make

# Stop and remove containers (volumes and data are preserved)
make down

# Stop, remove, and rebuild everything
make re

# Remove containers and images (data preserved)
make clean

# Full reset — removes everything including volume data
make fclean
```

The Makefile calls:
```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

On first run, the WordPress entrypoint detects that `wp-config.php` does not exist and performs the full installation automatically using WP-CLI — including Redis configuration and plugin setup. On subsequent runs it skips the installation and starts PHP-FPM directly.

---

## Managing Containers and Volumes

**View running containers:**
```bash
docker ps
```

**View logs (live):**
```bash
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb
docker logs -f redis
docker logs -f adminer
docker logs -f static
docker logs -f portainer
```

**Enter a running container:**
```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
docker exec -it redis bash
docker exec -it portainer sh
```

**Inspect a container (network, mounts, env):**
```bash
docker inspect mariadb
```

**List volumes:**
```bash
docker volume ls
```

**Remove unused images, containers, and networks:**
```bash
docker system prune -f
```

## Verifying the Database

Connect to MariaDB from inside the container to inspect the database state:

```bash
docker exec -it mariadb mysql \
  -u root \
  -p$(cat secrets/db_root_password.txt)
```

```sql
-- List all databases
SHOW DATABASES;

-- Verify users and their allowed hosts
SELECT User, Host FROM mysql.user;

-- Verify WordPress user privileges
SHOW GRANTS FOR 'wpuser'@'%';
```

---

## Verifying Redis

```bash
# Check Redis is responding
docker exec -it redis redis-cli ping
# Expected: PONG

# Monitor Redis commands in real time
docker exec -it redis redis-cli monitor

# Check Redis integration status from WordPress
docker exec -it wordpress wp redis status --path=/var/www/html --allow-root
# Expected: Status: Connected, Drop-in: Valid
```

---

## Data Persistence

All persistent data lives outside the containers on the host filesystem, mounted via Docker named volumes:

| Volume | Host path | Container path | Contents |
|---|---|---|---|
| `wp-files` | `/home/mchingi/data/wordpress` | `/var/www/html` | WordPress core, themes, plugins, uploads |
| `db-data` | `/home/mchingi/data/mariadb` | `/var/lib/mysql` | MariaDB database files |
| `portainer-data` | `/home/mchingi/data/portainer` | `/data` | Portainer users, settings, and endpoint metadata |

Both volumes use the `local` driver with `bind` options, meaning Docker manages them as named volumes while storing the data at a predictable host path. Stopping or removing containers does not affect this data. Only `make fclean` removes it.

To inspect the data directly on the host:

```bash
ls ~/data/wordpress
ls ~/data/mariadb
ls ~/data/portainer
```

---

## How Secrets Work Internally

Docker Compose mounts each secret as a read-only file inside the container:

```
/run/secrets/db_password
/run/secrets/db_root_password
/run/secrets/wp_admin_password
/run/secrets/wp_user_password
```

Each entrypoint script reads the relevant secret at startup:

```bash
export DB_PASSWORD=$(cat /run/secrets/db_password)
```

This means passwords are never present in:
- Dockerfiles
- Environment variables (`docker inspect` will not reveal them)
- The `.env` file
- Any image layer
- The git repository