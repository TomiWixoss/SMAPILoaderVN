import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/app_status_card.dart';
import '../widgets/mod_list_section.dart';
import '../widgets/action_buttons.dart';

/// Main home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMAPI Launcher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HomeProvider>().loadData(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.appStatus == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null && provider.appStatus == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
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
                    label: const Text('Retry'),
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
                  // App Status Card
                  if (provider.appStatus != null)
                    AppStatusCard(status: provider.appStatus!),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  ActionButtons(
                    isReady: provider.isReady,
                    isLoading: provider.isLoading,
                    onStartGame: () => provider.startGame(),
                    onUploadLog: () => _handleUploadLog(context, provider),
                    onOpenModFolder: () => _handleOpenModFolder(),
                    onInstallSmapi: () => _handleInstallSmapi(),
                    onInstallMod: () => _handleInstallMod(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Mod List Section
                  ModListSection(
                    mods: provider.mods,
                    onRefresh: () => provider.refreshMods(),
                    onDeleteMod: (modId) => _handleDeleteMod(context, provider, modId),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleUploadLog(BuildContext context, HomeProvider provider) async {
    try {
      final url = await provider.uploadLog();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Log uploaded: $url'),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                // TODO: Copy to clipboard
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleOpenModFolder() async {
    // TODO: Implement open mod folder
  }

  Future<void> _handleInstallSmapi() async {
    // TODO: Implement install SMAPI
  }

  Future<void> _handleInstallMod() async {
    // TODO: Implement install mod
  }

  Future<void> _handleDeleteMod(BuildContext context, HomeProvider provider, String modId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mod'),
        content: const Text('Are you sure you want to delete this mod?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.deleteMod(modId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mod deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete mod: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
