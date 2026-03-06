using System;
using System.Collections.Generic;
using Android.App;
using Android.Content.PM;
using Android.OS;
using IO.Flutter.Embedding.Android;
using IO.Flutter.Plugin.Common;
using Newtonsoft.Json;
using SMAPIGameLoader.Tool;
using Xamarin.Essentials;
using Java.Util;

namespace SMAPIGameLoader.Launcher;

[Activity(
    Label = "SMAPI Launcher",
    MainLauncher = true,
    Theme = "@style/LaunchTheme",
    AlwaysRetainTaskState = true,
    LaunchMode = LaunchMode.SingleInstance,
    ScreenOrientation = ScreenOrientation.SensorPortrait
)]
public class LauncherActivity : FlutterActivity, MethodChannel.IMethodCallHandler
{
    private const string CHANNEL = "com.smapiloader.app/bridge";
    private MethodChannel? _methodChannel;
    public static LauncherActivity? Instance { get; private set; }

    protected override void OnCreate(Bundle? savedInstanceState)
    {
        Instance = this;
        base.OnCreate(savedInstanceState);

        Platform.Init(this, savedInstanceState);
        ActivityTool.Init(this);

        // Setup Method Channel
        var flutterEngine = FlutterEngine;
        if (flutterEngine != null)
        {
            _methodChannel = new MethodChannel(
                flutterEngine.DartExecutor.BinaryMessenger,
                CHANNEL
            );
            _methodChannel.SetMethodCallHandler(this);
        }

        // Assert requirements
        AssertRequirement();

        // Process ADB extras
        ProcessAdbExtras();
    }

    private void ProcessAdbExtras()
    {
        if (AdbExtraTool.IsClickStartGame(this))
        {
            // Auto-start game if launched via ADB
            HandleStartGame(null);
        }
    }

    private void AssertRequirement()
    {
        // Check 64-bit support
        if (IntPtr.Size != 8)
        {
            ToastNotifyTool.Notify("Not support on device 32bit");
            Finish();
            return;
        }

        // Check game installation
        if (!StardewApkTool.IsInstalled)
        {
            var currentPackage = StardewApkTool.CurrentPackageInfo;
            if (currentPackage != null)
            {
                switch (currentPackage.PackageName)
                {
                    case StardewApkTool.GamePlayStorePackageName:
                        ToastNotifyTool.Notify("Please Download Game From Play Store");
                        break;
                    case StardewApkTool.GameGalaxyStorePackageName:
                        ToastNotifyTool.Notify("Please Download Game From Galaxy Store");
                        break;
                }
            }
            else
            {
                ToastNotifyTool.Notify("Please Download Game From Play Store Or Galaxy Store");
            }
            Finish();
            return;
        }
    }

    public void OnMethodCall(MethodCall call, MethodChannel.IResult? result)
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
                    HandleInstallSmapi(result);
                    break;

                case "pickAndInstallMod":
                    HandleInstallMod(result);
                    break;

                case "deleteMod":
                    HandleDeleteMod(call, result);
                    break;

