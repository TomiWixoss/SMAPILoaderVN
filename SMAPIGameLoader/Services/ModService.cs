using Android.Content;
using SMAPIGameLoader.Launcher;
using SMAPIGameLoader.Tool;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Threading.Tasks;

namespace SMAPIGameLoader.Services
{
    /// <summary>
    /// Service for mod management operations
    /// </summary>
    public class ModService : IModService
    {
        private readonly Context _context;

        public ModService(Context context)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
        }

        public Task<List<Dictionary<string, object>>> GetModListAsync()
        {
            return Task.Run(() =>
            {
                var modList = new List<Dictionary<string, object>>();

                if (!Directory.Exists(ModTool.ModsDir))
                {
                    return modList;
                }

                var modDirs = Directory.GetDirectories(ModTool.ModsDir);
                foreach (var modDir in modDirs)
                {
                    try
                    {
                        var manifestPath = Path.Combine(modDir, "manifest.json");
                        if (!File.Exists(manifestPath))
                            continue;

                        var manifestText = File.ReadAllText(manifestPath);
                        var manifest = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(manifestText);

                        if (manifest == null)
                            continue;

                        var modInfo = new Dictionary<string, object>
                        {
                            ["id"] = manifest.GetValueOrDefault("UniqueID", Path.GetFileName(modDir))?.ToString() ?? "",
                            ["name"] = manifest.GetValueOrDefault("Name", "Unknown")?.ToString() ?? "Unknown",
                            ["version"] = manifest.GetValueOrDefault("Version", "0.0.0")?.ToString() ?? "0.0.0",
                            ["author"] = manifest.GetValueOrDefault("Author", null)?.ToString(),
                            ["description"] = manifest.GetValueOrDefault("Description", null)?.ToString(),
                            ["isEnabled"] = true,
                            ["iconPath"] = null
                        };

                        modList.Add(modInfo);
                    }
                    catch
                    {
                        // Skip invalid mods
                        continue;
                    }
                }

                return modList;
            });
        }

        public Task InstallModAsync(string filePath)
        {
            return Task.Run(() =>
            {
                if (string.IsNullOrEmpty(filePath))
                {
                    throw new ArgumentException("File path is required", nameof(filePath));
                }

                if (!File.Exists(filePath))
                {
                    throw new FileNotFoundException("Mod file not found", filePath);
                }

                if (!Directory.Exists(ModTool.ModsDir))
                {
                    Directory.CreateDirectory(ModTool.ModsDir);
                }

                // Use existing ModInstaller logic
                using var zip = ZipFile.OpenRead(filePath);
                var entries = zip.Entries;
                var manifestEntries = entries.Where(entry => entry.Name == ModTool.ManifiestFileName).ToArray();
                
                if (manifestEntries.Length == 0)
                {
                    throw new InvalidOperationException("Invalid mod: manifest.json not found");
                }

                // Use existing extract logic from ModInstaller
                ModInstaller.ExtractModZipFile(filePath, zip, ModTool.ModsDir);
                
                FileTool.ClearCache();
            });
        }

        public Task DeleteModAsync(string modId)
        {
            return Task.Run(() =>
            {
                if (string.IsNullOrEmpty(modId))
                {
                    throw new ArgumentException("Mod ID is required", nameof(modId));
                }

                var modDirs = Directory.GetDirectories(ModTool.ModsDir);
                foreach (var modDir in modDirs)
                {
                    var manifestPath = Path.Combine(modDir, "manifest.json");
                    if (File.Exists(manifestPath))
                    {
                        var manifestText = File.ReadAllText(manifestPath);
                        var manifest = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(manifestText);
                        var uniqueId = manifest?.GetValueOrDefault("UniqueID", null)?.ToString();

                        if (uniqueId == modId)
                        {
                            // Use existing delete logic from ModInstaller
                            var success = ModInstaller.TryDeleteMod(modDir, cleaupParentFolder: true);
                            if (!success)
                            {
                                throw new InvalidOperationException($"Failed to delete mod '{modId}'");
                            }
                            return;
                        }
                    }
                }

                throw new InvalidOperationException($"Mod with ID '{modId}' not found");
            });
        }

        public Task OpenModFolderAsync()
        {
            return Task.Run(() =>
            {
                if (!Directory.Exists(ModTool.ModsDir))
                {
                    Directory.CreateDirectory(ModTool.ModsDir);
                }

                // Use existing FileTool logic
                FileTool.OpenAppFilesExternalFilesDir("Mods");
            });
        }
    }
}
