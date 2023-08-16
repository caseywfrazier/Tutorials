using '../main.bicep'

// param appServicePlanInstanceCount = 3
param appServicePlanSku = {
  name: 'F1'
  tier: 'Free'
}
param sqlDatabaseSku = {
  name: 'Standard'
  tier: 'Standard'
}

// as of 8/16/23 kv secrets cannot be referenced in a .bicepparam file 
//as per https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/key-vault-parameter?tabs=azure-cli#reference-secrets-in-parameters-file

// unless you use this: kv secret support added in https://github.com/Azure/bicep/pull/11236
// getSecret('<subscriptionId>', '<resourceGroupName>', '<keyVaultName>', '<secretName>')
// strings are hardcoded and duplicated
// param sqlServerAdministratorLogin = getSecret('3f823f67-c938-4a0e-9189-a6c7d521b953', 'learn-71c3162b-2c2b-463f-a504-fa93fcf77a0c', 'dev-6fu7jm7wiutxu-kv', 'sqlServerAdministratorLogin')
// param sqlServerAdministratorPassword = getSecret('3f823f67-c938-4a0e-9189-a6c7d521b953', 'learn-71c3162b-2c2b-463f-a504-fa93fcf77a0c', 'dev-6fu7jm7wiutxu-kv', 'sqlServerAdministratorPassword')

// or create a separate module for each resource that needs to reference a KV secret
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-resource#getsecret

// these 3 strings are needed to identify the KeyVault that is referenced in main.bicep
// param subscriptionId = '3f823f67-c938-4a0e-9189-a6c7d521b953'
// param kvResourceGroup = 'learn-71c3162b-2c2b-463f-a504-fa93fcf77a0c'
// param kvName = 'dev-6fu7jm7wiutxu-kv'

// or you can use a single string, and split it apart using variables in main.bicep
param kvResourceId = '/subscriptions/3f823f67-c938-4a0e-9189-a6c7d521b953/resourceGroups/learn-71c3162b-2c2b-463f-a504-fa93fcf77a0c/providers/Microsoft.KeyVault/vaults/dev-6fu7jm7wiutxu-kv'
