import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_background.dart';

/// Layar konfirmasi yang ditampilkan saat aplikasi dibuka setelah reset sandi.
class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SuccessHero(),
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      liveRegion: true,
                      header: true,
                      child: Text(
                        'Password berhasil diganti',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Akunmu aman. Sekarang kamu bisa masuk memakai password yang baru dibuat.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: scheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Jangan bagikan password baru ke siapa pun. Dompetku tidak akan pernah memintanya.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onPrimaryContainer,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: onContinue,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.control),
                        ),
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Lanjutkan ke Dompetku'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 164,
            height: 164,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant),
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: scheme.primary,
              size: 54,
              semanticLabel: 'Email terkonfirmasi',
            ),
          ),
          Positioned(
            right: 4,
            bottom: 14,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 4),
              ),
              child: Icon(
                Icons.check_rounded,
                color: scheme.onPrimary,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
