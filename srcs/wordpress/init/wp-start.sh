#!/bin/sh
set -e

# Install WordPress if not found
if [ ! -f wp-config.php ]; then
  echo "Downloading WordPress..."
  wp core download --allow-root

  echo "Creating wp-config.php..."
  wp config create \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --allow-root

  # Wait for MySQL to be ready (important for first run)
  echo "Waiting for MySQL..."
  while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    sleep 1
  done

  echo "Installing WordPress..."
  wp core install \
    --url="$WORDPRESS_SITE_URL" \
    --title="$WORDPRESS_SITE_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
    --allow-root
fi

# Ensure proper ownership
chown -R www-data:www-data /var/www/html

# Execute the CMD
exec "$@"
