@description('The Azure region into which the resources should be deployed.')
param location string = 'northeurope'

@description('The name of the environment. This must be dev, qa, or prod.')
@allowed([
  'dev'
  'qa'
  'demo'
  'prod'
])
param environmentName string = 'dev'
param dotnetEnvironment string = 'Development'

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
param solutionName string = 'projectName'

@description('The name and tier of the App Service plan SKU.')
param appServicePlanSku object = {
  name: 'B1'
  tier: 'Basic'
}
@description('The number of App Service plan instances.')
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@description('The name of the Storage Account plan SKU.')
param storageAccountSku string = 'Standard_LRS'
param storageAccountNames array = [
  'storage'
  'logs'
]

param tags object = {
  'Department Name': 'Development'
  'Service Name': 'Project Name'
  'Project Number': '123456789'
  'Product Code': '1234'
  'Technical Owner': 'jacekmackiewicz@gmail.com'
  'Owner': 'smith@mail.com'
}

param allowedIPs array = []

//-----------------------------------------------------------------------------------------------------//
var appServicePlanName = '${solutionName}-${environmentName}-plan'
//-----------------------------------------------------------------------------------------------------//

module dns 'modules/dns.bicep' = {
  name: 'dns-${environmentName}'
  params: {
    environmentName: environmentName
  }
}

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}
module appServices 'modules/appService.bicep' = {
  name: 'appServices'
  params: {
    location: location
    tags: tags
    dotnetEnvironment: dotnetEnvironment
    appServicePlanId: appServicePlan.id
    solutionPrefix: '${solutionName}-${environmentName}'
    appInsightsConnectionString: appInsights.properties.ConnectionString
    vnetSubnet3ResourceId: vnet.outputs.subnet3ResourceId
    dnsZoneName: dns.outputs.dnsZoneName
    allowedIPs: allowedIPs
  }
}

module storages 'modules/storage.bicep' = [ for storageAccountName in storageAccountNames: {
  name: '${solutionName}${environmentName}${storageAccountName}'
  params: {
    location: location
    tags: tags
    storageAccountName: '${solutionName}${environmentName}${storageAccountName}'
    storageAccountSku: storageAccountSku
    vnetSubnet2ResourceId: vnet.outputs.subnet2ResourceId
    allowedIPs: allowedIPs
  }
}]

module keyVault 'modules/keyVault.bicep' = {
  name: '${solutionName}${environmentName}kv'
  params: {
    location: location
    tags: tags
    keyVaultName: '${solutionName}${environmentName}kv'
    serviceOnePrincipalId: appServices.outputs.serviceOnePrincipalId
    serviceTwoPrincipalId: appServices.outputs.serviceTwoPrincipalId
    serviceThreePrincipalId: appServices.outputs.serviceThreePrincipalId
    serviceFourPrincipalId: appServices.outputs.serviceFourPrincipalId
    serviceFivePrincipalId: appServices.outputs.serviceFivePrincipalId
    vnetSubnet2ResourceId: vnet.outputs.subnet2ResourceId
    vnetSubnet3ResourceId: vnet.outputs.subnet3ResourceId
    allowedIPs: allowedIPs
  }
}

module vnet 'modules/vnet.bicep' = {
  name: '${solutionName}${environmentName}vnet'
  params: {
    location: location
    nsgId: nsg.outputs.nsgId
    tags: tags
    solutionPrefix: '${solutionName}-${environmentName}'
  }
}

module nsg 'modules/nsg.bicep' = {
  name: '${solutionName}${environmentName}nsg'
  params: {
    location: location
    tags: tags
    solutionPrefix: '${solutionName}-${environmentName}'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${solutionName}${environmentName}loganalyticsworkspace'
  location: location
  tags: tags
  properties: {
    features: {
      immediatePurgeDataOn30Days: true
    }
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

resource diagnosticLogsAppServicePlan 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: appServicePlan.name
  scope: appServicePlan
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 5
          enabled: true 
        }
      }
    ]
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${solutionName}${environmentName}appinsights'
  location: location
  tags: tags
  kind: 'string'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
