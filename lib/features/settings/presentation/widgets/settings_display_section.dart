import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import 'settings_snack_bar.dart';

class ThemeSelectionCard extends ConsumerWidget {
  const ThemeSelectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeModeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_outlined, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Tema Aplikasi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ThemeChip(
                    icon: Icons.brightness_auto_rounded,
                    label: 'Sistem',
                    selected: currentTheme == ThemeMode.system,
                    onTap: () => _saveTheme(context, ref, ThemeMode.system),
                  ),
                  const SizedBox(width: 8),
                  ThemeChip(
                    icon: Icons.light_mode_rounded,
                    label: 'Terang',
                    selected: currentTheme == ThemeMode.light,
                    onTap: () => _saveTheme(context, ref, ThemeMode.light),
                  ),
                  const SizedBox(width: 8),
                  ThemeChip(
                    icon: Icons.dark_mode_rounded,
                    label: 'Gelap',
                    selected: currentTheme == ThemeMode.dark,
                    onTap: () => _saveTheme(context, ref, ThemeMode.dark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) async {
    final saved = await ref
        .read(appThemeModeProvider.notifier)
        .setThemeMode(mode);
    if (!context.mounted) return;
    showSettingsSnackBar(
      context,
      message: saved ? 'Tema aplikasi diperbarui.' : 'Tema gagal disimpan.',
      isError: !saved,
    );
  }
}

class ThemeChip extends StatelessWidget {
  const ThemeChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.15)
                : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.6)
                  : cs.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHigh,
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
                  ? cs.primary.withValues(alpha: 0.1)
                  : cs.onSurfaceVariant.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPrivacyMode
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: isPrivacyMode ? cs.primary : cs.onSurfaceVariant,
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