                default:
                    result?.NotImplemented();
                    break;
            }
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, ex.StackTrace);
        }
    }

    private void HandleTestConnection(MethodChannel.IResult? result)
    {
        try
        {
            var message = "✅ Connection successful from C# Backend!";
            Android.Util.Log.Info("SMAPI", message);
            result?.Success(message);
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
        }
    }

    private void HandleGetAppStatus(MethodChannel.IResult? result)
    {
        try
        {
            var smapiVersion = SMAPIInstaller.GetCurrentVersion();
            var gameVersion = StardewApkTool.CurrentGameVersion;
            var statusMap = new HashMap();
            statusMap.Put("launcherVersion", AppInfo.VersionString);
            statusMap.Put("gameVersion", gameVersion != null ? gameVersion.ToString() : "Unknown");
            statusMap.Put("smapiVersion", smapiVersion?.ToString() ?? "Not Installed");
            statusMap.Put("isGameInstalled", Java.Lang.Boolean.ValueOf(StardewApkTool.IsInstalled));
            statusMap.Put("isSmapiInstalled", Java.Lang.Boolean.ValueOf(SMAPIInstaller.IsInstalled));
            statusMap.Put("isReady", Java.Lang.Boolean.ValueOf(StardewApkTool.IsGameVersionSupport && SMAPIInstaller.IsInstalled));

            result?.Success(statusMap);
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
        }
    }

    private void HandleGetModList(MethodChannel.IResult? result)
    {
        try
        {
            var modList = new ArrayList();
            var manifestFiles = new List<string>();

            ModTool.FindManifestFile(ModTool.ModsDir, manifestFiles);

            foreach (var manifestPath in manifestFiles)
            {
                try
                {
                    var manifestText = System.IO.File.ReadAllText(manifestPath);
                    var manifest = JsonConvert.DeserializeObject<Dictionary<string, object>>(manifestText);

                    var modMap = new HashMap();
                    modMap.Put("name", manifest?.ContainsKey("Name") == true ? manifest["Name"]?.ToString() ?? "Unknown" : "Unknown");
                    modMap.Put("version", manifest?.ContainsKey("Version") == true ? manifest["Version"]?.ToString() ?? "Unknown" : "Unknown");
                    modMap.Put("path", System.IO.Path.GetDirectoryName(manifestPath) ?? "");
                    modMap.Put("isValid", Java.Lang.Boolean.True);
                    modList.Add(modMap);
                }
                catch
                {
                    var errorMap = new HashMap();
                    errorMap.Put("name", "[ERROR] " + System.IO.Path.GetFileName(System.IO.Path.GetDirectoryName(manifestPath)));
                    errorMap.Put("version", "Unknown");
                    errorMap.Put("path", System.IO.Path.GetDirectoryName(manifestPath) ?? "");
                    errorMap.Put("isValid", Java.Lang.Boolean.False);
                    modList.Add(errorMap);
                }
            }

            result?.Success(modList);
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
        }
    }

    private void HandleStartGame(MethodChannel.IResult? result)
    {
        try
        {
            if (!StardewApkTool.IsGameVersionSupport)
            {
                result?.Error("UNSUPPORTED_VERSION", "Game version not supported: " + StardewApkTool.CurrentGameVersion, null);
                ToastNotifyTool.Notify("Not support game version: " + StardewApkTool.CurrentGameVersion);
                return;
            }

            if (!SMAPIInstaller.IsInstalled)
            {
                result?.Error("SMAPI_NOT_INSTALLED", "Please install SMAPI first", null);
                ToastNotifyTool.Notify("Please install SMAPI!!");
                return;
            }

            GameCloner.Setup();

            // Launch game
            EntryGame.LaunchGameActivity(this);
            result?.Success(Java.Lang.Boolean.True);
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
            ToastNotifyTool.Notify("Error: " + ex.Message);
        }
    }

    private void HandleUploadLog(MethodChannel.IResult? result)
    {
        try
        {
            // Call existing log upload functionality
            LogParser.OnClickUploadLog(this, EventArgs.Empty);
            result?.Success("Log upload started");
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
        }
    }

    private void HandleOpenModFolder(MethodChannel.IResult? result)
    {
        try
        {
            FileTool.OpenAppFiles(ModTool.ModsDir);
            result?.Success(Java.Lang.Boolean.True);
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
        }
    }

    private void HandleInstallSmapi(MethodChannel.IResult? result)
    {
        try
        {
            // Trigger SMAPI installation (will open file picker)
            SMAPIInstaller.OnClickInstallSMAPIZip(this, EventArgs.Empty);
            result?.Success("SMAPI installation started");
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
        }
    }

    private void HandleInstallMod(MethodChannel.IResult? result)
    {
        try
        {
            // TODO: Implement mod installation via file picker
            result?.Success(Java.Lang.Boolean.True);
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
        }
    }

    private void HandleDeleteMod(MethodCall call, MethodChannel.IResult? result)
    {
        try
        {
            var folderPath = call.Arguments()?.ToString();
            if (string.IsNullOrEmpty(folderPath))
            {
                result?.Error("INVALID_ARGUMENT", "Folder path is required", null);
                return;
            }

            if (System.IO.Directory.Exists(folderPath))
            {
                System.IO.Directory.Delete(folderPath, true);
                result?.Success(Java.Lang.Boolean.True);
            }
            else
            {
                result?.Error("NOT_FOUND", "Mod folder not found", null);
            }
        }
        catch (Exception ex)
        {
            result?.Error("ERROR", ex.Message, null);
        }
    }
}
