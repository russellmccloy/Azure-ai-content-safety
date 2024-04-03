using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Azure.AI.ContentSafety;
using azure_ai_content_safety_mvc.Models;

namespace azure_ai_content_safety_mvc.Controllers;

public class AnalyseImagesController : Controller
{
    private readonly ILogger<AnalyseImagesController> _logger;

    public AnalyseImagesController(ILogger<AnalyseImagesController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index()
    {
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
