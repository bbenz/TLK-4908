#!/usr/bin/env bash
# Delete everything that deploy/aks/infra.sh created.
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-tlk4908-books}"
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
echo "Deleting $RESOURCE_GROUP. It takes a few minutes."
