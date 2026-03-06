import 'package:flutter/foundation.dart';
import '../../../core/models/app_status.dart';
import '../../../core/models/mod_info.dart';
import '../../../core/services/platform_service.dart';

/// Home screen state provider
class HomeProvider with ChangeNotifier {
  AppStatus? _appStatus;
  List<ModInfo> _mods = [];
  bool _isLoading = false;
  String? _error;
  
  AppStatus? get appStatus => _appStatus;
  List<ModInfo> get mods => _mods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isReady => _appStatus?.isReady ?? false;
  
  /// Load initial data
  Future<void> loadData() async {
    _setLoading(true);
    _error = null;
    
    try {
      // Load app status and mods in parallel
      final results = await Future.wait([
        PlatformService.getAppStatus(),
        PlatformService.getModList(),
      ]);
      
      _appStatus = results[0] as AppStatus;
      _mods = results[1] as List<ModInfo>;
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refresh mod list
  Future<void> refreshMods() async {
    try {
      _mods = await PlatformService.getModList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Start game
  Future<void> startGame() async {
    _setLoading(true);
    _error = null;
    
    try {
      await PlatformService.startGame();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Upload log
  Future<String> uploadLog() async {
    _setLoading(true);
    _error = null;
    
    try {
      final url = await PlatformService.uploadLog();
      return url;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Delete mod
  Future<void> deleteMod(String modId) async {
    try {
      await PlatformService.deleteMod(modId);
      await refreshMods();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
