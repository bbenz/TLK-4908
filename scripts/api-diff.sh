#!/usr/bin/env bash
set -euo pipefail

export PATH="$PWD/.tools/bin:$PATH"
if ! command -v oasdiff >/dev/null 2>&1; then
  echo "Run scripts/install-tools.sh first."
  exit 1
fi

# the contract we wrote first is in api/openapi.yaml
[ -f target/books.jar ] || ./mvnw -B -q -DskipTests package
mkdir -p build
java -jar target/books.jar > build/app.log 2>&1 &
APP_PID=$!
trap 'kill "$APP_PID" 2>/dev/null || true' EXIT

curl -fs --retry 30 --retry-all-errors --retry-delay 2 \
     localhost:8080/v3/api-docs.yaml -o build/pr.yaml

oasdiff breaking api/openapi.yaml build/pr.yaml --fail-on ERR
