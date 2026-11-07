import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Nada pesan pada alur autentikasi.
enum AuthMessageTone { error, success, info }

/// Satu-satunya banner pesan untuk login, reset password, dan verifikasi.
///
/// Ditempatkan pada slot yang sama di setiap halaman: tepat di atas tombol
/// utama. Warna memakai pasangan container/on-container dari [ColorScheme]
/// sehingga aman di light maupun dark mode.
class AuthMessageBanner extends StatelessWidget {
  const AuthMessageBanner({
    super.key,
    required this.message,
    this.tone = AuthMessageTone.error,
    this.icon,
  });

  final String message;
  final AuthMessageTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (background, foreground, border, defaultIcon) = switch (tone) {
      AuthMessageTone.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        scheme.error.withValues(alpha: .35),
        Icons.error_outline_rounded,
      ),
      AuthMessageTone.success => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        scheme.primary.withValues(alpha: .3),
        Icons.check_circle_outline_rounded,
      ),
      AuthMessageTone.info => (
        scheme.surfaceContainerLow,
        scheme.onSurfaceVariant,
        scheme.outlineVariant,
        Icons.info_outline_rounded,
      ),
    };

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? defaultIcon, size: 20, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
