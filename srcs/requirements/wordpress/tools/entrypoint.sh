#!/bin/bash
set -e

if [ ! -f /var/www/html/wp-config.php ]; then

    wp core download --path=/var/www/html --allow-root

    wp config create --path=/var/www/html \
        --dbname=${DB_NAME} \
        --dbuser=${DB_USER} \
        --dbpass=$(cat /run/secrets/db_password) \
        --dbhost=mariadb \
        --allow-root

    wp core install --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title="0xchg World" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=$(cat /run/secrets/wp_admin_password) \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    wp user create --path=/var/www/html \
        ${WP_USER} ${WP_USER_EMAIL} \
        --user_pass=$(cat /run/secrets/wp_user_password) \
        --role=author \
        --allow-root

    wp config set WP_REDIS_HOST redis --path=/var/www/html --allow-root
    wp config set WP_REDIS_PORT 6379 --path=/var/www/html --allow-root

    wp plugin install redis-cache --activate --allow-root --path=/var/www/html

    wp redis enable --allow-root --path=/var/www/html

fi

exec php-fpm8.2 --nodaemonize