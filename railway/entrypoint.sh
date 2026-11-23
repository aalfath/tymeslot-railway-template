#!/bin/bash
# Railway entrypoint for Tymeslot. Runs as root (like upstream's
# start-docker.sh, which drops to the `app` user for the server).
set -eu

export PORT="${PORT:-4000}"
export DEPLOYMENT_TYPE=docker

# Mail goes to the admin's own address until SMTP is configured.
if [ -z "${EMAIL_FROM_ADDRESS:-}" ]; then
  export EMAIL_FROM_ADDRESS="noreply@${PHX_HOST:-localhost}"
fi

# The image's Erlang cookie is public, so write a random one for this
# container (bin/tymeslot rpc reads the same file), and keep Erlang
# distribution on loopback, off Railway's private network.
head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' > /app/releases/COOKIE
chown app:app /app/releases/COOKIE
chmod 400 /app/releases/COOKIE
unset RELEASE_COOKIE

# Create (or repair) the first admin once the server answers, in the
# background, so it never delays or blocks the server start.
/app/railway/bootstrap-admin.sh &

# Upstream's script: waits for PostgreSQL, runs migrations, then execs the
# server. Any failure exits non-zero, so Railway's ON_FAILURE restarts it.
exec /app/start-docker.sh
