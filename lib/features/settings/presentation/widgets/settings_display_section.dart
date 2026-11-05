import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import 'settings_snack_bar.dart';

/// Tema gelap sementara tidak ditawarkan sampai audit visual selesai.
/// Implementasi AppTheme.dark dan penyimpanan preferensi tetap dipertahankan.
class ThemeSelectionCard extends StatelessWidget {
  const ThemeSelectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: colors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Tema Aplikasi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.light_mode_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tema terang aktif',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pilihan tema gelap tersedia kembali setelah tampilannya disempurnakan.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
