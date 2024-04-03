# Azure AI Content Safety

Please see the related blog post here for all the information you need: [https://russellmccloy.github.io/????-azure-ai-content-safety](https://russellmccloy.github.io/????-azure-ai-content-safety/) // TODO: fix the url in this line of text

## Things to note

- Remember to update the `appsettings.Development.json` file with your search API key and service name // TODO: change this line
  
```json // TODO: change this line
{
  "AzureAISearchApiKey": "<SET_YOUR_SEARCH_SERVICE_API_KEY_HERE>",  // TODO: change this line
  "AzureAISearchService": "<SET_YOUR_SEARCH_SERVICE_NAME_HERE>",    // TODO: change this line
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

- The MVC code is just thrown together and I didn't put much effort into it as it's just used to display text and images. // TODO: change this line



