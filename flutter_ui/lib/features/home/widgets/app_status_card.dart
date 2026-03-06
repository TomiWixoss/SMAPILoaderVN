import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/app_status.dart';

/// Card displaying app status information
class AppStatusCard extends StatelessWidget {
  final AppStatus status;

  const AppStatusCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.isReady ? Icons.check_circle : Icons.warning,
                  color: status.isReady ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  status.isReady ? AppStrings.ready : AppStrings.notReady,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context, AppStrings.launcherVersion, status.launcherVersion),
            if (status.gameVersion != null)
              _buildInfoRow(context, AppStrings.gameVersion, status.gameVersion!),
            if (status.smapiVersion != null)
              _buildInfoRow(context, AppStrings.smapiVersion, status.smapiVersion!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
