using Azure.Storage.Blobs;
using System;
using System.IO;
using System.Threading.Tasks;

namespace UploadFilesToAzureStorageAccount;

// NOTE: Make sure you run this first: `dotnet add package Azure.Storage.Blobs`
class Program
{
    static async Task Main(string[] args)
    {
        // Storage account and container details
        // ============================================================================
        string storageAccountName = "<ENTER YOUR STORAGE ACCOUNT NAME HERE>";
        string storageAccountKey = "<ENTER YOUR STORAGE ACCOUNT KEY HERE>";

        string connectionString = "DefaultEndpointsProtocol=https;AccountName=" + storageAccountName + ";AccountKey=" + storageAccountKey + ";EndpointSuffix=core.windows.net";
        string containerName = prefix + "-dev-images";  // The name of the container inside the storage account
        // ============================================================================

        // Enter the full, absolute path the the `offensive_images` folder
        string folderPath = @"C:\Users\russe\code\azure-ai-content-safety\offensive_images";

        // Check if the folder exists
        if (Directory.Exists(folderPath))
        {
            // Get all files in the folder
            string[] files = Directory.GetFiles(folderPath);

            BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);
            BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(containerName);

            // Create the container if it doesn't exist
            await containerClient.CreateIfNotExistsAsync();

            // Loop through each file and upload
            foreach (string file in files)
            {
                Console.WriteLine(file);
                string fileName = Path.GetFileName(file);
                BlobClient blobClient = containerClient.GetBlobClient(Path.GetFileName(file));

                // Upload the file
                using (FileStream fileStream = File.OpenRead(file))
                {
                    await blobClient.UploadAsync(fileStream, true);
                }

                Console.WriteLine("File uploaded successfully.");
            }
        }
        else
        {
            Console.WriteLine("The specified folder does not exist.");
        }

    }
}
