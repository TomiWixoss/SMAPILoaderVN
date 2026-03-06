using Android.Content;
using IO.Flutter.Plugin.Common;
using Java.Util;
using SMAPIGameLoader.Tool;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Xamarin.Essentials;

namespace SMAPIGameLoader.Launcher
{
    /// <summary>
    /// Handles Method Channel calls from Flutter
    /// </summary>
    public class MethodChannelHandler : Java.Lang.Object, MethodChannel.IMethodCallHandler
    {
        private readonly Context _context;
        private const string ChannelName = "abc.smapi.gameloadervn/bridge";

        public MethodChannelHandler(Context context)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
        }

        public void OnMethodCall(MethodCall call, MethodChannel.IResult result)
        {
            try
            {
                switch (call.Method)
                {
                    case "testConnection":
                        HandleTestConnection(result);
                        break;

                    case "getAppStatus":
                        HandleGetAppStatus(result);
                        break;

                    case "getModList":
                        HandleGetModList(result);
                        break;

                    case "startGame":
                        HandleStartGame(result);
                        break;

                    case "uploadLog":
                        HandleUploadLog(result);
                        break;

                    case "openModFolder":
                        HandleOpenModFolder(result);
                        break;

                    case "pickAndInstallSmapi":
                        HandleInstallSmapi(call, result);
                        break;

                    case "pickAndInstallMod":
                        HandleInstallMod(call, result);
                        break;

                    case "deleteMod":
                        HandleDeleteMod(call, result);
                        break;

                    default:
                        result.NotImplemented();
                        break;
                }
            }
            catch (Exception ex)
            {
                result.Error("ERROR", ex.Message, ex.StackTrace);
            }
        }

        private void HandleTestConnection(MethodChannel.IResult result)
        {
            result.Success("✅ Connection successful! C# backend is working.");
        }

        private void HandleGetAppStatus(MethodChannel.IResult result)
        {
            var status = new HashMap();
            status.Put("launcherVersion", AppInfo.VersionString);
            status.Put("gameVersion", StardewApkTool.CurrentGameVersion?.ToString() ?? "Not installed");
            status.Put("smapiVersion", SMAPIInstaller.GetCurrentVersion()?.ToString() ?? "Not installed");
            status.Put("isReady", Java.Lang.Boolean.ValueOf(StardewApkTool.IsInstalled && SMAPIInstaller.IsInstalled));

            result.Success(status);
        }

        private void HandleGetModList(MethodChannel.IResult result)
        {
            var modList = new ArrayList();

            if (!Directory.Exists(ModTool.ModsDir))
            {
                result.Success(modList);
                return;
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

                    var modInfo = new HashMap();
                    modInfo.Put("id", manifest.GetValueOrDefault("UniqueID", Path.GetFileName(modDir))?.ToString() ?? "");
                    modInfo.Put("name", manifest.GetValueOrDefault("Name", "Unknown")?.ToString() ?? "Unknown");
                    modInfo.Put("version", manifest.GetValueOrDefault("Version", "0.0.0")?.ToString() ?? "0.0.0");
                    modInfo.Put("author", manifest.GetValueOrDefault("Author", null)?.ToString());
                    modInfo.Put("description", manifest.GetValueOrDefault("Description", null)?.ToString());
                    modInfo.Put("isEnabled", Java.Lang.Boolean.True);
                    modInfo.Put("iconPath", (string?)null);

                    modList.Add(modInfo);
                }
                catch
                {
                    // Skip invalid mods
                    continue;
                }
            }

            result.Success(modList);
        }

        private void HandleStartGame(MethodChannel.IResult result)
        {
            if (!StardewApkTool.IsInstalled)
            {
                result.Error("GAME_NOT_INSTALLED", "Stardew Valley is not installed", null);
                return;
            }

            if (!SMAPIInstaller.IsInstalled)
            {
                result.Error("SMAPI_NOT_INSTALLED", "SMAPI is not installed", null);
                return;
            }

            try
            {
                if (_context is Android.App.Activity activity)
                {
                    EntryGame.LaunchGameActivity(activity);
                    result.Success(null);
                }
                else
                {
                    result.Error("INVALID_CONTEXT", "Context is not an Activity", null);
                }
            }
            catch (Exception ex)
            {
                result.Error("LAUNCH_FAILED", $"Failed to launch game: {ex.Message}", null);
            }
        }

        private void HandleUploadLog(MethodChannel.IResult result)
        {
            try
            {
                var logPath = Path.Combine(ModTool.ModsDir, "SMAPI-latest.txt");
                if (!File.Exists(logPath))
                {
                    result.Error("LOG_NOT_FOUND", "SMAPI log file not found", null);
                    return;
                }

                // TODO: Implement actual log upload to smapi.io/log
                // For now, return a placeholder URL
                var url = "https://smapi.io/log/placeholder";
                result.Success(url);
            }
            catch (Exception ex)
            {
                result.Error("UPLOAD_FAILED", $"Failed to upload log: {ex.Message}", null);
            }
        }

        private void HandleOpenModFolder(MethodChannel.IResult result)
        {
            try
            {
                if (!Directory.Exists(ModTool.ModsDir))
                {
                    Directory.CreateDirectory(ModTool.ModsDir);
                }

                var intent = new Intent(Intent.ActionView);
                intent.SetDataAndType(Android.Net.Uri.Parse(ModTool.ModsDir), "resource/folder");
                intent.AddFlags(ActivityFlags.NewTask);
                _context.StartActivity(intent);

                result.Success(null);
            }
            catch (Exception ex)
            {
                result.Error("OPEN_FAILED", $"Failed to open mod folder: {ex.Message}", null);
            }
        }

        private void HandleInstallSmapi(MethodCall call, MethodChannel.IResult result)
        {
            try
            {
                var filePath = call.Arguments()?.ToString();
                if (string.IsNullOrEmpty(filePath))
                {
                    result.Error("INVALID_PATH", "File path is required", null);
                    return;
                }

                // TODO: Implement SMAPI installation from APK
                result.Error("NOT_IMPLEMENTED", "SMAPI installation not yet implemented", null);
            }
            catch (Exception ex)
            {
                result.Error("INSTALL_FAILED", $"Failed to install SMAPI: {ex.Message}", null);
            }
        }

        private void HandleInstallMod(MethodCall call, MethodChannel.IResult result)
        {
            try
            {
                var filePath = call.Arguments()?.ToString();
                if (string.IsNullOrEmpty(filePath))
                {
                    result.Error("INVALID_PATH", "File path is required", null);
                    return;
                }

                // TODO: Implement mod installation from ZIP
                result.Error("NOT_IMPLEMENTED", "Mod installation not yet implemented", null);
            }
            catch (Exception ex)
            {
                result.Error("INSTALL_FAILED", $"Failed to install mod: {ex.Message}", null);
            }
        }

        private void HandleDeleteMod(MethodCall call, MethodChannel.IResult result)
        {
            try {
                var args = call.Arguments() as HashMap;
                var modId = args?.Get("modId")?.ToString();

                if (string.IsNullOrEmpty(modId))
                {
                    result.Error("INVALID_MOD_ID", "Mod ID is required", null);
                    return;
                }

                // Find and delete mod directory
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
                            Directory.Delete(modDir, true);
                            result.Success(null);
                            return;
                        }
                    }
                }

                result.Error("MOD_NOT_FOUND", $"Mod with ID '{modId}' not found", null);
            }
            catch (Exception ex)
            {
                result.Error("DELETE_FAILED", $"Failed to delete mod: {ex.Message}", null);
            }
        }
    }
}
