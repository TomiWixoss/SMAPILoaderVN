using SMAPIGameLoader.Launcher;
using SMAPIGameLoader.Tool;
using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace SMAPIGameLoader.Services
{
    /// <summary>
    /// Service for SMAPI-related operations
    /// </summary>
    public class SmapiService : ISmapiService
    {
        private static readonly HttpClient _httpClient = new HttpClient();

        public bool IsSmapiInstalled => SMAPIInstaller.IsInstalled;

        public string GetSmapiVersion()
        {
            return SMAPIInstaller.GetCurrentVersion()?.ToString() ?? "Not installed";
        }

        public Task InstallSmapiAsync(string filePath)
        {
            return Task.Run(() =>
            {
                if (string.IsNullOrEmpty(filePath))
                {
                    throw new ArgumentException("File path is required", nameof(filePath));
                }

                if (!File.Exists(filePath))
                {
                    throw new FileNotFoundException("SMAPI ZIP file not found", filePath);
                }

                // Validate it's a SMAPI ZIP file (reuse existing validation logic)
                var fileName = Path.GetFileName(filePath);
                if (!fileName.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
                {
                    throw new InvalidOperationException("File must be a ZIP file");
                }

                if (!fileName.StartsWith("SMAPI-", StringComparison.OrdinalIgnoreCase) && 
                    !fileName.StartsWith("SMAPI_", StringComparison.OrdinalIgnoreCase))
                {
                    throw new InvalidOperationException("Invalid SMAPI file. Please select a SMAPI-4.x.x.zip file for Android");
                }

                var fileInfo = new FileInfo(filePath);
                if (FileTool.ConvertBytesToMB(fileInfo.Length) > 30)
                {
                    throw new InvalidOperationException("File too large. Android SMAPI should be less than 30MB");
                }

                // Use existing SMAPIInstaller logic - just call the static method
                using (var zip = System.IO.Compression.ZipFile.OpenRead(filePath))
                {
                    var stardewDir = GameAssemblyManager.AssembliesDirPath;
                    Directory.CreateDirectory(stardewDir);

                    foreach (var entry in zip.Entries)
                    {
                        string entryDirName = Path.GetDirectoryName(entry.FullName);
                        if (string.IsNullOrEmpty(entryDirName))
                            continue;

                        string[] directoryNames = entryDirName.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
                        if (directoryNames.Length == 0)
                            continue;

                        var rootDirName = directoryNames[0];
                        var newEntryFileName = entry.FullName.Remove(0, rootDirName.Length + 1);
                        
                        if (string.IsNullOrEmpty(newEntryFileName))
                            continue;

                        var destExtractFilePath = Path.Combine(stardewDir, newEntryFileName);
                        ZipFileTool.Extract(entry, destExtractFilePath);
                    }
                }

                FileTool.ClearCache();
            });
        }

        public async Task<string> UploadLogAsync()
        {
            var logPath = Path.Combine(ModTool.ModsDir, "SMAPI-latest.txt");
            if (!File.Exists(logPath))
            {
                throw new FileNotFoundException("SMAPI log file not found");
            }

            try
            {
                var logContent = await File.ReadAllTextAsync(logPath);
                
                // Upload to smapi.io/log
                var content = new StringContent(logContent, Encoding.UTF8, "text/plain");
                var response = await _httpClient.PostAsync("https://smapi.io/log", content);
                
                if (!response.IsSuccessStatusCode)
                {
                    throw new HttpRequestException($"Failed to upload log: {response.StatusCode}");
                }

                var responseText = await response.Content.ReadAsStringAsync();
                
                // Parse response to get log URL
                // The API returns JSON with a "url" field
                var urlStart = responseText.IndexOf("\"url\":\"") + 7;
                var urlEnd = responseText.IndexOf("\"", urlStart);
                var url = responseText.Substring(urlStart, urlEnd - urlStart);
                
                return url;
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"Failed to upload log: {ex.Message}", ex);
            }
        }
    }
}
