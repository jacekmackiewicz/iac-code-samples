@description('The name of the DNS zone to be created.  Must have at least 2 segments, e.g. hostname.org')
param zoneName string = 'project.domain.com'

resource zone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: zoneName
  location: 'global'
}

resource recorddev 'Microsoft.Network/dnsZones/NS@2018-05-01' = {
  parent: zone
  name: 'dev'
  properties: {
    TTL: 300
    NSRecords: [
      {
        nsdname: 'ns1-09.azure-dns.com.'
      }
      {
        nsdname: 'ns2-09.azure-dns.net.'
      }
      {
        nsdname: 'ns3-09.azure-dns.org.'
      }
      {
        nsdname: 'ns4-09.azure-dns.info.'
      }
    ]
  }
}

resource recorddemo 'Microsoft.Network/dnsZones/NS@2018-05-01' = {
  parent: zone
  name: 'demo'
  properties: {
    TTL: 300
    NSRecords: [
      {
        nsdname: 'ns1-02.azure-dns.com.'
      }
      {
        nsdname: 'ns2-02.azure-dns.net.'
      }
      {
        nsdname: 'ns3-02.azure-dns.org.'
      }
      {
        nsdname: 'ns4-02.azure-dns.info.'
      }
    ]
  }
}

output nameServers array = zone.properties.nameServers
