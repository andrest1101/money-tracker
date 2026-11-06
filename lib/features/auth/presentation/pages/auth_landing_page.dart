import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_background.dart';
import '../widgets/auth_error_message.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 700;
              final horizontalPadding = constraints.maxWidth < 380
                  ? 20.0
                  : 28.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: compact ? 24 : 40,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - (compact ? 48 : 80))
                        .clamp(0.0, double.infinity),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'DOMPETKU',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 32 : 44),
                          Text(
                            'Keuangan lebih teratur.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Satu tempat untuk transaksi, anggaran, dan tabunganmu.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: compact ? 24 : 32),
                          Container(
                            padding: EdgeInsets.all(compact ? 18 : 24),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.hero,
                              ),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.hasError) ...[
                                  AuthErrorMessage(
                                    message: state.error.toString(),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                _GoogleSignInButton(
                                  isLoading: state.isLoading,
                                  onPressed: _google,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: colors.outlineVariant,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                      ),
                                      child: Text(
                                        'atau',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: colors.outlineVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                OutlinedButton.icon(
                                  onPressed: state.isLoading
                                      ? null
                                      : _showEmailAuth,
                                  icon: const Icon(Icons.mail_outline_rounded),
                                  label: const Text('Lanjutkan dengan email'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(54),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.control,
                                      ),
                                    ),
                                    side: BorderSide(
                                      color: colors.outlineVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                TextButton(
                                  onPressed: state.isLoading ? null : _guest,
                                  child: const Text('Jelajahi tanpa akun'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : () => onPressed(),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                image: true,
                label: 'Google',
                child: Image.asset(
                  'assets/images/google_logo_192.png',
                  width: 23,
                  height: 23,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isLoading ? 'Menghubungkan…' : 'Lanjutkan dengan Google',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
