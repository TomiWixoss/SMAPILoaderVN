import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/mod_info.dart';

/// Card widget for displaying mod information
class ModCard extends StatelessWidget {
  final ModInfo mod;
  final VoidCallback onDelete;

  const ModCard({
    super.key,
    required this.mod,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.extension,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          mod.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (mod.author != null)
              Text('${AppStrings.author}: ${mod.author}'),
            Text('${AppStrings.version}: ${mod.version}'),
            if (mod.description != null) ...[
              const SizedBox(height: 4),
              Text(
                mod.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
          tooltip: AppStrings.delete,
        ),
      ),
    );
  }
}
