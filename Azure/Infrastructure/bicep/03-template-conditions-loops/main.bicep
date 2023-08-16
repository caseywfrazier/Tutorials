@description('The Azure regions into which the resources should be deployed.')
param locations array = [
  'westeurope'
  'eastus2'
  'eastasia'
]

//commenting out in favor of getting secrets from keyvault
//@secure()
//@description('The administrator login username for the SQL server.')
//param sqlServerAdministratorLogin string

//@secure()
//@description('The administrator login password for the SQL server.')
//param sqlServerAdministratorLoginPassword string

@description('The IP address range for all virtual networks to use.')
param virtualNetworkAddressPrefix string = '10.10.0.0/16'

@description('The name and IP address range for each subnet in the virtual networks.')
param subnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.5.0/24'
  }
  {
    name: 'backend'
    ipAddressRange: '10.10.10.0/24'
  }
]

@description('The resource ID of a keyvault with sql server credentials')
param kvResourceId string = '/subscriptions/2eb288f0-205d-43c5-9356-449b90daee2e/resourceGroups/learn-588a3fc5-cb7e-4c2e-8fc0-c6ecf3d73e6f/providers/Microsoft.KeyVault/vaults/dev-6fu7jm7wiutxu2-kv'

var kvResourceIdSplit = split(kvResourceId, '/')
var subscriptionId = kvResourceIdSplit[2]
var kvResourceGroup = kvResourceIdSplit[4]
var kvResourceName = last(kvResourceIdSplit)

// variable loops are awesome - take a simple input object and transform it into something more complex
var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}]

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: kvResourceName
  scope: resourceGroup(subscriptionId, kvResourceGroup)
}

module databases 'modules/database.bicep' = [for location in locations: {
  name: 'database-${location}' //maps to deployment name in azure portal
  params: {
    location: location
    sqlServerAdministratorLogin: keyVault.getSecret('sqlServerAdministratorLogin')
    sqlServerAdministratorLoginPassword: keyVault.getSecret('sqlServerAdministratorPassword')
  }
}]

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2021-08-01' = [for location in locations: {
  name: 'teddybear-${location}'
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        virtualNetworkAddressPrefix
      ]
    }
    subnets: subnetProperties
  }
}]

//have to use this weird array indexing currently
output serverInfo array = [for i in range(0, length(locations)): {
  name: databases[i].outputs.serverName
  location: databases[i].outputs.location
  fullyQualifiedDomainName: databases[i].outputs.serverFQDN
}]
