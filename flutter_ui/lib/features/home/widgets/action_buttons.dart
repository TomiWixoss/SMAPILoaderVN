import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

/// Action buttons for main operations
class ActionButtons extends StatelessWidget {
  final bool isReady;
  final bool isLoading;
  final VoidCallback onStartGame;
  final VoidCallback onUploadLog;
  final VoidCallback onOpenModFolder;
  final VoidCallback onInstallSmapi;

  const ActionButtons({
    super.key,
    required this.isReady,
    required this.isLoading,
    required this.onStartGame,
    required this.onUploadLog,
    required this.onOpenModFolder,
    required this.onInstallSmapi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Game Button (Primary)
        ElevatedButton.icon(
          onPressed: isReady && !isLoading ? onStartGame : null,
          icon: const Icon(Icons.play_arrow, size: 28),
          label: const Text(AppStrings.startGame, style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary Actions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: isLoading ? null : onUploadLog,
              icon: const Icon(Icons.upload_file, size: 20),
              label: const Text(AppStrings.uploadLog),
            ),
            OutlinedButton.icon(
              onPressed: isLoading ? null : onOpenModFolder,
              icon: const Icon(Icons.folder_open, size: 20),
              label: const Text(AppStrings.openModFolder),
            ),
            if (!isReady)
              OutlinedButton.icon(
                onPressed: isLoading ? null : onInstallSmapi,
                icon: const Icon(Icons.download, size: 20),
                label: const Text(AppStrings.installSmapi),
              ),
          ],
        ),
      ],
    );
  }
}
