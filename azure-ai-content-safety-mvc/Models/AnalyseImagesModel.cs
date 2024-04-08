namespace azure_ai_content_safety_mvc.Models;

public class AnalyseImagesModel
{
    public Azure.Storage.Blobs.BlobClient BlobClient { get; set; }

    public Azure.AI.ContentSafety.AnalyzeImageResult AnalyzeImageResult { get; set; }
}
