_This project has been created as part of the 42 curriculum by mchingi_

---

## Description

Inception is a system administration project that has as a goal build a small but complete web infrastructure using Docker and Docker Compose, running entirely inside a virtual machine.

The infrastructure is composed of seven services, each running in its own dedicated container built from scratch:

- **NGINX** — the sole entry point into the infrastructure, handling HTTPS traffic on port 443 with TLSv1.2/TLSv1.3
- **WordPress + PHP-FPM** — the application layer, processing PHP and serving the WordPress CMS
- **MariaDB** — the database layer, storing all WordPress data
- **Redis** — an in-memory cache that reduces database load and accelerates WordPress page loads
- **Adminer** — a lightweight web interface for inspecting and managing the MariaDB database, accessible at `/adminer`
- **Static site** — a very simple and beautiful static website written in HTML and accessible at `/static`
- **Portainer** — a container management interface available through NGINX at `/portainer/`

The containers communicate through a private Docker Network. Data is persisted via Docker named volumes. No ready-made images are used: every container is built from a custom Dockerfile based on Debian 12.

### Design Choices

**Why Debian 12 as the base image?**
Debian provides a stable, well-documented environment with a mature package manager. Alpine Linux would produce smaller images but uses `musl libc` instead of `glibc`, which can cause unexpected behaviour with certain packages. For a learning project where predictability matters, Debian is the safer choice also because i'm already used to it.

**Why a static site in HTML?**
The static site bonus is as simple as it is to be and I didn't want to do something hard. The subject explicitly forbids PHP for this service, making HTML the cleanest choice.

### Virtual Machines vs Docker

A virtual machine emulates complete hardware and runs a full guest operating system on top of a hypervisor. Each VM carries gigabytes of OS overhead and takes minutes to boot. Docker containers share the host kernel through Linux namespaces and cgroups — they isolate only the process and its dependencies, not the entire OS. The result is images measured in megabytes and startup times measured in seconds. For deploying reproducible application environments, containers are dramatically more efficient.

### Secrets vs Environment Variables

Environment variables are the standard mechanism for passing configuration into containers. They are readable by any process inside the container and can be exposed in `docker inspect` output, image layers, or version control if mishandled. Docker secrets provide a more secure alternative: the secret value is mounted as a file inside the container under `/run/secrets/<name>` and is never written into the image or visible in environment variable listings.

### Docker Network vs Host Network

With `network: host`, the container shares the host machine's network stack directly — there is no isolation, and any port the container opens is immediately accessible on the host. With a Docker bridge network (used in this project), each container gets its own virtual network interface and IP address inside an isolated network. Containers on the same network can reach each other by service name (resolved via Docker's internal DNS), but the outside world can only access what is explicitly published via port mapping. The subject explicitly forbids `network: host` for this reason — using it would bypass the network isolation that is central to the architecture.

### Docker Volumes vs Bind Mounts

A bind mount maps a specific host path directly into a container (for example `/home/user/data:/var/lib/mysql`). This is transparent and convenient, but tightly couples the container to host path layout and permissions. A Docker volume is managed by Docker and is portable across compose runs, easier to inspect/manage with Docker tooling, and less brittle when moving environments.

This project uses Docker named volumes with the local driver and bind options: it gets the operational clarity of fixed host locations (`/home/<user>/data/...`) while still treating storage as first-class Docker volumes in Compose.

---

## Instructions 

### Prerequisites

- A virtual machine running a GNU/Linux distro (Ubuntu or Debian prefered)
- Docker and Docker Compose installed
- Your user added to the `docker` group (`sudo usermod -aG docker $USER`)

### Configuration

Clone the repository and configure the domain name:

```bash
# Clone the repository to a directory
git clone url_of_the_repository dir_name

# Add the domain to /etc/hosts
echo "127.0.0.1     mchingi.42.fr" | sudo tee -a /etc/hosts
```

Create the `secrets/` directory at the root of the repository and populate each file with the corresponding credential:

