import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service để giao tiếp với C# Backend thông qua Method Channel
/// Theo chuẩn PRD Section 8: Mock Data Strategy
class SmapiBridgeService {
  static const MethodChannel _channel = MethodChannel('com.smapiloader.app/bridge');

  /// Test connection với C# Backend
  /// Phase 1 POC: Mục tiêu là in ra Log từ C#
  static Future<String> testConnection() async {
    // ------------------------------------------------------------------
    // MÔI TRƯỜNG 1: CHẠY ĐỘC LẬP (TEST UI TRÊN MÁY ẢO)
    // ------------------------------------------------------------------
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return "✅ [MOCK] Connection test successful! (Running in Debug Mode)";
    }

    // ------------------------------------------------------------------
    // MÔI TRƯỜNG 2: CHẠY TÍCH HỢP (KHI ĐÃ BUILD .AAR VÀO C#)
    // ------------------------------------------------------------------
    try {
      final String result = await _channel.invokeMethod('testConnection');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Bridge Error (testConnection): ${e.message}");
      throw Exception("Không thể kết nối với C# Backend: ${e.message}");
    }
  }

  /// Lấy thông tin trạng thái ứng dụng
  /// PRD Section 4: API Specification - getAppStatus
  static Future<Map<String, dynamic>> getAppStatus() async {
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        "launcherVersion": "1.1.4",
        "gameVersion": "1.6.9",
        "smapiVersion": "4.0.8",
        "isGameInstalled": true,
        "isSmapiInstalled": true,
        "isReady": true,
      };
    }

    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getAppStatus');
      return result.cast<String, dynamic>();
    } on PlatformException catch (e) {
      debugPrint("Bridge Error (getAppStatus): ${e.message}");
      throw Exception("Không thể lấy thông tin trạng thái: ${e.message}");
    }
  }

  /// Lấy danh sách Mod đã cài đặt
  /// PRD Section 4: API Specification - getModList
  static Future<List<Map<String, dynamic>>> getModList() async {
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 800));
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
          "isValid": false
        }
      ];
    }

    try {
      final List<dynamic> result = await _channel.invokeMethod('getModList');
      return result.cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      debugPrint("Bridge Error (getModList): ${e.message}");
      throw Exception("Không thể lấy danh sách Mod: ${e.message}");
    }
  }

  /// Khởi chạy Game với SMAPI
  /// PRD Section 4: API Specification - startGame
  static Future<bool> startGame() async {
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return true;
    }

    try {
      final bool result = await _channel.invokeMethod('startGame');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Bridge Error (startGame): ${e.message}");
      throw Exception("Không thể khởi chạy Game: ${e.message}");
    }
  }

  /// Upload log lên smapi.io
  /// PRD Section 4: API Specification - uploadLog
  static Future<String> uploadLog() async {
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 2000));
      return "https://smapi.io/log/mock-log-id-12345";
    }

    try {
      final String result = await _channel.invokeMethod('uploadLog');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Bridge Error (uploadLog): ${e.message}");
      throw Exception("Không thể upload log: ${e.message}");
    }
  }
}
