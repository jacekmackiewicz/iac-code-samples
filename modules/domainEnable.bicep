param webAppName string
param webAppHostname string
param certificateThumbprint string

resource webAppCustomHostEnable 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  name: '${webAppName}/${webAppHostname}'
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}
