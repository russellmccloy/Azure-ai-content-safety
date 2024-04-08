# Azure AI Content Safety

Please see the related blog post here for all the information you need: [https://russellmccloy.github.io/????-azure-ai-content-safety](https://russellmccloy.github.io/????-azure-ai-content-safety/) // TODO: fix the url in this line of text

## Things to note

- Remember to update the `appsettings.Development.json` file with your Content Safety endpoint,  API key and storage account settings
  
```json
{
  "ContentSafetyEndpoint": "<ENTER_YOUR_CONTENT_SAFETY_ENDPOINT_HERE>",
  "ContentSafetyKey": "<ENTER_YOUR_CONTENT_SAFETY_KEY_HERE>",
  "StorageAccountName": "<ENTER_THE_NAME_OF_YOUR_STORAGE_ACCOUNT>",
  "StorageAccountKey": "<ENTER_YOUR_STORAGE_ACCOUNT_KEY>",
  "NamingPrefix": "rdmc03",
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

// TODO: write something here