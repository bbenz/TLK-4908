#!/usr/bin/env bash
set -euo pipefail

docker build -q -t books:pr .
docker run -d --name books -p 8080:8080 books:pr > /dev/null
trap 'docker logs --tail 40 books' ERR
trap 'docker rm -f books > /dev/null 2>&1 || true' EXIT

curl -fs --retry 30 --retry-all-errors --retry-delay 2 \
     localhost:8080/actuator/health | grep '"status":"UP"'
curl -fs localhost:8080/api/books > /dev/null
docker run --rm --entrypoint java books:pr -version 2>&1 \
  | grep 'version "25'
