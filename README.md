_This project has been created as part of the 42 curriculum by mchingi_

---

## Description

Inception is a system administration project that has as a goal build a small but complete web infrastructure using Docker and Docker Compose, running entirely inside a virtual machine.

The infrastructure is composed of three services, each running in its own dedicated container built from scratch:

- **NGINX** — the sole entry point into the infrastructure, handling HTTPS traffic on port 443 with TLSv1.2/TLSv1.3
- **WordPress + PHP-FPM** — the application layer, processing PHP and serving the WordPress CMS
- **MariaDB** — the database layer, storing all WordPress data
- **Redis** — an in-memory cache that reduces database load and accelerates WordPress page loads
- **Adminer** — a lightweight web interface for inspecting and managing the MariaDB database, accessible at `/adminer`

The containers communicate through a private Docker Network. Data is persisted via Docker named volumes. No ready-made images are used: every container is built from a custom Dockerfile based on Debian 12.

### Design Choise

**Why Debian 12 as the base image?**
Debian provides a stable, well-documented environment with a mature package manager. Alpine Linux would produce smaller images but uses `musl libc` instead of `glibc`, which can cause unexpected behaviour with certain packages. For a learning project where predictability matters, Debian is the safer choice also because i'm already used to it.

### Virtual Machines vs Docker

A virtual machine emulates complete hardware and runs a full guest operating system on top of a hypervisor. Each VM carries gigabytes of OS overhead and takes minutes to boot. Docker containers share the host kernel through Linux namespaces and cgroups — they isolate only the process and its dependencies, not the entire OS. The result is images measured in megabytes and startup times measured in seconds. For deploying reproducible application environments, containers are dramatically more efficient.

### Secrets vs Environment Variables

Environment variables are the standard mechanism for passing configuration into containers. They are readable by any process inside the container and can be exposed in `docker inspect` output, image layers, or version control if mishandled. Docker secrets provide a more secure alternative: the secret value is mounted as a file inside the container under `/run/secrets/<name>` and is never written into the image or visible in environment variable listings.

### Docker Network vs Host Network



### Docker Volumes vs Bind Mounts



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

### AI Usage

Claude by Anthropic was used throughout this project as a learning assistant. Specifically, it was used to:

- Explain core Docker concepts (images, layers, containers, volumes, networks, PID 1)
- Guide the step-by-step development of each Dockerfile and entrypoint script
- Debug runtime errors encountered during container builds and startup
- Explain the reasoning behind each configuration choice rather than just providing solutions

All code was written, reviewed, and understood by the author. AI was used as a tutor and reference, not as a code generator.
