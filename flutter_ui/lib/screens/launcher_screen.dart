import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/smapi_bridge_service.dart';

/// Màn hình Launcher chính - Phase 1 POC
/// Mục tiêu: Test Method Channel communication với C#
class LauncherScreen extends StatelessWidget {
  const LauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMAPI Launcher'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Icon(
                Icons.games,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'SMAPI Launcher',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Phase 1: Proof of Concept',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 48),

              // Test C# Button
              Consumer<LauncherState>(
                builder: (context, state, child) {
                  return Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: state.isLoading ? null : () => _testConnection(context),
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cable),
                        label: Text(state.isLoading ? 'Testing...' : 'Test C# Connection'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Get App Status Button
                      ElevatedButton.icon(
                        onPressed: state.isLoading ? null : () => _getAppStatus(context),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Get App Status'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Get Mod List Button
                      ElevatedButton.icon(
                        onPressed: state.isLoading ? null : () => _getModList(context),
                        icon: const Icon(Icons.extension),
                        label: const Text('Get Mod List'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Message display
                      if (state.message.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Response:',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection(BuildContext context) async {
    final state = context.read<LauncherState>();
    state.setLoading(true);
    state.setMessage('');

    try {
      final result = await SmapiBridgeService.testConnection();
      state.setMessage(result);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Connection test successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      state.setMessage('❌ Error: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> _getAppStatus(BuildContext context) async {
    final state = context.read<LauncherState>();
    state.setLoading(true);
    state.setMessage('');

    try {
      final result = await SmapiBridgeService.getAppStatus();
      final formatted = result.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
      state.setMessage('App Status:\n$formatted');
    } catch (e) {
      state.setMessage('❌ Error: $e');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> _getModList(BuildContext context) async {
    final state = context.read<LauncherState>();
    state.setLoading(true);
    state.setMessage('');

    try {
      final result = await SmapiBridgeService.getModList();
      final formatted = result
          .map((mod) => '• ${mod['name']} (v${mod['version']})')
          .join('\n');
      state.setMessage('Installed Mods (${result.length}):\n$formatted');
    } catch (e) {
      state.setMessage('❌ Error: $e');
    } finally {
      state.setLoading(false);
    }
  }
}
