@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The unique name of hte solution. This is used to ensure that resource names are unique.')
@minLength(5)
@maxLength(30)
param solutionName string = 'toyhr-${uniqueString(resourceGroup().id)}'

@description('The number of App Service plan instances.')
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@description('The name and tier of the App Service plan SKU.')
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}

@description('The Azure region into which the resources should be deployed.')
param location string = 'westus3' //normally would use resourceGroup().location

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}-${solutionName}-sql'
var sqlDatabaseName = 'Employees'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

// param subscriptionId string
// param kvResourceGroup string
// param kvName string

@description('The full resourceId string of the KeyVault resource that contains the sql server credential secrets')
param kvResourceId string
var kvResourceIdSplit = split(kvResourceId, '/')
var subscriptionId = kvResourceIdSplit[2]
var kvResourceGroup = kvResourceIdSplit[4]
var kvName = last(kvResourceIdSplit)

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: kvName
  scope: resourceGroup(subscriptionId, kvResourceGroup)
}

module sql './sql-server.bicep' = {
  name: 'deploySQL'
  params: {
    sqlServerName: sqlServerName
    location: location
    sqlServerAdministratorLogin: keyVault.getSecret('sqlServerAdministratorLogin')
    sqlServerAdministratorPassword: keyVault.getSecret('sqlServerAdministratorPassword')
    sqlDatabaseName: sqlDatabaseName
    sqlDatabaseSku: sqlDatabaseSku
  }
}
