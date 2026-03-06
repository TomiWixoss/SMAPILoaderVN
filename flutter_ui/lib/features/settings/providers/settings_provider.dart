import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/platform_service.dart';

/// Provider for app settings
class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _appVersion = '1.0.0';

  bool get isDarkMode => _isDarkMode;
  String get appVersion => _appVersion;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<String> testConnection() async {
    return await PlatformService.testConnection();
  }
}
