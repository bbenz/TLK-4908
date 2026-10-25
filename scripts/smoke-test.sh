#!/usr/bin/env bash
set -euo pipefail

# Start the site with the same compose.yaml people use on their laptops.
export COMPOSE_PROJECT_NAME=books-gate
port="${APP_PORT:-8080}"
trap 'docker compose down > /dev/null 2>&1 || true' EXIT

if ! docker compose up --build --detach --wait --wait-timeout 180; then
  echo "The site did not start. The last 40 log lines:"
  docker compose logs --no-color --tail 40
  exit 1
fi

curl -fs "localhost:$port/actuator/health" | grep '"status":"UP"'
curl -fs "localhost:$port/api/books" > /dev/null
container="$(docker compose ps --quiet | head -n 1)"
docker exec "$container" java -version 2>&1 | grep 'version "25'
