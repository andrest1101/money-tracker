import 'package:flutter/material.dart';

class DeveloperCard extends StatelessWidget {
  const DeveloperCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.code_rounded,
            color: colors.primary.withValues(alpha: 0.5),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Savu v1.0.0',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Product by Andre Robert',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
