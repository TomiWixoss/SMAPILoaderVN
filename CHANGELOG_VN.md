# Changelog - Cập nhật phiên bản VN

## Các thay đổi chính

### 1. Tái cấu trúc Backend (C#)

#### Tạo Services Layer (Sử dụng logic có sẵn)
- **ISmapiService / SmapiService**: Quản lý SMAPI (cài đặt từ ZIP, upload log) - sử dụng SMAPIInstaller
- **IGameService / GameService**: Quản lý game (khởi động, kiểm tra cài đặt) - sử dụng EntryGame
- **IModService / ModService**: Quản lý mod (cài đặt, xóa, liệt kê) - sử dụng ModInstaller & ModTool
- **IStatusService / StatusService**: Quản lý trạng thái app

#### Cập nhật MethodChannelHandler
- Sử dụng các service thay vì code trực tiếp
- Tất cả methods giờ là async
- Services sử dụng lại logic có sẵn từ SMAPIInstaller, ModInstaller, EntryGame, FileTool
- Code sạch hơn, dễ maintain hơn

### 2. Hoàn thành TODO

✅ **TODO đã hoàn thành:**
- Upload log lên smapi.io/log (SmapiService.UploadLogAsync)
- Cài đặt SMAPI từ ZIP (SmapiService.InstallSmapiAsync - sử dụng logic từ SMAPIInstaller)
- Cài đặt mod từ ZIP (ModService.InstallModAsync - sử dụng logic từ ModInstaller)
- Mở thư mục mod (ModService.OpenModFolderAsync - sử dụng FileTool.OpenAppFilesExternalFilesDir)
- Xóa mod (ModService.DeleteModAsync - sử dụng ModInstaller.TryDeleteMod)
- Copy log URL to clipboard (HomeTab._handleUploadLog)
- Navigate to settings (MainScreen với NavigationBar)
- Kiểm tra permission (FilePickerTool - đã có sẵn)

✅ **Tất cả TODO đã hoàn thành!**

### 3. Đổi UI sang Tiếng Việt

#### Tạo AppStrings
- File: `flutter_ui/lib/core/constants/app_strings.dart`
- Chứa tất cả text tiếng Việt
- Dễ dàng thay đổi ngôn ngữ sau này

#### Cập nhật tất cả UI components
- AppStatusCard: Hiển thị trạng thái bằng tiếng Việt
- ActionButtons: Các nút bấm tiếng Việt
- ModCard: Thông tin mod tiếng Việt
- Tất cả messages và dialogs

### 4. Thêm "VN" vào tên App

- **AndroidManifest.xml**: `SMAPI Launcher VN`
- **AppStrings**: `appName = 'SMAPI Launcher VN'`
- Hiển thị trên app bar và launcher

### 5. Tái cấu trúc UI - 3 Tabs

#### Cấu trúc mới:
```
MainScreen (với NavigationBar)
├── Tab 1: Home (HomeTab)
│   ├── AppStatusCard
│   └── ActionButtons
├── Tab 2: Mods (ModsScreen)
│   ├── ModsProvider
│   └── ModCard list
└── Tab 3: Settings (SettingsScreen)
    ├── SettingsProvider
    ├── Dark mode toggle
    └── App info
```

#### Providers mới:
- **HomeProvider**: Quản lý home state
- **ModsProvider**: Quản lý danh sách mod
- **SettingsProvider**: Quản lý cài đặt (dark mode, etc.)

#### Features:
- **Home Tab**: Khởi động game, upload log, cài đặt SMAPI/mod
- **Mods Tab**: Xem, cài đặt, xóa mod với FAB
- **Settings Tab**: Dark mode, thông tin app, test connection

### 6. Cải tiến khác

#### UI/UX:
- NavigationBar với 3 tabs
- Pull-to-refresh trên tất cả screens
- Loading states và error handling
- Confirmation dialogs
- SnackBar notifications
- Dark mode support

#### Code Quality:
- Separation of concerns (Services, Providers, Widgets)
- Async/await pattern
- Error handling
- Type safety

## Cấu trúc thư mục mới

### Backend (C#)
```
SMAPIGameLoader/
├── Services/
│   ├── ISmapiService.cs
│   ├── SmapiService.cs
│   ├── IGameService.cs
│   ├── GameService.cs
│   ├── IModService.cs
│   ├── ModService.cs
│   ├── IStatusService.cs
│   └── StatusService.cs
└── Launcher/
    └── MethodChannelHandler.cs (refactored)
```

### Frontend (Flutter)
```
flutter_ui/lib/
├── core/
│   ├── constants/
│   │   └── app_strings.dart (NEW)
│   ├── models/
│   ├── services/
│   └── theme/
├── features/
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_tab.dart (NEW)
│   │   ├── providers/
│   │   └── widgets/
│   ├── mods/ (NEW)
│   │   ├── screens/
│   │   │   └── mods_screen.dart
│   │   ├── providers/
│   │   │   └── mods_provider.dart
│   │   └── widgets/
│   │       └── mod_card.dart
│   └── settings/ (NEW)
│       ├── screens/
│       │   └── settings_screen.dart
│       └── providers/
│           └── settings_provider.dart
└── main.dart (refactored với MainScreen)
```

## Tóm tắt

Đã hoàn thành tất cả yêu cầu:
- ✅ Tái cấu trúc backend thành services (sử dụng logic có sẵn)
- ✅ Hoàn thành tất cả TODO
- ✅ Đổi UI sang tiếng Việt
- ✅ Thêm "VN" vào tên app
- ✅ Tái cấu trúc UI thành 3 tabs (Home, Mod, Settings)
- ✅ Sử dụng FilePickerTool native thay vì Flutter plugin
- ✅ Home tab chỉ hiển thị status và actions chính
- ✅ Tab Mod riêng để quản lý mod

## Cách sử dụng

1. **Trang chủ (Home)**: Xem trạng thái, khởi động game, upload log, cài SMAPI
2. **Tab Mod**: Xem danh sách mod, cài đặt mod mới, xóa mod
3. **Tab Cài đặt**: Dark mode, thông tin app, test connection
