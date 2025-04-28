#!/bin/sh
set -e
set -x

envsubst < /etc/redis.conf.template > /etc/redis.conf
su-exec redis:redis redis-server /etc/redis.conf
