<#
.SYNOPSIS
Builds the image in the registry, then deploys k8s/books.yaml to AKS.

.DESCRIPTION
Run ./deploy/aks/infra.ps1 first. The image tag is the current commit.
The Service gets a public address. By default, its Azure DNS name is the registry name.
Use -DnsLabel "" for no DNS name.

.EXAMPLE
./deploy/aks/deploy.ps1
./deploy/aks/deploy.ps1 -Namespace books-test -DnsLabel ""
#>
param(
  [string]$ResourceGroup = "tlk4908-books",
  [string]$Namespace = "books",
  [string]$DnsLabel,
  [string]$Tag
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path

function Get-InfraOutput([string]$name) {
  $value = az deployment group show --resource-group $ResourceGroup --name books-infra `
    --query "properties.outputs.$name.value" --output tsv
  if ($LASTEXITCODE -ne 0 -or -not $value) { throw "Run ./deploy/aks/infra.ps1 first." }
  return $value
}

$registry = Get-InfraOutput registryName
$cluster = Get-InfraOutput clusterName
$loginServer = Get-InfraOutput registryLoginServer
$location = az group show --name $ResourceGroup --query location --output tsv
if (-not $Tag) { $Tag = git -C $root rev-parse --short HEAD }
if (-not $PSBoundParameters.ContainsKey("DnsLabel")) { $DnsLabel = $registry }
$image = "$loginServer/books:$Tag"

if (git -C $root status --porcelain) {
  Write-Warning "You have uncommitted changes. The image includes them, but the tag $Tag does not say so."
}

Write-Host "Building $image"
az acr build --registry $registry --image "books:$Tag" $root
if ($LASTEXITCODE -ne 0) { throw "The image build failed." }
az aks get-credentials --resource-group $ResourceGroup --name $cluster --overwrite-existing --output none
if ($LASTEXITCODE -ne 0) { throw "Could not get the cluster credentials." }

kubectl create namespace $Namespace --dry-run=client --output yaml | kubectl apply --filename -
(Get-Content (Join-Path $root "k8s/books.yaml") -Raw).Replace("image: books:local", "image: $image") |
  kubectl apply --namespace $Namespace --filename -
if ($LASTEXITCODE -ne 0) { throw "Could not apply k8s/books.yaml." }
if ($DnsLabel) {
  kubectl annotate service books --namespace $Namespace --overwrite `
    "service.beta.kubernetes.io/azure-dns-label-name=$DnsLabel"
}

kubectl rollout status deployment/books --namespace $Namespace --timeout=5m
if ($LASTEXITCODE -ne 0) {
  Write-Host "The pods did not become ready:"
  kubectl get pods --namespace $Namespace
  kubectl get events --namespace $Namespace --field-selector reason=Unhealthy | Select-Object -Last 5
  exit 1
}

$ip = ""
foreach ($i in 1..60) {
  $ip = kubectl get service books --namespace $Namespace --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
  if ($ip) { break }
  Start-Sleep -Seconds 5
}
if ($DnsLabel) {
  Write-Host "The site: http://$DnsLabel.$location.cloudapp.azure.com"
} else {
  Write-Host "The site: http://$ip"
}
