# 🚀 Flutter UI Integration Guide - Phase 1 POC

## Mục tiêu Phase 1
Tạo kết nối cơ bản giữa Flutter UI và C# Backend thông qua Method Channel.

## ✅ Đã hoàn thành

### 1. Flutter Module Setup
- ✅ Tạo Flutter module với `flutter create -t module flutter_ui`
- ✅ Cấu hình Material 3 với Dark Mode support
- ✅ Thiết lập State Management (Provider)
- ✅ Tạo Mock Data Strategy theo PRD Section 8

### 2. UI Components
- ✅ LauncherScreen với 3 nút test:
  - Test C# Connection
  - Get App Status
  - Get Mod List
- ✅ Loading states
- ✅ Error handling với SnackBar
- ✅ Response display

### 3. Bridge Service
- ✅ SmapiBridgeService với Method Channel
- ✅ Mock data cho Debug mode
- ✅ Real implementation cho Release mode
- ✅ Exception handling

## 📋 Các bước tiếp theo

### Bước 1: Build Flutter AAR
```bash
# Chạy script tự động
build_flutter.bat

# Hoặc build thủ công
cd flutter_ui
flutter pub get
flutter build aar --no-debug --no-profile
```

### Bước 2: Thêm AAR vào C# Project

Mở file `SMAPIGameLoader/SMAPIGameLoader.csproj` và thêm:

```xml
<ItemGroup>
  <!-- Flutter UI Module -->
  <AndroidLibrary Include="Libs\flutter_ui.aar" />
</ItemGroup>
```

### Bước 3: Cập nhật LauncherActivity.cs

Thay đổi `LauncherActivity` để kế thừa từ `FlutterActivity`:

```csharp
using Android.App;
using Android.OS;
using IO.Flutter.Embedding.Android;
using IO.Flutter.Plugin.Common;

namespace SMAPIGameLoader.Launcher
{
    [Activity(
        Label = "SMAPI Launcher",
        MainLauncher = true,
        Theme = "@style/LaunchTheme"
    )]
    public class LauncherActivity : FlutterActivity
    {
        private const string CHANNEL = "com.smapiloader.app/bridge";
        private MethodChannel? _methodChannel;

        protected override void OnCreate(Bundle? savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            
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
        }

        // Implement Method Channel Handler
        public void OnMethodCall(MethodCall call, MethodChannel.IResult result)
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
                    
                default:
                    result.NotImplemented();
                    break;
            }
        }

        private void HandleTestConnection(MethodChannel.IResult result)
        {
            try
            {
                var message = "✅ Connection successful from C# Backend!";
                Log.Info("SMAPI", message);
                result.Success(message);
            }
            catch (Exception ex)
            {
                result.Error("ERROR", ex.Message, null);
            }
        }

        private void HandleGetAppStatus(MethodChannel.IResult result)
        {
            try
            {
                var status = new Dictionary<string, object>
                {
                    ["launcherVersion"] = "1.1.4",
                    ["gameVersion"] = StardewApkTool.CurrentGameVersion ?? "Unknown",
                    ["smapiVersion"] = SMAPIInstaller.GetCurrentVersion()?.ToString() ?? "Not Installed",
                    ["isGameInstalled"] = StardewApkTool.IsGameInstalled,
                    ["isSmapiInstalled"] = SMAPIInstaller.IsInstalled,
                    ["isReady"] = StardewApkTool.IsGameVersionSupport && SMAPIInstaller.IsInstalled
                };
                
                result.Success(status);
            }
            catch (Exception ex)
            {
                result.Error("ERROR", ex.Message, null);
            }
        }

        private void HandleGetModList(MethodChannel.IResult result)
        {
            try
            {
                var modList = new List<Dictionary<string, object>>();
                var manifestFiles = new List<string>();
                
                ModTool.FindManifestFile(FileTool.GetModsDir(), manifestFiles);
                
                foreach (var manifestPath in manifestFiles)
                {
                    try
                    {
                        var manifest = JObject.Parse(File.ReadAllText(manifestPath));
                        modList.Add(new Dictionary<string, object>
                        {
                            ["name"] = manifest["Name"]?.ToString() ?? "Unknown",
                            ["version"] = manifest["Version"]?.ToString() ?? "Unknown",
                            ["path"] = Path.GetDirectoryName(manifestPath) ?? "",
                            ["isValid"] = true
                        });
                    }
                    catch
                    {
                        modList.Add(new Dictionary<string, object>
                        {
                            ["name"] = "[ERROR] " + Path.GetFileName(Path.GetDirectoryName(manifestPath)),
                            ["version"] = "Unknown",
                            ["path"] = Path.GetDirectoryName(manifestPath) ?? "",
                            ["isValid"] = false
                        });
                    }
                }
                
                result.Success(modList);
            }
            catch (Exception ex)
            {
                result.Error("ERROR", ex.Message, null);
            }
        }
    }
}
```

### Bước 4: Test trên thiết bị

1. Build C# project với Flutter AAR đã tích hợp
2. Cài đặt APK lên thiết bị Android
3. Mở app và test 3 nút:
   - Test C# Connection → Phải nhận được message từ C#
   - Get App Status → Phải hiển thị thông tin thật
   - Get Mod List → Phải hiển thị danh sách mod thật

## 🧪 Test trong Debug Mode (Standalone)

Để test UI độc lập mà không cần C#:

```bash
cd flutter_ui
flutter run
```

Trong mode này, tất cả data sẽ là Mock Data (giả lập).

## 📊 Tiêu chí thành công Phase 1

- ✅ Flutter UI hiển thị đúng trên thiết bị
- ✅ Bấm nút "Test C#" → Nhận được response từ C# (in ra Log)
- ✅ Get App Status → Hiển thị thông tin thật từ C#
- ✅ Get Mod List → Hiển thị danh sách mod thật từ C#
- ✅ Không có crash khi chuyển đổi giữa Flutter và C#

## 🐛 Troubleshooting

### Lỗi: "Method Channel not found"
- Kiểm tra tên channel khớp giữa Flutter và C#: `com.smapiloader.app/bridge`
- Đảm bảo `SetMethodCallHandler` được gọi trong `OnCreate`

### Lỗi: "AAR not found"
- Kiểm tra đường dẫn AAR trong `.csproj`
- Rebuild Flutter với `flutter clean` trước

### Lỗi: "FlutterActivity not found"
- Thêm NuGet package: `Xamarin.Flutter.Embedding.Android`

## 📚 Tài liệu tham khảo

- [Flutter Add-to-App](https://docs.flutter.dev/add-to-app)
- [Method Channel Documentation](https://docs.flutter.dev/platform-integration/platform-channels)
- [PRD Section 4: API Specification](../docs/prd.md#4-đặc-tả-api-giao-tiếp)
