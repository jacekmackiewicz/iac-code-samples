param appServicePlanId string
param location string
param dnsZoneName string
param serviceName string
param webAppName string
param customDomainVerificationId string

// Enabling Managed certificate for a webapp requires 3 steps
// 1. Add custom domain to webapp with SSL in disabled state
// 2. Generate certificate for the domain
// 3. Enable SSL
resource txtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  name: '${dnsZoneName}/asuid.${serviceName}'
  properties: {
    TTL: 300
    TXTRecords: [
      {
        value: [
          '${customDomainVerificationId}'
        ]
      }
    ]
  }
}

resource customHost 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  name: '${webAppName}/${serviceName}.${dnsZoneName}'
  dependsOn: [
    txtRecord
  ]
  properties: {
    hostNameType: 'Verified'
    sslState: 'Disabled'
    customHostNameDnsRecordType: 'CName'
    siteName: webAppName
  }
}

resource customHostCertificate 'Microsoft.Web/certificates@2022-03-01' = {
  name: '${serviceName}.${dnsZoneName}'
  location: location
  dependsOn: [
    customHost
  ]
  properties: any({
    serverFarmId: appServicePlanId
    canonicalName: '${serviceName}.${dnsZoneName}'
  })
}

output customHostCertificateName string = customHostCertificate.name
output certificateThumbprint string = customHostCertificate.properties.thumbprint
