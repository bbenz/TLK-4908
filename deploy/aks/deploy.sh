#!/usr/bin/env bash
# Build the image in the registry, then deploy k8s/books.yaml to AKS. Run deploy/aks/infra.sh first.
#   NAMESPACE  Kubernetes namespace (default: books)
#   DNS_LABEL  Azure DNS name for the public address (default: the registry name). Set it empty for none.
#   TAG        Image tag (default: the current commit)
set -euo pipefail
cd "$(dirname "$0")/../.."

RESOURCE_GROUP="${RESOURCE_GROUP:-tlk4908-books}"
NAMESPACE="${NAMESPACE:-books}"
TAG="${TAG:-$(git rev-parse --short HEAD)}"

output() {
  az deployment group show --resource-group "$RESOURCE_GROUP" --name books-infra \
    --query "properties.outputs.$1.value" --output tsv
}
REGISTRY="$(output registryName)"
CLUSTER="$(output clusterName)"
IMAGE="$(output registryLoginServer)/books:$TAG"
LOCATION="$(az group show --name "$RESOURCE_GROUP" --query location --output tsv)"
DNS_LABEL="${DNS_LABEL-$REGISTRY}"

if [ -n "$(git status --porcelain)" ]; then
  echo "Warning: you have uncommitted changes. The image includes them, but the tag $TAG does not say so."
fi

echo "Building $IMAGE"
az acr build --registry "$REGISTRY" --image "books:$TAG" .
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER" --overwrite-existing --output none

kubectl create namespace "$NAMESPACE" --dry-run=client --output yaml | kubectl apply --filename -
sed "s|image: books:local|image: $IMAGE|" k8s/books.yaml | kubectl apply --namespace "$NAMESPACE" --filename -
if [ -n "$DNS_LABEL" ]; then
  kubectl annotate service books --namespace "$NAMESPACE" --overwrite \
    "service.beta.kubernetes.io/azure-dns-label-name=$DNS_LABEL"
fi

if ! kubectl rollout status deployment/books --namespace "$NAMESPACE" --timeout=5m; then
  echo "The pods did not become ready:"
  kubectl get pods --namespace "$NAMESPACE"
  kubectl get events --namespace "$NAMESPACE" --field-selector reason=Unhealthy | tail -n 5
  exit 1
fi

for _ in $(seq 60); do
  ip="$(kubectl get service books --namespace "$NAMESPACE" \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')"
  [ -n "$ip" ] && break
  sleep 5
done
if [ -n "$DNS_LABEL" ]; then
  echo "The site: http://$DNS_LABEL.$LOCATION.cloudapp.azure.com"
else
  echo "The site: http://$ip"
fi
