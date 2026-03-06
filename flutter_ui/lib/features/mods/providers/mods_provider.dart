import 'package:flutter/foundation.dart';
import '../../../core/models/mod_info.dart';
import '../../../core/services/platform_service.dart';

/// Provider for mods management
class ModsProvider extends ChangeNotifier {
  List<ModInfo> _mods = [];
  bool _isLoading = false;
  String? _error;

  List<ModInfo> get mods => _mods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load mods from platform
  Future<void> loadMods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mods = await PlatformService.getModList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> installMod() async {
    try {
      // Let native code handle file picking
      _isLoading = true;
      notifyListeners();

      await PlatformService.pickAndInstallMod();
      await loadMods();
    } catch (e) {
      // Don't set error if user cancelled
      if (!e.toString().contains('CANCELLED')) {
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a mod
  Future<void> deleteMod(String modId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await PlatformService.deleteMod(modId);
      await loadMods();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
