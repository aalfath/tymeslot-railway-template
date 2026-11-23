#!/bin/bash
# Waits until Tymeslot listens on $PORT, then runs bootstrap-admin.exs on the
# running node (bin/tymeslot rpc), which creates a verified admin from
# ADMIN_EMAIL / ADMIN_PASSWORD if the install has no verified admin yet.
set -u

for _ in $(seq 1 200); do
  if (exec 3<>"/dev/tcp/127.0.0.1/${PORT}") 2>/dev/null; then
    for attempt in 1 2 3 4 5; do
      if su -p app -c "cd /app && bin/tymeslot rpc 'Code.eval_file(\"/app/railway/bootstrap-admin.exs\")'"; then
        exit 0
      fi
      echo "[railway-bootstrap] attempt ${attempt} failed, retrying in 10s"
      sleep 10
    done
    echo "[railway-bootstrap] ERROR: could not create the admin account; see the lines above"
    exit 1
  fi
  sleep 3
done
echo "[railway-bootstrap] ERROR: server did not listen on port ${PORT} within 10 minutes"
exit 1
