namespace azure_ai_content_safety_mvc.Models;

public class AnalyseTextModel
{
    public string sentence {get;set; }
    public Azure.AI.ContentSafety.AnalyzeTextResult AnalyzeTextResult { get; set; }
}
