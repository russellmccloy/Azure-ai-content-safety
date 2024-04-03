using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Azure.AI.ContentSafety;
using Microsoft.Extensions.Configuration;

using azure_ai_content_safety_mvc.Models;
using Azure;

namespace azure_ai_content_safety_mvc.Controllers;

public class AnalyseTextController : Controller
{
    private readonly IConfiguration Configuration;
    private readonly ILogger<AnalyseTextController> _logger;

    public AnalyseTextController(IConfiguration configuration, ILogger<AnalyseTextController> logger)
    {
        Configuration = configuration;
        _logger = logger;
    }

    public IActionResult Index()
    {
        // Get these two values from config
        string? endpoint = Configuration["Endpoint"];
        string? key = Configuration["Key"];


        ContentSafetyClient client = new ContentSafetyClient(new Uri(endpoint), new AzureKeyCredential(key));

        string text = "Your input text";
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
