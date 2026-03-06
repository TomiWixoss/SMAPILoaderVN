import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/mods_provider.dart';
import '../widgets/mod_card.dart';

/// Mods management screen
class ModsScreen extends StatefulWidget {
  const ModsScreen({super.key});

  @override
  State<ModsScreen> createState() => _ModsScreenState();
}

class _ModsScreenState extends State<ModsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModsProvider>().loadMods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ModsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.mods.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.mods.isEmpty) {
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
                  Text(provider.error!),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadMods(),
                    icon: const Icon(Icons.refresh),
                    label: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          if (provider.mods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.extension_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noModsInstalled,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _handleInstallMod(context, provider),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.installMod),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMods(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          '${provider.mods.length} ${AppStrings.modCount}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => provider.loadMods(),
                          tooltip: AppStrings.refresh,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final mod = provider.mods[index];
                        return ModCard(
                          mod: mod,
                          onDelete: () => _handleDeleteMod(context, provider, mod.id),
                        );
                      },
                      childCount: provider.mods.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleInstallMod(context, context.read<ModsProvider>()),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.installMod),
      ),
    );
  }

  Future<void> _handleInstallMod(BuildContext context, ModsProvider provider) async {
    try {
      await provider.installMod();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.modInstalledSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Don't show error if user cancelled
        if (!e.toString().contains('CANCELLED')) {
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

  Future<void> _handleDeleteMod(BuildContext context, ModsProvider provider, String modId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteModTitle),
        content: const Text(AppStrings.deleteModMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.deleteMod(modId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.modDeletedSuccess)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.modDeletedError}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