```bash
mkdir -p secrets
echo "your_db_password"      > secrets/db_password.txt
echo "your_root_password"    > secrets/db_root_password.txt
echo "your_admin_password"   > secrets/wp_admin_password.txt
echo "your_user_password"    > secrets/wp_user_password.txt
```

Create the `.env` file inside `srcs/` with non-sensitive configuration only:

```bash
DOMAIN_NAME=mchingi.42.fr
DB_NAME=wordpress
DB_USER=wpuser
WP_ADMIN_USER=wpadmin
WP_ADMIN_EMAIL=admin@mchingi.42.fr
WP_USER=regularuser
WP_USER_EMAIL=user@mchingi.42.fr
```

> **Important:** The `secrets/` directory and `.env` file are listed in `.gitignore` and must never be committed to version control. No passwords appear anywhere in the repository.

### Build and Run

```bash
# Build and start all containers
make

# Stop all containers
make down

# Rebuild everything from scratch
make re

# Full cleanup (removes containers, images, and data volumes)
make fclean
```

### Verify

Once running, open a browser and navigate to `https://mchingi.42.fr`. Accept the self-signed certificate warning. The WordPress site should be accessible.

**Adminer** is available at `https://mchingi.42.fr/adminer`. Log in with:
 
```
System:   MySQL
Server:   mariadb
Username: wpuser
Password: (contents of secrets/db_password.txt)
Database: wordpress
```
<!-- To log in as root and see all databases, use 'root' as the username and leave the Database field empty. -->

**Static site** is available at `https://mchingi.42.fr/static`.

**Portainer** is available at `https://mchingi.42.fr/portainer/`. On first access, create the Portainer admin account, then manage local Docker resources from the web UI.

To verify individual containers:

```bash
# Check all containers are running
docker ps

# Check logs for a specific service
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs redis
docker logs adminer
docker logs static
docker logs portainer

# Enter a running container for inspection
docker exec -it mariadb bash

# Verify Redis is responding
docker exec -it redis redis-cli ping
 
# Verify Redis cache is active in WordPress
docker exec -it wordpress wp redis status --path=/var/www/html --allow-root
```

---

## Resources

### Books

Mouat, A. (2015). *Using Docker: Developing and deploying software with containers.* O’Reilly Media.

Kerrisk, M. (2010). *The Linux programming interface: A Linux and UNIX system programming handbook.* No Starch Press.

Lacroix, J. (2016). *Mastering Ubuntu Server: Gain expertise in the art of deploying, configuring, managing, and troubleshooting Ubuntu Server* (3rd ed.). Packt Publishing.

### Documentation

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)
- [FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [What is SSL/TLS?](https://www.ssl.com/article/what-is-ssl-tls-an-in-depth-guide/)
- [Install your SSL certificate on NGINX](https://knowledge.digicert.com/tutorials/how-to-create-a-csr-using-openssl-and-install-your-ssl-certificate-on-a-nginx-server) 
- [Redis Documentation](https://redis.io/docs/)
- [Redis Object Cache Plugin](https://wordpress.org/plugins/redis-cache/)
- [Adminer](https://www.adminer.org/)
- [Portainer Documentation](https://docs.portainer.io/)

### AI Usage

Claude by Anthropic was used throughout this project as a learning assistant. Specifically, it was used to:

- Explain core Docker concepts (images, layers, containers, volumes, networks, PID 1)
- Guide the step-by-step development of each Dockerfile and entrypoint script
- Debug runtime errors encountered during container builds and startup
- Explain the reasoning behind each configuration choice rather than just providing solutions

All code was written, reviewed, and understood by the author. AI was used as a tutor and reference, not as a code generator.

- **GitHub Copilot (GPT-5 mini) — contribution summary:** Assisted interactively inside the repository to: update and reword documentation (including `README.md`, `USER_DOC.md`, and `DEV_DOC.md`), add the Portainer bonus-service details, correct headings and minor typos, and apply focused code/document patches. All edits were performed under the author's direction; the author reviewed and accepted every change.
