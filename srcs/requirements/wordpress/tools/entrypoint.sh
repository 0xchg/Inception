#!/bin/bash
set -e

# Espera que o MariaDB esteja pronto
until mysqladmin ping -h mariadb -u ${DB_USER} -p${DB_PASSWORD} --silent 2>/dev/null; do
    echo "A aguardar MariaDB..."
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then

    wp core download --path=/var/www/html --allow-root

    wp config create --path=/var/www/html \
        --dbname=${DB_NAME} \
        --dbuser=${DB_USER} \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb \
        --allow-root

    wp core install --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title="0xchg World" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    wp user create --path=/var/www/html \
        ${WP_USER} ${WP_USER_EMAIL} \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author \
        --allow-root

fi

exec php-fpm8.2 --nodaemonize