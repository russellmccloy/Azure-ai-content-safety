param name string
param location string
param sku string
param environment string

resource contentSafetyInstance 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {

  name: name
  location: location
  sku: {
    name: sku
  }

  kind: 'ContentSafety'

  properties: {}

  identity: {
    type: 'SystemAssigned'
  }

  tags: {
    environment: environment
  }
}

output contentSafetyInstanceId string = contentSafetyInstance.id
output identityPrincipalId string = contentSafetyInstance.identity.principalId
