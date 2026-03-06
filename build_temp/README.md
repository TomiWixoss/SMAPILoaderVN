# 🛠️ Build Temporary Files

Thư mục này chứa các file tạm thời trong quá trình build và extract dependencies từ game APK.

## 📁 Cấu trúc thư mục

```
build_temp/
├── README.md              # File này (được commit vào Git)
├── ExtractTool/           # Tool extract DLL (được commit vào Git)
├── temp_apks/             # [Ignored] APK files từ .apks bundle
├── temp_base/             # [Ignored] Nội dung base.apk
├── DependenciesDll/       # [Ignored] DLL được extract
└── *.zip, *.apk, *.apks   # [Ignored] File tạm
```

## 🔄 Cách extract DLL từ game APK mới

Khi có phiên bản game mới (ví dụ: v1.7), làm theo các bước sau:

### Bước 1: Chuẩn bị file APK/APKS

Download file game từ:
- Google Play Store (dùng tool như APKPure, APKMirror)
- Samsung Galaxy Store
- Hoặc extract từ thiết bị đã cài game

Đặt file vào thư mục `build_temp/`

### Bước 2: Extract APKS (nếu là file .apks)

```powershell
# Trong thư mục build_temp/
Copy-Item "Stardew.Valley.v.1.7.x.apks" "temp_apks.zip"
Expand-Archive "temp_apks.zip" -DestinationPath "temp_apks"

# Extract base.apk
Copy-Item "temp_apks\base.apk" "temp_base.zip"
Expand-Archive "temp_base.zip" -DestinationPath "temp_base"
```

### Bước 3: Extract DLL từ Assembly Store

```powershell
# Chạy từ thư mục gốc dự án (SMAPILoaderVN/)
dotnet run --project ExtractTool/ExtractTool.csproj -- "build_temp/temp_base/assemblies/assemblies.arm64_v8a.blob" "build_temp/DependenciesDll"
```

Tool sẽ extract tất cả DLL từ Assembly Store format của .NET Android.

### Bước 4: Copy 3 DLL cần thiết

Copy 3 file sau vào thư mục dependencies:

```powershell
# Từ thư mục gốc dự án
Copy-Item "build_temp\DependenciesDll\MonoGame.Framework.dll" "C:\Users\tomis\Docs\SMAPI-Android-1.6\src\DependenciesDll\" -Force
Copy-Item "build_temp\DependenciesDll\StardewValley.dll" "C:\Users\tomis\Docs\SMAPI-Android-1.6\src\DependenciesDll\" -Force
Copy-Item "build_temp\DependenciesDll\StardewValley.GameData.dll" "C:\Users\tomis\Docs\SMAPI-Android-1.6\src\DependenciesDll\" -Force
```

**Lưu ý:** Đường dẫn `C:\Users\tomis\Docs\SMAPI-Android-1.6\src\DependenciesDll\` được reference trong file `SMAPIGameLoader.csproj`. Nếu bạn thay đổi cấu trúc thư mục, cần cập nhật đường dẫn trong csproj.

### Bước 5: Verify và Build

```powershell
# Kiểm tra các DLL đã được copy
Get-ChildItem "C:\Users\tomis\Docs\SMAPI-Android-1.6\src\DependenciesDll\" -Filter "*.dll"

# Build project
cd SMAPIGameLoader
dotnet build SMAPIGameLoader.csproj -c Release -f net8.0-android
```

## 🧹 Dọn dẹp

Sau khi extract xong, có thể xóa các file tạm:

```powershell
# Từ thư mục build_temp/
Remove-Item "temp_apks" -Recurse -Force
Remove-Item "temp_base" -Recurse -Force
Remove-Item "DependenciesDll" -Recurse -Force
Remove-Item "*.zip" -Force
```

Hoặc đơn giản chỉ cần xóa toàn bộ nội dung trong `build_temp/` (trừ README.md và ExtractTool/).

## 📝 Các file DLL cần thiết

| File | Mô tả | Nguồn |
|------|-------|-------|
| `MonoGame.Framework.dll` | Game engine framework | Từ game APK |
| `StardewValley.dll` | Game logic chính | Từ game APK |
| `StardewValley.GameData.dll` | Game data và content | Từ game APK |

## ⚠️ Lưu ý quan trọng

1. **Bản quyền:** Các file DLL được extract từ game gốc và thuộc bản quyền của ConcernedApe. Chỉ sử dụng cho mục đích phát triển và testing.

2. **Không commit DLL:** Các file DLL đã được thêm vào `.gitignore` và KHÔNG được commit lên Git repository.

3. **Version matching:** Mỗi version game mới cần extract lại DLL tương ứng. Không dùng DLL từ version cũ cho version mới.

4. **Assembly Store format:** Game sử dụng Assembly Store format của .NET Android để nén và lưu trữ DLL. Tool `ExtractTool` được tạo để đọc format này.

## 🔧 Troubleshooting

### Lỗi: "Could not locate the assembly"
- Kiểm tra đường dẫn trong `SMAPIGameLoader.csproj` có đúng không
- Verify 3 file DLL đã được copy vào đúng thư mục

### Lỗi: "Store data not available"
- Đảm bảo chạy ExtractTool với parameter `keepStoreInMemory: true` (đã được set sẵn)

### Lỗi: "Could not find android.jar for API level X"
- Cài đặt Android SDK Platform tương ứng từ Android Studio SDK Manager
- Hoặc chạy: `dotnet build -t:InstallAndroidDependencies`

## 📚 Tài liệu liên quan

- [Assembly Store Format](https://github.com/dotnet/android/tree/main/tools/assembly-store-reader)
- [.NET Android Documentation](https://learn.microsoft.com/en-us/dotnet/maui/android/)
- [PRD - Product Requirements Document](../docs/prd.md)
