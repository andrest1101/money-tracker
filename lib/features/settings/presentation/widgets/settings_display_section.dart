import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import 'settings_snack_bar.dart';

class PrivacyCard extends ConsumerWidget {
  const PrivacyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyMode = ref.watch(privacyModeProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: colors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SwitchListTile(
          value: isPrivacyMode,
          onChanged: (value) async {
            final saved = await ref.read(privacyModeProvider.notifier).toggle();
            if (!context.mounted) return;
            showSettingsSnackBar(
              context,
              message: saved
                  ? 'Mode privasi ${value ? 'diaktifkan' : 'dinonaktifkan'}. '
                        'Perubahan diterapkan di Beranda.'
                  : 'Mode privasi gagal disimpan.',
              isError: !saved,
            );
          },
          title: Text(
            'Mode Privasi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text('Sembunyikan nominal saldo di Beranda'),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPrivacyMode
                  ? colors.primary.withValues(alpha: 0.1)
                  : colors.onSurfaceVariant.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPrivacyMode
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: isPrivacyMode ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
