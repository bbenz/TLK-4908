#!/usr/bin/env bash
set -euo pipefail

export PATH="$PWD/.tools/bin:$PATH"
if ! command -v osv-scanner >/dev/null 2>&1; then
  echo "Run scripts/install-tools.sh first."
  exit 1
fi
if docker info > /dev/null 2>&1 && ! command -v grype >/dev/null 2>&1; then
  echo "Run scripts/install-tools.sh first."
  exit 1
fi

status=0
osv-scanner scan source --recursive . || status=1
./mvnw -B -q cyclonedx:makeAggregateBom || status=1

if docker info > /dev/null 2>&1; then
  docker build -q -t books:pr . > /dev/null || status=1
  grype books:pr --only-fixed --fail-on high || status=1
else
  echo "Docker is not running. Skipping the image scan."
fi
exit "$status"
