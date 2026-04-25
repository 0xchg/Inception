# User Documentation

This project runs a self-hosted WordPress website acessible via HTTPS. It is composed of three services working together:

- **WordPress** — the website and content management system where you can create and manage pages, posts, and media
- **MariaDB** — the database that stores all WordPress content, users, and settings
- **NGINX** — the web server that receives all incoming traffic and secures it with HTTPS

As an end user or administrator, you interact only with the website and the WordPress admin panel <!--— the underlying services run automatically in the background.-->

---

All commands are run from the root of the repository

**Start the project:**
```bash
make
```
This builds all Docker images and starts all three services. On first run, WordPress is installed automatically

**Stop the project (preserves all data):**
```bash
make down
```

**Restart the project:**
```bash
make re
```

**Full reset (destroys all containers, images, and data):**
```bash
make fclean
```
> ⚠️ This deletes all website content and database data. Use only if you want to start from scratch.

---

## Accessing the Website

Once the project is running, open a browser and go to:

```
https://mchingi.42.fr
```

Your browser will show a security warning because the certificate is self-signed. This is expected — click **Advanced** and proceed to the site.

