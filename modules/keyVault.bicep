param location string
param tags object
param keyVaultName string
param serviceOnePrincipalId string
param serviceTwoPrincipalId string
param serviceThreePrincipalId string
param serviceFourPrincipalId string
param serviceFivePrincipalId string
param vnetSubnet2ResourceId string
param vnetSubnet3ResourceId string
param allowedIPs array

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    enabledForTemplateDeployment: true
    tenantId: tenant().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: vnetSubnet2ResourceId
        }
        {
          id: vnetSubnet3ResourceId
        }
      ]
      ipRules: [ for instance in allowedIPs: {
        value: replace(instance.ipAddress, '/32', '')
      }]
    }
    accessPolicies: [
      {
        objectId: serviceOnePrincipalId
        tenantId: tenant().tenantId
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'get'
            'list'
          ]
          storage: []
        }
      }
      {
        objectId: serviceTwoPrincipalId
        tenantId: tenant().tenantId
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'get'
            'list'
          ]
          storage: []
        }
      }
      {
        objectId: 'Object Id hash'
        tenantId: tenant().tenantId
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'get'
            'list'
          ]
          storage: []
        }
      }
      {
        objectId: 'Object Id hash' //jacekmackiewicz@gmail.com
        tenantId: tenant().tenantId
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'all'
          ]
          storage: []
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'testMySecretName'
  properties: {
    value: 'testMyVerySecretValue'
  }
}
