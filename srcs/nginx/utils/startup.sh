#!/usr/bin/env sh

mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout certs/aouhadou.key \
    -out certs/aouhadou.crt \
    -subj "/CN=DOMAIN_NAME.42.fr"
