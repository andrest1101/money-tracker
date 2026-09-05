import 'package:flutter/material.dart';

class DashboardErrorView extends StatelessWidget {
  const DashboardErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 40,
                color: colors.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data keuangan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Periksa koneksi internetmu lalu coba lagi.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardSectionError extends StatelessWidget {
  const DashboardSectionError({
    super.key,
    required this.label,
    required this.onRetry,
  });

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.cloud_off_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(label),
        trailing: IconButton(
          tooltip: 'Coba lagi',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
    );
  }
}
