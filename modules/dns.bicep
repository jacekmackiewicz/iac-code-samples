param environmentName string

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: '${environmentName}.globaldomain.com'
  location: 'global'
}

resource recordCnameServiceOne 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 'service-one'
  properties: {
    TTL: 300
    CNAMERecord: {
      cname: '${projectName}-${environmentName}-service-one.azurewebsites.net'
    }
  }
}

resource recordCnameServiceTwo 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 'service-two'
  properties: {
    TTL: 300
    CNAMERecord: {
      cname: '${projectName}-${environmentName}-service-two.azurewebsites.net'
    }
  }
}

resource recordCnameServiceThree 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 'service-three'
  properties: {
    TTL: 300
    CNAMERecord: {
      cname: '${projectName}-${environmentName}-service-three.azurewebsites.net'
    }
  }
}

resource recordCnameServiceFour 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 'service-four'
  properties: {
    TTL: 300
    CNAMERecord: {
      cname: '${projectName}-${environmentName}-service-four.azurewebsites.net'
    }
  }
}

resource recordCnameServiceFive 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 'service-five'
  properties: {
    TTL: 300
    CNAMERecord: {
      cname: '${projectName}-${environmentName}-service-five.azurewebsites.net'
    }
  }
}

output dnsZoneName string = dnsZone.name
