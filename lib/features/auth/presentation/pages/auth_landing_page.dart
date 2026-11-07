import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../utils/auth_error_text.dart';
import '../widgets/auth_brand_lockup.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_value_props.dart';
import 'email_auth_page.dart';

class AuthLandingPage extends ConsumerStatefulWidget {
  const AuthLandingPage({super.key});

  @override
  ConsumerState<AuthLandingPage> createState() => _AuthLandingPageState();
}

class _AuthLandingPageState extends ConsumerState<AuthLandingPage> {
  @override
  void initState() {
    super.initState();
    final link = Uri.base.toString();
    if (link.contains('oobCode=') && link.contains('mode=signIn')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showEmailAuth(
            initialLink: link,
            initialEmail: Uri.base.queryParameters['email'],
          );
        }
      });
    }
  }

  Future<void> _google() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  Future<void> _guest() async {
    await ref.read(authControllerProvider.notifier).continueAsGuest();
  }

  Future<void> _showEmailAuth({
    String? initialLink,
    String? initialEmail,
  }) async {
    ref.read(authControllerProvider.notifier).clearError();
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            EmailAuthPage(initialLink: initialLink, initialEmail: initialEmail),
      ),
    );
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final error = authErrorText(state);
    final isLoading = state.isLoading;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final actionCard = _AuthActionCard(
      isLoading: isLoading,
      error: error,
      onGoogle: () => _google(),
      onEmail: () => _showEmailAuth(),
      onGuest: () => _guest(),
    );

    final compact = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthBrandLockup(size: AuthBrandSize.hero, centered: true),
        const SizedBox(height: AppSpacing.xxl),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Keuangan lebih '),
              TextSpan(
                text: 'teratur.',
                style: TextStyle(color: scheme.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.12,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Satu tempat untuk transaksi, anggaran, dan tabunganmu.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        const AuthValueProps(),
        const SizedBox(height: AppSpacing.xl),
        actionCard,
        const SizedBox(height: AppSpacing.lg),
        const AuthFooter(),
      ],
    );

    final wide = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Masuk atau daftar',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Pilih cara masuk. Catatanmu tetap tersinkron ke semua perangkat.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        actionCard,
        const SizedBox(height: AppSpacing.lg),
        const AuthFooter(),
      ],
    );

    return AuthScaffold(
      showAppBar: false,
      panel: const AuthBrandPanel(
        description: 'Satu akun untuk transaksi, anggaran, dan target tabunganmu.',
      ),
      wideChild: wide,
      child: compact,
    );
  }
}

class _AuthActionCard extends StatelessWidget {
  const _AuthActionCard({
    required this.isLoading,
    required this.error,
    required this.onGoogle,
    required this.onEmail,
    required this.onGuest,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onGoogle;
  final VoidCallback onEmail;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) ...[
            AuthMessageBanner(message: error!),
            const SizedBox(height: AppSpacing.md),
          ],
          AuthSocialButton(
            label: isLoading
                ? 'Menghubungkan…'
                : 'Lanjutkan dengan Google',
            isLoading: isLoading,
            onPressed: onGoogle,
            leading: Image.asset(
              'assets/images/google_logo_192.png',
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _OrDivider(),
          const SizedBox(height: AppSpacing.md),
          AuthSecondaryButton(
            label: 'Lanjutkan dengan email',
            icon: Icons.mail_outline_rounded,
            onPressed: onEmail,
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: onGuest,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            child: const Text('Jelajahi tanpa akun'),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(child: Divider(color: scheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'atau',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: scheme.outlineVariant)),
      ],
    );
  }
}
