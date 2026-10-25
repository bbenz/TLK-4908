// A container registry and an AKS cluster for the books site.
// deploy/aks/infra.ps1 and deploy/aks/infra.sh run this file.

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the AKS cluster.')
param clusterName string = 'books-aks'

@description('Name of the container registry. It must be unique across Azure.')
param registryName string

@description('Number of nodes in the cluster.')
@minValue(1)
param nodeCount int = 2

@description('VM size for the nodes.')
param nodeVmSize string = 'Standard_D2s_v5'

resource registry 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: registryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

resource cluster 'Microsoft.ContainerService/managedClusters@2026-04-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: 'system'
        mode: 'System'
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
      }
    ]
  }
}

// AcrPull lets the cluster pull images from the registry, with no password.
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, cluster.id, acrPullRoleId)
  scope: registry
  properties: {
    principalId: cluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
  }
}

output registryName string = registry.name
output registryLoginServer string = registry.properties.loginServer
output clusterName string = cluster.name
