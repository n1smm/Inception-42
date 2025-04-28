#!/bin/sh
set -e
set -x

# Install WordPress if empty directory
if [ -z "$(ls -A .)" ]; then
    su-exec www-data:www-data wp core download --allow-root
fi

# Create config
su-exec www-data:www-data wp config create \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --force \
    --allow-root || echo "wordpress DB connection failed"

# Wait for database
echo "Waiting for database..."
while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    sleep 2
done

# Install WordPress
su-exec www-data:www-data wp core install \
    --url="$WORDPRESS_SITE_URL" \
    --title="$WORDPRESS_SITE_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
    --skip-email \
    --allow-root || echo "wp core install failed"



#create second user; role=author
su-exec www-data:www-data wp user create \
	$WORDPRESS_EXTRA_USER \
	$WORDPRESS_EXTRA_EMAIL \
	--role=author \
	--user_pass=$WORDPRESS_EXTRA_PASSWORD \
	--allow-root || echo "wp user create failed"

# redis
su-exec www-data:www-data wp plugin install redis-cache --activate --allow-root || echo "redis plugin install failed"
su-exec www-data:www-data wp config set WP_REDIS_HOST "redis" --allow-root || echo "redis config failed"
su-exec www-data:www-data wp config set WP_REDIS_PORT "6379" --allow-root || echo "redis config failed"
#if password needed
# su-exec www-data:www-data wp config set WP_REDIS_PASSWORD $WORDPRESS_REDIS_PASSWORD --allow-root
su-exec www-data:www-data wp redis enable --allow-root || echo "redis config failed"

#for ftp integration
su-exec www-data:www-data wp plugin install media-sync --activate --allow-root || echo "sync plugin failed"
su-exec www-data:www-data wp plugin install add-from-server --activate --allow-root || echo "ftp plugin failed"

exec "$@"
