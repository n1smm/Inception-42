#!/bin/sh
set -e

# Copy staged WordPress files if directory is empty
if [ -z "$(ls -A /var/www/html)" ]; then
    echo "Initializing WordPress from staging..."
    cp -a /usr/src/wordpress/. /var/www/html/
fi

# Fix permissions
chown -R www-data:www-data /var/www/html

# Configure database
su-exec www-data:www-data sh -c '
    if [ ! -f wp-config.php ]; then
        echo "Creating wp-config.php..."
        wp config create \
            --dbname="$WORDPRESS_DB_NAME" \
            --dbuser="$WORDPRESS_DB_USER" \
            --dbpass="$WORDPRESS_DB_PASSWORD" \
            --dbhost="$WORDPRESS_DB_HOST" \
            --allow-root
    fi

    # Wait for database
    echo "Waiting for database..."
    while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
        sleep 2
    done

    # Install WordPress
    if ! $(wp core is-installed --allow-root); then
        echo "Finalizing installation..."
        wp core install \
            --url="$WORDPRESS_SITE_URL" \
            --title="$WORDPRESS_SITE_TITLE" \
            --admin_user="$WORDPRESS_ADMIN_USER" \
            --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL" \
			--skip-email
            --allow-root
    fi
'

exec "$@"
