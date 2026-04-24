_This project has been created as part of the 42 curriculum by mchingi_

---

## Description

Inception is a system administration project that has as a goal build a small but complete web infrastructure using Docker and Docker Compose, running entirely inside a virtual machine.

The infrastructure is composed of three services, each running in its own dedicated container built from scratch:

- **NGINX** 

- **WordPress + PHP-FPM**

- **MariaDB**

The containers communicate through a private Docker Network. Data is persisted via Docker named volumes. No ready-made images are used: every container is built from a custom Dockerfile based on Debian 12.

### Design Choise

**Why Debian 12 as the base image?**
Debian provides a stable, well-documented environment with a mature package manager. Alpine Linux would produce smaller images but uses `musl libc` instead of `glibc`, which can cause unexpected behaviour with certain packages. For a learning project where predictability matters, Debian is the safer choice also because i'm already used to it.

### Virtual Machines vs Docker



### Secrets vs Environment Variables



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

To verify individual containers:

```bash
# Check all containers are running
docker ps

# Check logs for a specific service
docker logs nginx
docker logs wordpress
docker logs mariadb

# Enter a running container for inspection
docker exec -it mariadb bash
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

### AI Usage

Claude by Anthropic was used throughout this project as a learning assistant. Specifically, it was used to:

- Explain core Docker concepts (images, layers, containers, volumes, networks, PID 1)
- Guide the step-by-step development of each Dockerfile and entrypoint script
- Debug runtime errors encountered during container builds and startup
- Explain the reasoning behind each configuration choice rather than just providing solutions

All code was written, reviewed, and understood by the author. AI was used as a tutor and reference, not as a code generator.