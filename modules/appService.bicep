param location string
param tags object
param dotnetEnvironment string
param solutionPrefix string
param appServicePlanId string
param appInsightsConnectionString string
param vnetSubnet3ResourceId string
param dnsZoneName string
param allowedIPs array

var allowedIPSecurityRestrictions = [ for instance in allowedIPs: {
  ipAddress: instance.ipAddress
  action: 'Allow'
  tag: 'Default'
  priority: instance.priority
  name: instance.name
}]

var allowvnetSubnet3 = [{
  vnetSubnetResourceId: vnetSubnet3ResourceId
  action: 'Allow'
  tag: 'Default'
  priority: 90
  name: 'AllowServiceEndpoints'
}]

output serviceOnePrincipalId string = serviceOne.identity.principalId
output serviceTwoPrincipalId string = serviceTwo.identity.principalId
output serviceThreePrincipalId string = serviceThree.identity.principalId
output serviceFourPrincipalId string = serviceFour.identity.principalId
output serviceFivePrincipalId string = serviceFive.identity.principalId

resource serviceOne 'Microsoft.Web/sites@2022-03-01' = {
  name: '${solutionPrefix}-service-one'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    virtualNetworkSubnetId: vnetSubnet3ResourceId
    siteConfig: {
      alwaysOn: true
      linuxFxVersion: 'DOTNETCORE|6.0'
      appCommandLine: 'dotnet AnB.GridCalculator.Api.dll'
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'DOTNET_ENVIRONMENT'
          value: dotnetEnvironment
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
      ]
      ipSecurityRestrictions: concat(allowvnetSubnet3,allowedIPSecurityRestrictions)   
    }
  }
}

//-------------------------------------------------------------------------------------------------
module serviceOneDomainBinding './domainBinding.bicep' = {
  name: '${deployment().name}-service-one-domain-bind'
  params: {
    appServicePlanId: appServicePlanId
    location: location
    dnsZoneName: dnsZoneName
    serviceName: 'service-one'
    webAppName: serviceOne.name
    customDomainVerificationId: serviceOne.properties.customDomainVerificationId
  }
}

// We need to use a module to enable sni, as ARM forbids using resource with this same type-name combination twice in one deployment.
module serviceOneCustomHostEnable './domainEnable.bicep' = {
  name: '${deployment().name}-service-one-sni-enable'
  dependsOn: [
    serviceOneDomainBinding
  ]
  params: {
    webAppName: serviceOne.name
    webAppHostname: serviceOneDomainBinding.outputs.customHostCertificateName
    certificateThumbprint: serviceOneDomainBinding.outputs.certificateThumbprint
  }
}
//-------------------------------------------------------------------------------------------------
