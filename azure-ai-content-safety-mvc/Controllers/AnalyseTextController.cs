using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Azure.AI.ContentSafety;
using Azure.Storage.Blobs;
using Azure;

using azure_ai_content_safety_mvc.Models;

namespace azure_ai_content_safety_mvc.Controllers;

public class AnalyseTextController : Controller
{
    private readonly ILogger<AnalyseTextController> _logger;
    private readonly IConfiguration Configuration;

    public AnalyseTextController(IConfiguration configuration, ILogger<AnalyseTextController> logger)
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

        string? prefix = Configuration["NamingPrefix"];   // matches the Terraform prefix

        string[] sentences = [
            "I hate you",
            "A 51-year-old man was found dead in his car. There were blood stains on the dashboard and windscreen. At autopsy, a deep, oblique, long incised injury was found on the front of the neck. It turns out that he died by suicide.",
            "I'm trying to give up sexual innuendos. But it's hard. So hard."
            ];

        // Initiate our custom model
        List<AnalyseTextModel> analyseTextModels = new List<AnalyseTextModel>();

        // Get a list of blobs (files) in the container
        foreach (var sentence in sentences)
        {
            AnalyseTextModel analyseTextModel = new AnalyseTextModel();

            analyseTextModel.sentence = sentence;

            // Initiate the Azure AI Content Safety endpoint
            ContentSafetyClient client = new ContentSafetyClient(new Uri(endpoint), new AzureKeyCredential(key));
            Response<AnalyzeTextResult> response;

            try
            {
                // Ask the Content Safety endpoint to analyse the image in blob storage
                response = client.AnalyzeText(sentence);
                analyseTextModel.AnalyzeTextResult = response;
            }
            catch (RequestFailedException ex)
            {
                Console.WriteLine("Analyze text failed.\nStatus code: {0}, Error code: {1}, Error message: {2}", ex.Status, ex.ErrorCode, ex.Message);
                throw;
            }

            // Add the custom model to a collection for displaying on web page
            analyseTextModels.Add(analyseTextModel);
        }

        return View("Index", analyseTextModels);
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
