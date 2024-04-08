using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Azure.AI.ContentSafety;
using Azure.Storage.Blobs;
using Azure;

using azure_ai_content_safety_mvc.Models;

namespace azure_ai_content_safety_mvc.Controllers;

public class AnalyseImagesController : Controller
{
    private readonly ILogger<AnalyseImagesController> _logger;
    private readonly IConfiguration Configuration;

    public AnalyseImagesController(IConfiguration configuration, ILogger<AnalyseImagesController> logger)
    {
        _logger = logger;
        Configuration = configuration;
    }

    public async Task<ActionResult> Index()
    {
        _logger.LogInformation("Starting ...");

        // Get these two values from config
        string? endpoint = Configuration["ContentSafetyEndpoint"];
        string? key = Configuration["ContentSafetyKey"];

        string? storageAccountName = Configuration["StorageAccountName"];
        string? storageAccountKey = Configuration["StorageAccountKey"];

        string? prefix = Configuration["NamingPrefix"];   // matches the Terraform prefix

        string connectionString = "DefaultEndpointsProtocol=https;AccountName=" + storageAccountName + ";AccountKey=" + storageAccountKey + ";EndpointSuffix=core.windows.net";
        string containerName = prefix + "-dev-images";  // The name of the container inside the storage account

        // Create a BlobServiceClient object which will be used to create a container client
        BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);

        // Get a reference to a container
        BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(containerName);

        // Initiate our custom model
        List<AnalyseImagesModel> analyseImagesModels = new List<AnalyseImagesModel>();

        // Get a list of blobs (files) in the container
        await foreach (var blobItem in containerClient.GetBlobsAsync())
        {
            // Assuming that you're interested in only images
            if (blobItem.Name.EndsWith(".jpg") || blobItem.Name.EndsWith(".jpeg") || blobItem.Name.EndsWith(".png"))
            {
                BlobClient blobClient = containerClient.GetBlobClient(blobItem.Name);

                AnalyseImagesModel analyseImagesModel = new AnalyseImagesModel
                {
                    BlobClient = blobClient
                };

                // Initiate the Azure AI Content Safety endpoint
                ContentSafetyClient client = new ContentSafetyClient(new Uri(endpoint), new AzureKeyCredential(key));
                Response<AnalyzeImageResult> response;

                try
                {
                    // Ask the Content Safety endpoint to analyse the image in blob storage
                    response = client.AnalyzeImage(blobClient.Uri);
                    analyseImagesModel.AnalyzeImageResult = response;
                }
                catch (RequestFailedException ex)
                {
                    Console.WriteLine("Analyze image failed.\nStatus code: {0}, Error code: {1}, Error message: {2}", ex.Status, ex.ErrorCode, ex.Message);
                    throw;
                }

                // Add the custom model to a collection for displaying on web page
                analyseImagesModels.Add(analyseImagesModel);
            }
        }

        return View("Index", analyseImagesModels);
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
