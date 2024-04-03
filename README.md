# Azure AI Content Safety

Please see the related blog post here for all the information you need: [https://russellmccloy.github.io/????-azure-ai-content-safety](https://russellmccloy.github.io/????-azure-ai-content-safety/) // TODO: fix the url in this line of text

## Things to note

- Remember to update the `appsettings.Development.json` file with your Content Safety endpoint and  API key
  
```json 
{
  "Endpoint": "https://australiaeast.api.cognitive.microsoft.com/contentsafety/text:analyze?api-version=2023-10-01",  // <===== Mine looks like this
  "ContentSafetyAPIKey": "<put_your_content_safety_api_key_here>",
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}

```

- The MVC code is just thrown together and I didn't put much effort into it as it's just used to display text and images. // TODO: change this line



