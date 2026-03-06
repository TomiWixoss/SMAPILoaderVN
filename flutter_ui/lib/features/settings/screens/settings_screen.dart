import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/settings_provider.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                AppStrings.general,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(AppStrings.darkMode),
                      subtitle: Text(
                        provider.isDarkMode
                            ? AppStrings.darkMode
                            : AppStrings.lightMode,
                      ),
                      value: provider.isDarkMode,
                      onChanged: (value) => provider.setDarkMode(value),
                      secondary: Icon(
                        provider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.about,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text(AppStrings.appInfo),
                      subtitle: Text(provider.appVersion),
                    ),
                    ListTile(
                      leading: const Icon(Icons.system_update),
                      title: const Text(AppStrings.checkUpdates),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _handleCheckUpdates(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.bug_report),
                      title: const Text(AppStrings.testConnection),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _handleTestConnection(context, provider),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleCheckUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng đang phát triển')),
    );
  }

  Future<void> _handleTestConnection(BuildContext context, SettingsProvider provider) async {
    try {
      final message = await provider.testConnection();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
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
}
