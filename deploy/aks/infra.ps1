<#
.SYNOPSIS
Creates or updates the container registry and the AKS cluster in infra/main.bicep.

.DESCRIPTION
These resources cost money while they run. Delete them with ./deploy/aks/down.ps1.

.EXAMPLE
./deploy/aks/infra.ps1
./deploy/aks/infra.ps1 -Location westus3
#>
param(
  [string]$ResourceGroup = "tlk4908-books",
  [string]$Location = "eastus2",
  [string]$Cluster = "books-aks",
  [string]$Registry = "",
  [int]$NodeCount = 2,
  [string]$NodeSize = "Standard_D2s_v5"
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path

if ($Registry -eq "") {
  # Registry names are global. The default adds a short hash of your subscription ID.
  $subscription = az account show --query id --output tsv
  if ($LASTEXITCODE -ne 0) { throw "Sign in first with: az login" }
  $hash = [Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($subscription))
  $Registry = "books" + (-join ($hash[0..3] | ForEach-Object { $_.ToString("x2") }))
}

Write-Host "Creating $Cluster and $Registry in $ResourceGroup ($Location). The first run takes several minutes."
az group create --name $ResourceGroup --location $Location --output none
if ($LASTEXITCODE -ne 0) { throw "Could not create the resource group." }
az deployment group create --resource-group $ResourceGroup --name books-infra `
  --template-file (Join-Path $root "infra/main.bicep") `
  --parameters clusterName=$Cluster registryName=$Registry nodeCount=$NodeCount nodeVmSize=$NodeSize `
  --output none
if ($LASTEXITCODE -ne 0) { throw "The deployment failed." }
Write-Host "Done. Next, run ./deploy/aks/deploy.ps1"
