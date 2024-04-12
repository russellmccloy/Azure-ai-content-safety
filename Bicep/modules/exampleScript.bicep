// *****************************************************************************************************
// Note: the code in this file is not used, I was just playing around with running a script from Bicep *
// *****************************************************************************************************


param storageAccountName string
param resourceGroupName string
param containerName string

param location string = resourceGroup().location

param roleDefinition string = 'Contributor' // TODO: think about changing this to the reader level

var roles = {
  // See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for these mappings and more.
  'Contributor': '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
}

var roleDefinitionId = roles[roleDefinition]

resource storageAcct 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource userIdForExampleScript 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'userIdForExampleScript'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('script-rbac', userIdForExampleScript.id, resourceGroup().id, 'abc1234567', roleDefinitionId)
  scope: storageAcct
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: reference(userIdForExampleScript.id, '2023-07-31-preview').principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'inlinePowerShellScript'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdForExampleScript.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '10.0'
    arguments: '-storageAccountName ${storageAccountName} -resourceGroupName ${resourceGroupName} -containerName ${containerName}'
    scriptContent: '''
      param(
        [string] $storageAccountName,
        [string] $resourceGroupName,
        [string] $containerName
      )

      Write-Output 'Starting to upload images to Storage Account'

      $localImagePath = "C:\Users\russe\code\azure-ai-content-safety\offensive_images"

      # Get the storage account context
      $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
      $ctx = $storageAccount.Context

      $containersList = Get-AzStorageContainer -Context $ctx
      $containersList

      $output = '{0}' -f $containersList
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['text'] = $output
    '''
    retentionInterval: 'PT1H'
  }
}

output result string = deploymentScript.properties.outputs.text
