param storageName string
param storageLocation string
param storageContainerName string
param environment string
param roleAssignmenPrincipalId string

param roleId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource storageAcct 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: storageLocation

  kind: 'StorageV2'

  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Cool'
  }

  tags: {
    environment: environment
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAcct
}

// Storage Container
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: storageContainerName
  parent: blobService
  properties: {
    publicAccess: 'None' // for this proof of concept the container type not private but it should be to ensure the security of your documents
  }
}

@description('This is the built-in Storage Blob Data Contributor role. See https://learn.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles/storage#storage-blob-data-contributor')
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: roleId
}

// Role Assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAcct.id, '7ba0f919-d01c-428b-b5d9-af2a95a2aafb', contributorRoleDefinition.id)
  scope: storageAcct
  properties: {
    roleDefinitionId:  contributorRoleDefinition.id
    principalId: guid(roleAssignmenPrincipalId)
    principalType: 'ServicePrincipal'
  }
}

output storageAcctId string = storageAcct.id
