# 📄 PRODUCT REQUIREMENTS DOCUMENT (PRD)
**Tên dự án:** SMAPI Launcher - Modern UI Revamp (Dự án: Cánh Cổng)
**Phiên bản tài liệu:** 1.0.0
**Ngày lập:** [Ngày hiện tại]
**Người lập:** Product Owner / Tech Lead
**Trạng thái:** 🟢 Approved for Development

---

## 1. TÓM TẮT DỰ ÁN (EXECUTIVE SUMMARY)
### 1.1. Bối cảnh
SMAPILoader hiện tại là một ứng dụng Android (viết bằng C# .NET 8) mạnh mẽ, cho phép load mod vào game Stardew Valley bằng cách hook trực tiếp vào MonoGame Framework. Tuy nhiên, giao diện người dùng (UI) hiện tại được xây dựng bằng Android XML truyền thống, dẫn đến UX (trải nghiệm người dùng) kém mượt mà, khó tạo hiệu ứng đẹp và khó mở rộng sau này.

### 1.2. Mục tiêu (Objective)
Thay thế toàn bộ UI XML hiện tại bằng **Flutter (Add-to-App)** để mang lại giao diện hiện đại (Material 3/Cupertino), mượt mà (60fps), có animation cao cấp. 
**Yêu cầu cốt lõi:** Tuyệt đối không làm ảnh hưởng đến lõi xử lý C# (Core Engine) đang hoạt động ổn định.

### 1.3. Chỉ số thành công (Success Metrics)
*   **Hiệu năng:** Tốc độ phản hồi UI dưới 16ms (60FPS).
*   **Kích thước App:** Dung lượng ứng dụng tăng không quá 15MB (Do tích hợp Flutter Engine).
*   **Crash Rate:** Tỉ lệ crash liên quan đến giao tiếp Flutter - C# dưới 1%.

---

## 2. KIẾN TRÚC HỆ THỐNG (SYSTEM ARCHITECTURE)
Sử dụng mô hình **Hybrid (Frontend-Backend on Device)**.

*   **Frontend (Presentation Layer):** **Flutter Module**. Đảm nhận việc vẽ UI, quản lý State màn hình, xử lý Animation và nhận Input từ user. Build ra file `flutter_ui.aar`.
*   **Backend (Core Layer):** **C# .NET 8 for Android**. Đảm nhận việc đọc/ghi file, giải nén Mod, vá lỗi thư viện (HarmonyLib, Mono.Cecil), và khởi chạy `SMAPIActivity`.
*   **Bridge (Communication Layer):** **Flutter Method Channel**. Nơi truyền tải dữ liệu JSON/String giữa Frontend và Backend.

---

## 3. PHẠM VI TÍNH NĂNG (SCOPE & FEATURES)

### Epic 1: Màn hình chính (Launcher Dashboard)
Giao diện thay thế cho `LauncherLayout.xml`.
*   **T1.1. Hiển thị thông tin hệ thống:** Hiển thị version Launcher, version Game hiện tại, và version SMAPI đang cài. Lấy dữ liệu từ C# bắn sang.
*   **T1.2. Trạng thái Sẵn sàng:** Nút "Start Game" sẽ có trạng thái (Disable/Enable/Loading) dựa trên việc C# kiểm tra xem game gốc đã được cài đặt đúng chuẩn chưa (Play Store/Galaxy Store).
*   **T1.3. Cài đặt SMAPI:** Nút "Install SMAPI from Zip". Mở bộ chọn file (UI Flutter) -> Gửi đường dẫn file cho C# xử lý -> Nhận % tiến độ từ C# để hiển thị thanh Loading.

### Epic 2: Quản lý Mod (Mod Manager)
Giao diện thay thế cho `ModManagerLayout.xml` và `ModItemViewLayout.xml`.
*   **T2.1. Danh sách Mod:** Giao diện thẻ (Card view) danh sách các Mod đã cài. Dữ liệu (Tên, Version, Đường dẫn) được C# đọc từ `manifest.json` và gửi sang Flutter dưới dạng chuỗi JSON Array.
*   **T2.2. Xóa Mod:** Vuốt (Swipe) để xóa mod. Hiển thị Dialog xác nhận. Gọi lệnh xuống C# để xóa folder.
*   **T2.3. Cài Mod mới:** Nút "Install Mod". Mở File Picker -> Chuyển path cho C# -> Nhận callback thành công -> Flutter tự động reload danh sách Mod.

### Epic 3: Tiện ích (Utilities)
*   **T3.1. Chia sẻ Log:** Nút "Share Log". Gọi C# thực thi logic đọc `SMAPI-latest.txt`, upload lên `smapi.io/log` và trả về URL cho Flutter hiển thị.
*   **T3.2. Mở thư mục Mods:** Gọi C# chạy Intent hệ thống để mở thư mục `ExternalFilesDir/Mods`.

---

## 4. ĐẶC TẢ API GIAO TIẾP (METHOD CHANNEL SPECIFICATION)
*Đây là hợp đồng (Contract) giữa team UI (Flutter) và team Core (C#).*

**Channel Name:** `com.smapiloader.app/bridge`

| Tên Hàm (Method) | Gọi từ đâu | Input (Payload) | Output (Trả về) | Ý nghĩa logic |
| :--- | :--- | :--- | :--- | :--- |
| `getAppStatus` | Flutter -> C# | None | `JSON` (GameVer, SmapiVer, isReady) | Lấy thông tin hiển thị Dashboard. |
| `startGame` | Flutter -> C# | None | `boolean` (Thành công/Thất bại) | Đóng Flutter, kích hoạt `SMAPIActivity`. |
| `pickAndInstallSmapi`| Flutter -> C# | None | `String` (Message lỗi hoặc Thành công) | Gọi FilePicker của C# và cài giải nén SMAPI. |
| `getModList` | Flutter -> C# | None | `JSON Array` (List ModItemView) | Lấy danh sách mod đang có. |
| `pickAndInstallMod` | Flutter -> C# | None | `boolean` (True/False) | Gọi C# giải nén file Mod. |
| `deleteMod` | Flutter -> C# | `String` (FolderPath) | `boolean` (True/False) | Xóa thư mục Mod cụ thể. |
| `uploadLog` | Flutter -> C# | None | `String` (URL link smapi.io) | Upload log báo lỗi. |
| `openModFolder` | Flutter -> C# | None | None | Mở app File Manager của Android. |

---

## 5. YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)

*   **NFR 1: Quản lý vòng đời (Lifecycle):** Khi C# kích hoạt `SMAPIActivity` (chạy Game), Flutter Engine phải được tạm dừng (Pause) hoặc hủy (Destroy) để giải phóng RAM tối đa cho Game (Stardew Valley rất ngốn RAM).
*   **NFR 2: Quyền hệ thống (Permissions):** UI Flutter phải hiển thị màn hình yêu cầu quyền truy cập Bộ nhớ (Storage) đẹp mắt trước khi gọi C# thực hiện việc can thiệp file.
*   **NFR 3: Thiết kế UI:** Áp dụng **Material Design 3**. Hỗ trợ Dark Mode tự động theo hệ thống máy.
*   **NFR 4: Tự động hóa Build:** Tạo file script (.bat hoặc .sh) để khi gõ 1 lệnh, tự động build Flutter ra `.aar` và copy đè vào thư mục `Libs/` của C#.

---

## 6. LỘ TRÌNH TRIỂN KHAI (ROADMAP & MILESTONES)

### Phase 1: Proof of Concept (Khả thi công nghệ) - Cần 3 ngày
*   Khởi tạo dự án Flutter Module.
*   Tạo UI đơn giản có 1 nút "Test C#".
*   Build ra `.aar`, nhúng vào file `SMAPIGameLoader.csproj`.
*   Sửa `LauncherActivity.cs` kế thừa từ `FlutterActivity`.
*   **Mục tiêu:** Bấm nút trên Flutter, in ra dòng chữ (Log) từ C#.

### Phase 2: Phát triển Giao diện Flutter (Frontend Dev) - Cần 7 ngày
*   Thiết kế và code toàn bộ UI: Màn Splash, Dashboard, Mod Manager (Dùng dữ liệu giả - Mock Data).
*   Tích hợp State Management (Provider hoặc Riverpod) để quản lý state loading, error.

### Phase 3: Tích hợp Lõi C# (Bridge Integration) - Cần 5 ngày
*   Thực thi toàn bộ các hàm trong bảng "Đặc tả API Giao tiếp" (Mục 4) bằng C#.
*   Thay thế dữ liệu giả bằng dữ liệu thật từ C# truyền sang.
*   Đảm bảo hàm `EntryGame.LaunchGameActivity(this);` hoạt động hoàn hảo khi gọi từ Flutter.

### Phase 4: Tối ưu và QA (Testing) - Cần 3 ngày
*   Test trên thiết bị giả lập và thiết bị thật (Android 10 đến Android 14).
*   Xử lý lỗi (Exception handling): Nếu C# báo lỗi giải nén (như `ErrorDialogTool`), Flutter phải nhận được để hiển thị Dialog đẹp đẽ.
*   Xử lý rò rỉ bộ nhớ (Memory Leak) khi chuyển đổi giữa Flutter UI và Game.

---

## 7. RỦI RO & PHƯƠNG ÁN GIẢI QUYẾT (RISKS & MITIGATIONS)

| Rủi ro (Risk) | Khả năng | Tác động | Giải pháp (Mitigation) |
| :--- | :---: | :---: | :--- |
| **Xung đột bộ nhớ:** Cả Flutter Engine và MonoGame Framework cùng chạy trong 1 App có thể gây tràn RAM và văng ứng dụng. | Trung bình | Cao | **Bắt buộc:** Tắt hoàn toàn `FlutterActivity` (`Finish()`) ngay trước khi gọi hàm chuyển Intent sang `SMAPIActivity`. Không giữ màn hình Flutter ở chế độ nền. |
| **Lỗi UI Thread:** C# thực thi việc giải nén ZIP lâu, làm đứng UI Flutter. | Cao | Cao | Các hàm Method Channel của C# phải được chạy trong `Task.Run` (Bất đồng bộ) và trả kết quả về sau. Hiển thị Loading Indicator trên Flutter. |
| **Bảo trì khó khăn:** Cần mở 2 IDE cùng lúc, quy trình build rườm rà. | Chắc chắn | Thấp | Viết một file `build_and_deploy.bat` tự động hóa việc `flutter build aar` và dán thẳng vào dự án C#. |

---

## 8. CHIẾN LƯỢC PHÁT TRIỂN & KIỂM THỬ UI (UI DEVELOPMENT & TESTING STRATEGY)

### 8.1. Mục tiêu (Objective)
Đảm bảo việc phát triển giao diện (UI) bằng Flutter hoàn toàn **tách biệt (decoupled)** khỏi logic lõi của C# (.NET Android). 
Cho phép lập trình viên UI (hoặc bạn khi đóng vai trò Frontend Dev) có thể thiết kế, chạy thử, tinh chỉnh layout và animation trực tiếp trên máy ảo/thiết bị thật thông qua tính năng **Hot Reload** của Flutter, *mà không cần biên dịch lại (recompile) toàn bộ Lõi C#*.

### 8.2. Phương pháp tiếp cận (Approach): Kiến trúc Mock Data (Dữ liệu Giả)

Để Flutter có thể hoạt động độc lập khi không có Lõi C# "chống lưng" (phản hồi các cuộc gọi từ Method Channel), hệ thống bắt buộc phải áp dụng cơ chế **Môi trường kép (Dual Environment)**.

*   **Môi trường 1: Chạy Độc Lập (Standalone/Debug Mode).** Môi trường này kích hoạt khi chạy source code Flutter trực tiếp từ IDE (VS Code/Android Studio). Toàn bộ các cuộc gọi Method Channel sẽ bị chặn lại (intercepted) và thay thế bằng **Mock Data** (Dữ liệu giả được định nghĩa sẵn). UI sẽ mô phỏng độ trễ (latency) của thao tác xử lý file thực tế.
*   **Môi trường 2: Chạy Tích Hợp (Integrated/Release Mode).** Môi trường này kích hoạt khi Flutter được biên dịch thành file `.aar` và nhúng vào Lõi C#. Các cuộc gọi Method Channel sẽ được thực thi thực sự, giao tiếp trực tiếp với Lõi C#.

### 8.3. Triển khai Kỹ thuật (Technical Implementation)

#### 8.3.1. Phân tầng Kiến trúc (Architecture Layers)
Mô hình phát triển UI Flutter sẽ áp dụng kiến trúc Repository Pattern để cô lập logic gọi Platform:

1.  **UI Layer (Widgets):** Các màn hình hiển thị (Dashboard, Mod List). Chỉ quan tâm đến việc nhận Dữ liệu (State) và vẽ giao diện. Không gọi trực tiếp Method Channel.
2.  **State Management Layer (Ví dụ: Provider/Riverpod/Bloc):** Quản lý trạng thái màn hình (Loading, Error, Success). Yêu cầu dữ liệu từ Repository Layer.
3.  **Repository Layer (Bridge Interface):** Lớp trung gian quyết định trả về Dữ liệu Giả (Mock) hay gọi Dữ liệu Thật (Native C#) dựa trên cờ môi trường.

#### 8.3.2. Tiêu chuẩn viết Code Giao tiếp (Bridge Communication Standard)

*Yêu cầu bắt buộc đối với mọi lệnh gọi Method Channel trong source code Flutter:*

Sử dụng hằng số `kDebugMode` (từ `package:flutter/foundation.dart`) để kiểm tra môi trường chạy.

**Ví dụ Chuẩn (Implementation Standard):**
*(Tham khảo Class `SmapiBridgeService` đính kèm trong tài liệu thiết kế hệ thống)*

```dart
// [ĐOẠN CODE NÀY PHẢI ĐƯỢC CHUẨN HÓA TRONG DỰ ÁN FLUTTER]
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Bắt buộc để dùng kDebugMode

class SmapiBridgeService {
  static const MethodChannel _channel = MethodChannel('com.smapiloader.app/bridge');

  /// Lấy danh sách Mod đã cài đặt
  static Future<List<Map<String, dynamic>>> fetchInstalledMods() async {
    // ------------------------------------------------------------------
    // MÔI TRƯỜNG 1: CHẠY ĐỘC LẬP (TEST UI TRÊN MÁY ẢO BẰNG HOT RELOAD)
    // ------------------------------------------------------------------
    if (kDebugMode) {
      // 1. Mô phỏng độ trễ đọc file từ thẻ nhớ (Ví dụ: 800ms)
      await Future.delayed(const Duration(milliseconds: 800));

      // 2. Trả về cấu trúc Dữ liệu Giả (Mock Data) chuẩn xác với định dạng C# sẽ trả về
      return [
        {
          "name": "SMAPI Thai Translation",
          "version": "1.0.0",
          "path": "/storage/emulated/0/Android/data/com.smapiloader/files/Mods/ThaiTrans",
          "isValid": true
        },
        {
          "name": "Content Patcher",
          "version": "1.29.3",
          "path": "/storage/emulated/0/Android/data/com.smapiloader/files/Mods/ContentPatcher",
          "isValid": true
        },
        {
          "name": "[LỖI] CJB Cheats Menu",
          "version": "Unknown",
          "path": "/storage/emulated/0/Android/data/com.smapiloader/files/Mods/CJB_Error",
          "isValid": false // Mô phỏng kịch bản Mod bị hỏng manifest.json
        }
      ];
    } 
    
    // ------------------------------------------------------------------
    // MÔI TRƯỜNG 2: CHẠY TÍCH HỢP (KHI ĐÃ BUILD RA FILE .AAR VÀO C#)
    // ------------------------------------------------------------------
    else {
      try {
        final List<dynamic> result = await _channel.invokeMethod('getModList');
        return result.cast<Map<String, dynamic>>();
      } on PlatformException catch (e) {
        // Bắt buộc xử lý Exception để UI không bị văng khi Lõi C# gặp lỗi (Ví dụ: Quyền truy cập bị từ chối)
        print("Bridge Error (getModList): ${e.message}");
        throw Exception("Không thể lấy danh sách Mod từ Hệ thống: ${e.message}");
      }
    }
  }
}
```

### 8.4. Quy trình Phát triển & Kiểm thử Giao diện (UI Workflow)

Quy trình này áp dụng cho mọi tính năng mới (Ví dụ: Thêm màn hình Quản lý Save Game).

**Bước 1: Thiết lập Dữ liệu Giả (Mocking - Flutter Dev)**
*   Định nghĩa rõ ràng với "Team C#" về cấu trúc JSON sẽ giao tiếp (Xem bảng Đặc tả API ở phần 4).
*   Thêm kịch bản Mock Data vào `SmapiBridgeService` (như code mẫu ở trên). Chú ý phải có cả kịch bản **Lỗi (Error Cases)** để vẽ giao diện báo lỗi (Dialog/Snackbar).

**Bước 2: Phát triển UI Độc lập (Prototyping - Flutter Dev)**
*   Khởi chạy Flutter Module trên thiết bị/máy ảo Android: `flutter run`.
*   Thiết kế layout, tinh chỉnh animation, kiểm tra các luồng thao tác (Click "Install Mod" -> Hiện Loading -> Báo Thành công/Thất bại) dựa trên Mock Data.
*   **Hoàn thiện UI 100% trước khi chuyển sang Bước 3.** Mọi chỉnh sửa giao diện ở giai đoạn sau sẽ tốn chi phí build lại `.aar`.

**Bước 3: Đóng gói UI (Packaging - Build Engineer)**
*   Đảm bảo UI đã được phê duyệt (Approved).
*   Chạy lệnh đóng gói: `flutter build aar --no-profile --no-debug`.
*   *(Lưu ý: Flag `--no-debug` rất quan trọng, nó đảm bảo mã `kDebugMode` sẽ bị loại bỏ hoàn toàn, ép ứng dụng sử dụng luồng gọi C# thực tế).*

**Bước 4: Tích hợp và Kiểm thử Toàn trình (Integration & E2E Testing - C# Dev)**
*   Copy file `.aar` (ví dụ: `build/host/outputs/repo/com/smapiloader/ui/flutter_release/1.0/flutter_release-1.0.aar`) vào thư mục `Libs` của dự án Lõi C#.
*   Biên dịch dự án C# (`.csproj`).
*   Chạy ứng dụng hoàn chỉnh trên thiết bị thật. Kiểm tra luồng gọi thật (Real Data Flow) từ Flutter -> Lõi C# -> Game Stardew Valley.

### 8.5. Kịch bản Kiểm thử Bắt buộc cho UI (Mandatory UI Test Cases)

Khi chạy UI ở chế độ Độc lập (Mock Data), phải đảm bảo các kịch bản sau hiển thị đúng thiết kế:

1.  **Trạng thái Chờ (Loading States):** Hiển thị Shimmer Effect hoặc CircularProgressIndicator trong thời gian chờ (mô phỏng 1-2 giây) đối với các tác vụ nặng (Đọc list Mod, Cài SMAPI, Giải nén Zip). Ngăn user bấm đúp nhiều lần (Disable Buttons).
2.  **Trạng thái Rỗng (Empty States):** Hiển thị giao diện thân thiện (Ví dụ: Hình minh họa Lều/Gà Stardew Valley) kèm câu thông báo "Bạn chưa cài đặt Mod nào cả" khi mảng Mod trả về rỗng (`[]`).
3.  **Trạng thái Lỗi (Error Handling):** Hiển thị Snackbar màu Đỏ hoặc Dialog (với nội dung lỗi mô phỏng) khi giả lập thao tác Thất bại (Ví dụ: File ZIP bị hỏng, C# báo lỗi từ chối quyền truy cập Storage).
4.  **Tương tác vuốt (Swipe Actions):** Giao diện vuốt thẻ Mod sang trái/phải để hiện nút Xóa (Delete) hoạt động mượt mà ở 60fps.

---
*(Phần này đóng vai trò quan trọng trong việc chuẩn hóa quy trình làm việc độc lập, giúp dự án duy trì tính module hóa cao và giảm thiểu rủi ro khi thay thế UI cũ).*