param location string
param solutionPrefix string
param tags object

var nsgName = '${solutionPrefix}-nsg'

output nsgId string = nsg.id

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AzureKeyVault'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'AzureKeyVault'
          destinationPortRange: '*'
          direction: 'Outbound'
          priority: 170
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AzureStorageAccount'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'Storage'
          destinationPortRange: '*'
          direction: 'Outbound'
          priority: 180
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AzureWeb'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'AppService'
          destinationPortRange: '*'
          direction: 'Outbound'
          priority: 190
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AzureFrontDoor'
        properties: {
           access: 'Allow'
           destinationAddressPrefix: 'AzureFrontDoor.FrontEnd'
           destinationPortRange: '443'
           direction: 'Outbound'
           priority: 200
           protocol: 'Tcp'
           sourceAddressPrefix: '*'
           sourcePortRange: '*'
         }
       }
      {
        name: 'DenyInternetAll'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          direction: 'Outbound'
          priority: 1000
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

output networkSecurityGroup string = nsg.id
