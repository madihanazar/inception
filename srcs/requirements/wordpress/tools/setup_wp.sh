#!/bin/bash

WP_ADMIN_PASS=$(sed -n '1p' /run/secrets/credentials)
WP_USER_PASSWORD=$(sed -n '2p' /run/secrets/credentials)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Wait for mariadb to be ready
echo "Waiting for MariaDB..."
while ! mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done
echo "MariaDB is ready."

# Create WordPress directory
mkdir -p /var/www/html
cd /var/www/html

# Donwload and configure wordpress only if not already done
if [ ! -f "/var/www/html/wp-config.php" ]; then

    wp core download --allow-root --locale=en_US

    # Create wp-config.php
    wp config create \
        --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --path="/var/www/html"
    
    # Install wordpress
    wp core install \
        --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --path="/var/www/html"
    
    # Create second regular user
    wp user create \
        --allow-root \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=editor \
        --path="/var/www/html"
    
    chown -R www-data:www-data /var/www/html
fi

PHP_FPM=$(find /usr/sbin -name "php-fpm*" | head -1)
exec "${PHP_FPM}" -F