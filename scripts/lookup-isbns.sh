#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required."
  exit 1
fi

jq -r '.[].isbn' src/main/resources/books.json | while read -r isbn; do
  curl --fail --silent "https://openlibrary.org/isbn/${isbn}.json" >/dev/null && echo "${isbn}: found" || echo "${isbn}: not found"
done
