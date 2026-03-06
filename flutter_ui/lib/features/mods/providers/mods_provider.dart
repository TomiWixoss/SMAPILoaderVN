import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
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

  /// Install a mod from file
  Future<void> installMod() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        _isLoading = true;
        notifyListeners();

        await PlatformService.installMod(result.files.single.path!);
        await loadMods();
      }
    } catch (e) {
      _error = e.toString();
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
