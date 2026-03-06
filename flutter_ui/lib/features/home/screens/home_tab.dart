import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/platform_service.dart';
import '../providers/home_provider.dart';
import '../widgets/app_status_card.dart';
import '../widgets/action_buttons.dart';

/// Home tab content
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.appStatus == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.appStatus == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  AppStrings.errorLoadingData,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.loadData(),
                  icon: const Icon(Icons.refresh),
                  label: const Text(AppStrings.retry),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.appStatus != null)
                  AppStatusCard(status: provider.appStatus!),
                const SizedBox(height: 16),
                ActionButtons(
                  isReady: provider.isReady,
                  isLoading: provider.isLoading,
                  onStartGame: () => _handleStartGame(context, provider),
                  onUploadLog: () => _handleUploadLog(context, provider),
                  onOpenModFolder: () => _handleOpenModFolder(context),
                  onInstallSmapi: () => _handleInstallSmapi(context, provider),
                  onInstallMod: () => _handleInstallMod(context, provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleStartGame(BuildContext context, HomeProvider provider) async {
    try {
      await provider.startGame();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.failedToStartGame}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUploadLog(BuildContext context, HomeProvider provider) async {
    try {
      final url = await provider.uploadLog();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.logUploadedSuccess}: $url'),
            action: SnackBarAction(
              label: AppStrings.copy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.logUploadedError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleOpenModFolder(BuildContext context) async {
    try {
      await PlatformService.openModFolder();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleInstallSmapi(BuildContext context, HomeProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'],
      );

      if (result != null && result.files.single.path != null) {
        await PlatformService.installSmapi(result.files.single.path!);
        await provider.loadData();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.smapiInstalledSuccess)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.smapiInstalledError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleInstallMod(BuildContext context, HomeProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        await PlatformService.installMod(result.files.single.path!);
        await provider.loadData();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.modInstalledSuccess)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.modInstalledError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
