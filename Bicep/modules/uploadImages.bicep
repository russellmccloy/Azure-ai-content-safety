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

resource userIdForScript 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'userIdForScript'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('script-rbac', userIdForScript.id, resourceGroup().id, 'abc1234567', roleDefinitionId)
  scope: storageAcct
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: reference(userIdForScript.id, '2023-07-31-preview').principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'inlinePS'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdForScript.id}': {}
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

      # Get the list of image files in the local directory # -Filter *.jpg,*.jpeg,*.png,*.gif
      $imageFiles = Get-ChildItem -Path $localImagePath 

      Write-Output "There are $($imageFiles.Length) images to upload"
      
      # Upload each image to Azure Blob Storage
      foreach ($imageFile in $imageFiles) {

        Write-Output "Uploading $($imageFile.Name) ..."

        $blobName = $imageFile.Name
        $blob = Set-AzStorageBlobContent -File $imageFile.FullName -Container $containerName -Blob $blobName -Context $ctx -Force
        Write-Output "Uploaded $($imageFile.Name) to Azure Blob Storage."
      }

      $output = 'The images were uploaded to the Storage Account: {0}' -f $storageAccountName
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['text'] = $output
    '''
    retentionInterval: 'PT1H'
  }
}

output result string = deploymentScript.properties.outputs.text
