targetScope='subscription'

@description('Some data that are used globally throughout the code')
param general object

@description('Some data relating to just the resource group')
param resourceGroup object

@description('Some data relating to just the Azure AI Content Safety instance')
param contentSafety object

@description('Some data relating to just the storage account and container')
param storageAccountAndContainer object

@description('Combining the unique prefixName and the environment to make it easier to read for all resources and storage account which has a more limited naming convention')
var prefix = '${general.prefixName}-${general.environment}'
var storagePrefix = replace(prefix, '-', '') // Storage can't have hiphens in the name

@description('The resource group to hold all the resources')
resource contentSafetyResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${prefix}-${resourceGroup.name}'
  location: general.location
}

@description('The module relating to the Azure AI Content Safety instance')
module contentSafetyModule 'modules/contentSafety.bicep' = {
  name: 'contentSafetyModule'
  scope: contentSafetyResourceGroup
  params: {
    name: '${prefix}-${contentSafety.name}'
    location: general.location
    sku: contentSafety.sku
    environment: general.environment
  }
}

@description('The module relating to the storage account and all related items')
module storageModule 'modules/storage.bicep' = {
  name: 'storageModule'
  scope: contentSafetyResourceGroup
  params: {
    storageName: '${storagePrefix}${storageAccountAndContainer.name}'
    storageLocation: general.location
    storageContainerName: '${prefix}-${storageAccountAndContainer.containerName}'
    environment: general.environment
    principalId: contentSafetyModule.outputs.identityPrincipalId
  }
}

output contentSafetyInstanceId string = contentSafetyModule.outputs.contentSafetyInstanceId
output identityPrincipalId string = contentSafetyModule.outputs.identityPrincipalId
