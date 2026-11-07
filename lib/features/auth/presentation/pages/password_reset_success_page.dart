import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';

/// Layar konfirmasi yang ditampilkan saat password berhasil diganti.
class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AuthScaffold(
      showBack: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SuccessHero(),
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
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Akunmu aman. Sekarang kamu bisa masuk memakai password yang baru dibuat.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AuthMessageBanner(
            message:
                'Jangan bagikan password baru ke siapa pun. Dompetku tidak akan pernah memintanya.',
            tone: AuthMessageTone.info,
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthPrimaryButton(
            label: 'Lanjutkan ke Dompetku',
            icon: Icons.arrow_forward_rounded,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _SuccessHero extends StatelessWidget {
  const _SuccessHero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: scheme.primary,
              size: 46,
              semanticLabel: 'Password berhasil diganti',
            ),
          ),
          Positioned(
            right: 4,
            bottom: 10,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 4),
              ),
              child: Icon(
                Icons.check_rounded,
                color: scheme.onPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
