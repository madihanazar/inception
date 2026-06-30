#!/bin/bash
set -e

SSL_DIR="/etc/ssl"
mkdir -p "${SSL_DIR}"

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f "${SSL_DIR}/nginx.crt" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${SSL_DIR}/nginx.key" \
        -out    "${SSL_DIR}/nginx.crt" \
        -subj "/C=AE/ST=AbuDhabi/L=AbuDhabi/O=42/OU=student/CN=mnazar.42.fr"
fi

# Start nginx in foreground
exec nginx -g 'daemon off;'