#!/usr/bin/env bash
# Create or update the container registry and the AKS cluster in infra/main.bicep.
# These resources cost money while they run. Delete them with deploy/aks/down.sh.
set -euo pipefail
cd "$(dirname "$0")/../.."

RESOURCE_GROUP="${RESOURCE_GROUP:-tlk4908-books}"
LOCATION="${LOCATION:-eastus2}"
CLUSTER="${CLUSTER:-books-aks}"
NODE_COUNT="${NODE_COUNT:-2}"
NODE_SIZE="${NODE_SIZE:-Standard_D2s_v5}"

# Registry names are global. The default adds a short hash of your subscription ID.
subscription="$(az account show --query id --output tsv)"
REGISTRY="${REGISTRY:-books$(printf '%s' "$subscription" | sha256sum | cut -c1-8)}"

echo "Creating $CLUSTER and $REGISTRY in $RESOURCE_GROUP ($LOCATION). The first run takes several minutes."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
az deployment group create --resource-group "$RESOURCE_GROUP" --name books-infra \
  --template-file infra/main.bicep \
  --parameters clusterName="$CLUSTER" registryName="$REGISTRY" \
               nodeCount="$NODE_COUNT" nodeVmSize="$NODE_SIZE" \
  --output none
echo "Done. Next, run deploy/aks/deploy.sh"
