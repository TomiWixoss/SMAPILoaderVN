import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/app_status.dart';
import '../models/mod_info.dart';

/// Platform service for communicating with native C# code
class PlatformService {
  static const MethodChannel _channel = MethodChannel(AppConstants.methodChannelName);
  
  /// Test connection to C# backend
  static Future<String> testConnection() async {
    try {
      final result = await _channel.invokeMethod<String>('testConnection');
      return result ?? 'No response';
    } on PlatformException catch (e) {
      throw Exception('Failed to test connection: ${e.message}');
    }
  }
  
  /// Get app status (launcher version, game version, SMAPI version, etc.)
  static Future<AppStatus> getAppStatus() async {
    try {
      final result = await _channel.invokeMethod<Map>('getAppStatus');
      if (result == null) {
        throw Exception('No status data received');
      }
      return AppStatus.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw Exception('Failed to get app status: ${e.message}');
    }
  }
  
  /// Get list of installed mods
  static Future<List<ModInfo>> getModList() async {
    try {
      final result = await _channel.invokeMethod<List>('getModList');
      if (result == null) {
        return [];
      }
      return result
          .map((mod) => ModInfo.fromMap(Map<String, dynamic>.from(mod as Map)))
          .toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to get mod list: ${e.message}');
    }
  }
  
  /// Start the game with SMAPI
  static Future<void> startGame() async {
    try {
      await _channel.invokeMethod('startGame');
    } on PlatformException catch (e) {
      throw Exception('Failed to start game: ${e.message}');
    }
  }
  
  /// Upload SMAPI log
  static Future<String> uploadLog() async {
    try {
      final result = await _channel.invokeMethod<String>('uploadLog');
      return result ?? '';
    } on PlatformException catch (e) {
      throw Exception('Failed to upload log: ${e.message}');
    }
  }
  
  /// Open mod folder
  static Future<void> openModFolder() async {
    try {
      await _channel.invokeMethod('openModFolder');
    } on PlatformException catch (e) {
      throw Exception('Failed to open mod folder: ${e.message}');
    }
  }
  
  /// Install SMAPI from APK file
  static Future<void> installSmapi(String filePath) async {
    try {
      await _channel.invokeMethod('pickAndInstallSmapi', {'filePath': filePath});
    } on PlatformException catch (e) {
      throw Exception('Failed to install SMAPI: ${e.message}');
    }
  }
  
  /// Install mod from file
  static Future<void> installMod(String filePath) async {
    try {
      await _channel.invokeMethod('pickAndInstallMod', {'filePath': filePath});
    } on PlatformException catch (e) {
      throw Exception('Failed to install mod: ${e.message}');
    }
  }
  
  /// Delete a mod
  static Future<void> deleteMod(String modId) async {
    try {
      await _channel.invokeMethod('deleteMod', {'modId': modId});
    } on PlatformException catch (e) {
      throw Exception('Failed to delete mod: ${e.message}');
    }
  }
}
