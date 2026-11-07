import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../utils/auth_error_text.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key, required this.user});

  final User user;

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  Timer? _cooldownTimer;
  int _secondsRemaining = 0;
  String? _statusMessage;
  AuthMessageTone _statusTone = AuthMessageTone.info;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0) return;
    setState(() => _statusMessage = null);

    await ref.read(authControllerProvider.notifier).sendEmailVerification();
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) return;

    setState(() {
      _secondsRemaining = 60;
      _statusTone = AuthMessageTone.success;
      _statusMessage =
          'Email verifikasi baru sudah dikirim. Periksa Inbox atau Spam.';
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _checkVerification() async {
    setState(() => _statusMessage = null);

    final verified = await ref
        .read(authControllerProvider.notifier)
        .reloadCurrentUser();
    if (!mounted) return;
    if (verified) {
      ref.invalidate(authStateChangesProvider);
      return;
    }

    final state = ref.read(authControllerProvider);
    if (state.hasError) return;

    setState(() {
      _statusTone = AuthMessageTone.info;
      _statusMessage =
          'Email belum terverifikasi. Buka tautan di email terlebih dahulu.';
    });
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;
    ref.invalidate(authStateChangesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final error = authErrorText(authState);
    final isLoading = authState.isLoading;
    final email = widget.user.email ?? 'email akunmu';

    return AuthScaffold(
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Icon(
                Icons.mark_email_unread_rounded,
                size: 32,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Verifikasi emailmu',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Satu langkah lagi sebelum kamu bisa memakai Dompetku.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.alternate_email_rounded,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: SelectableText(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AuthMessageBanner(
            message:
                'Klik tautan verifikasi di email. Jika tidak ada di Inbox, cek folder Spam atau Promosi.',
            tone: AuthMessageTone.info,
            icon: Icons.mark_email_read_outlined,
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AuthMessageBanner(message: error),
          ],
          if (_statusMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AuthMessageBanner(
              message: _statusMessage!,
              tone: _statusTone,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AuthPrimaryButton(
            label: 'Saya sudah verifikasi',
            icon: Icons.refresh_rounded,
            isLoading: isLoading,
            onPressed: _checkVerification,
          ),
          const SizedBox(height: AppSpacing.sm),
          AuthSecondaryButton(
            label: _secondsRemaining > 0
                ? 'Kirim ulang dalam ${_secondsRemaining}s'
                : 'Kirim ulang email verifikasi',
            icon: Icons.send_rounded,
            onPressed: isLoading || _secondsRemaining > 0 ? null : _resend,
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton.icon(
            onPressed: isLoading ? null : _signOut,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Gunakan akun lain'),
          ),
        ],
      ),
    );
  }
}
