param location string
param tags object
param storageAccountName string
param storageAccountSku string
param vnetSubnet2ResourceId string
param allowedIPs array

resource storageAccountResoruces 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          action: 'Allow'
          id: vnetSubnet2ResourceId
        }
      ]
      ipRules: [ for instance in allowedIPs: {
        value: replace(instance.ipAddress, '/32', '')
      }]
    }
  }
}
