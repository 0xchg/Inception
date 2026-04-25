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

**WordPress Administration Panel:**
```
https://mchingi.42.fr/wp-admin
```

Log in with the administrator credentials stored in `secrets/wp_admin_password.txt`. The administrator username is defined in `srcs/.env` under `WP_ADMIN_USER`.

---

## Locating and Managing Credentials

All credentials are stored as plaintext files in the `secrets/` directory at the root of the repository:

| File | Purpose |
|---|---|
| `secrets/db_password.txt` | WordPress database user password |
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/wp_admin_password.txt` | WordPress administrator password |
| `secrets/wp_user_password.txt` | WordPress regular user password |

Non-sensitive configuration (usernames, email addresses, domain name) is in `srcs/.env`.

> These files are never committed to version control. If you are setting up this project for the first time, you must create them manually — see the Developer Documentation.

---

## Checking That Services Are Running

**See all running containers:**
```bash
docker ps
```
You should see three containers — `nginx`, `wordpress`, and `mariadb` — all with status `Up`.

**Check logs for a specific service:**
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

**Quick connectivity check:**
```bash
curl -k https://mchingi.42.fr -I
```
A response of `HTTP/1.1 200 OK` confirms the site is up and reachable.
