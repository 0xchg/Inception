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
# Add the domain to /etc/hosts
echo "127.0.0.1     mchingi.42.fr" | sudo tee -a /etc/hosts
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