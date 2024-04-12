param storageName string
param storageLocation string
param storageContainerName string

@description('The current environment being deployed')
param environment string

@description('The principalId of the Azure AI Content Safety Instance')
param principalId string

@description('The role that the identity of the Azure AI Content Safety instance has on the storage account')
param roleDefinition string = 'Storage Blob Data Contributor' // TODO: think about changing this to the reader level

var roles = {
  // See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for these mappings and more.
  'Storage Blob Data Contributor': '/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  // NOTE: You can add more roles here
}

@description('The actual Id of the named role defintion')
var roleDefinitionId = roles[roleDefinition]

resource storageAcct 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: storageLocation

  kind: 'StorageV2'

  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Cool'
    allowBlobPublicAccess: true // for this proof of concept the container type not private but it should be to ensure the security of your documents
  }

  tags: {
    environment: environment
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAcct
}

@description('The Storage Container to hold the images for Azure AI Content Safety to analyse')
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: storageContainerName
  parent: blobService

  properties: {
    publicAccess: 'Container' // for this proof of concept the container type not private but it should be to ensure the security of your documents
  }
}

@description('The role assignment that the identity of the Azure AI Content Safety instance has on the storage account')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // Generate a unique but deterministic resource name
  name: guid('storage-rbac', storageAcct.id, resourceGroup().id, principalId, roleDefinitionId)
  scope: storageAcct
  properties: {
      principalId: principalId              // The principalId of the Azure AI Content Safety Instance
      roleDefinitionId: roleDefinitionId    // Storage Blob Data Contributor
      principalType: null                   // We don't need this as we are using the System Assigned Identity 
  }
}

output storageAcctId string = storageAcct.id
output storageAcctName string = storageAcct.name
output storageContainerName string = storageContainer.name
