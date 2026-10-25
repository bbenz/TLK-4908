<#
.SYNOPSIS
Deletes everything that ./deploy/aks/infra.ps1 created.
#>
param(
  [string]$ResourceGroup = "tlk4908-books"
)

az group delete --name $ResourceGroup --yes --no-wait
if ($LASTEXITCODE -ne 0) { throw "Could not delete $ResourceGroup." }
Write-Host "Deleting $ResourceGroup. It takes a few minutes."
