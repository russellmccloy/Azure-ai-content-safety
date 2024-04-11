targetScope='subscription'

// General
param general object

param resourceGroup object

// Content Safety
param contentSafety object

param storageAccountAndContainer object


@description('Combining the unique prefixName and the environment to make it easier to read')
var prefix = '${general.prefixName}-${general.environment}'

resource contentSafetyResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${prefix}-${resourceGroup.name}'
  location: general.location
}

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

module storageModule 'modules/storage.bicep' = {
  name: 'storageModule'
  scope: contentSafetyResourceGroup
  params: {
    storageName: '${replace(prefix, '-', '')}${storageAccountAndContainer.name}'
    storageLocation: storageAccountAndContainer.location
    storageContainerName: '${prefix}-${storageAccountAndContainer.containerName}'
    environment: general.environment
    roleAssignmenPrincipalId: contentSafetyModule.outputs.identityPrincipalId
  }
}

output contentSafetyInstanceId string = contentSafetyModule.outputs.contentSafetyInstanceId
output identityPrincipalId string = contentSafetyModule.outputs.identityPrincipalId
