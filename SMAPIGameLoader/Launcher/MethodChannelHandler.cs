using Android.Content;
using IO.Flutter.Plugin.Common;
using Java.Util;
using SMAPIGameLoader.Services;
using System;
using System.Collections.Generic;
using System.Linq;

namespace SMAPIGameLoader.Launcher
{
    /// <summary>
    /// Handles Method Channel calls from Flutter
    /// </summary>
    public class MethodChannelHandler : Java.Lang.Object, MethodChannel.IMethodCallHandler
    {
        private readonly Context _context;
        private readonly IGameService _gameService;
        private readonly ISmapiService _smapiService;
        private readonly IModService _modService;
        private readonly IStatusService _statusService;
        private const string ChannelName = "abc.smapi.gameloadervn/bridge";

        public MethodChannelHandler(Context context)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _gameService = new GameService(context);
            _smapiService = new SmapiService();
            _modService = new ModService(context);
            _statusService = new StatusService(_gameService, _smapiService);
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

        private async void HandleGetAppStatus(MethodChannel.IResult result)
        {
            try
            {
                var statusDict = await _statusService.GetAppStatusAsync();
                var status = new HashMap();
                
                foreach (var kvp in statusDict)
                {
                    if (kvp.Value is bool boolValue)
                        status.Put(kvp.Key, Java.Lang.Boolean.ValueOf(boolValue));
                    else
                        status.Put(kvp.Key, kvp.Value?.ToString());
                }

                result.Success(status);
            }
            catch (Exception ex)
            {
                result.Error("ERROR", ex.Message, ex.StackTrace);
            }
        }

        private async void HandleGetModList(MethodChannel.IResult result)
        {
            try
            {
                var mods = await _modService.GetModListAsync();
                var modList = new ArrayList();

                foreach (var mod in mods)
                {
                    var modInfo = new HashMap();
                    foreach (var kvp in mod)
                    {
                        if (kvp.Value is bool boolValue)
                            modInfo.Put(kvp.Key, Java.Lang.Boolean.ValueOf(boolValue));
                        else if (kvp.Value != null)
                            modInfo.Put(kvp.Key, kvp.Value.ToString());
                        else
                            modInfo.Put(kvp.Key, null);
                    }
                    modList.Add(modInfo);
                }

                result.Success(modList);
            }
            catch (Exception ex)
            {
                result.Error("ERROR", ex.Message, ex.StackTrace);
            }
        }

        private async void HandleStartGame(MethodChannel.IResult result)
        {
            try
            {
                await _gameService.LaunchGameAsync();
                result.Success(null);
            }
            catch (InvalidOperationException ex)
            {
                result.Error("LAUNCH_ERROR", ex.Message, null);
            }
            catch (Exception ex)
            {
                result.Error("LAUNCH_FAILED", $"Failed to launch game: {ex.Message}", null);
            }
        }

        private async void HandleUploadLog(MethodChannel.IResult result)
        {
            try
            {
                var url = await _smapiService.UploadLogAsync();
                result.Success(url);
            }
            catch (System.IO.FileNotFoundException)
            {
                result.Error("LOG_NOT_FOUND", "SMAPI log file not found", null);
            }
            catch (Exception ex)
            {
                result.Error("UPLOAD_FAILED", $"Failed to upload log: {ex.Message}", null);
            }
        }

        private async void HandleOpenModFolder(MethodChannel.IResult result)
        {
            try
            {
                await _modService.OpenModFolderAsync();
                result.Success(null);
            }
            catch (Exception ex)
            {
                result.Error("OPEN_FAILED", $"Failed to open mod folder: {ex.Message}", null);
            }
        }

        private async void HandleInstallSmapi(MethodCall call, MethodChannel.IResult result)
        {
            try
            {
                var filePath = call.Arguments()?.ToString();
                if (string.IsNullOrEmpty(filePath))
                {
                    result.Error("INVALID_PATH", "File path is required", null);
                    return;
                }

                await _smapiService.InstallSmapiAsync(filePath);
                result.Success(null);
            }
            catch (NotImplementedException)
            {
                result.Error("NOT_IMPLEMENTED", "SMAPI installation not yet implemented", null);
            }
            catch (Exception ex)
            {
                result.Error("INSTALL_FAILED", $"Failed to install SMAPI: {ex.Message}", null);
            }
        }

        private async void HandleInstallMod(MethodCall call, MethodChannel.IResult result)
        {
            try
            {
                var filePath = call.Arguments()?.ToString();
                if (string.IsNullOrEmpty(filePath))
                {
                    result.Error("INVALID_PATH", "File path is required", null);
                    return;
                }

                await _modService.InstallModAsync(filePath);
                result.Success(null);
            }
            catch (InvalidOperationException ex)
            {
                result.Error("INVALID_MOD", ex.Message, null);
            }
            catch (Exception ex)
            {
                result.Error("INSTALL_FAILED", $"Failed to install mod: {ex.Message}", null);
            }
        }

        private async void HandleDeleteMod(MethodCall call, MethodChannel.IResult result)
        {
            try
            {
                var args = call.Arguments() as HashMap;
                var modId = args?.Get("modId")?.ToString();

                if (string.IsNullOrEmpty(modId))
                {
                    result.Error("INVALID_MOD_ID", "Mod ID is required", null);
                    return;
                }

                await _modService.DeleteModAsync(modId);
                result.Success(null);
            }
            catch (InvalidOperationException ex)
            {
                result.Error("MOD_NOT_FOUND", ex.Message, null);
            }
            catch (Exception ex)
            {
                result.Error("DELETE_FAILED", $"Failed to delete mod: {ex.Message}", null);
            }
        }
    }
}
