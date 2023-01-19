param location string
param nsgId string
param solutionPrefix string
param tags object

var virtualNetworkName = '${solutionPrefix}-vnet'
var subnet1Name = '${solutionPrefix}-public'
var subnet2Name = '${solutionPrefix}-private'
var subnet3Name = '${solutionPrefix}-webapp'

output subnet1ResourceId string = virtualNetwork::subnet1.id
output subnet2ResourceId string = virtualNetwork::subnet2.id
output subnet3ResourceId string = virtualNetwork::subnet3.id

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsgId
          }
          serviceEndpoints: [
            {
              locations: ['*']
              service: 'Microsoft.KeyVault'
            }
            {
              locations: ['northeurope']
              service: 'Microsoft.Storage'
            }
            {
              locations: ['*']
              service: 'Microsoft.Web'
            }
          ]
        }
      }
      {
        name: subnet3Name
        properties: {
          addressPrefix: '10.0.2.0/26'
          networkSecurityGroup: {
            id: nsgId
          }
          delegations: [
            {
              name: 'Microsoft.Web/serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              locations: ['northeurope']
              service: 'Microsoft.KeyVault'
            }
            {
              locations: ['northeurope']
              service: 'Microsoft.Storage'
            }
            {
              locations: ['northeurope']
              service: 'Microsoft.Web'
            }
          ]
        }
      }
    ]
  }

  resource subnet1 'subnets' existing = {
    name: subnet1Name
  }

  resource subnet2 'subnets' existing = {
    name: subnet2Name
  }

  resource subnet3 'subnets' existing = {
    name: subnet3Name
  }
}
