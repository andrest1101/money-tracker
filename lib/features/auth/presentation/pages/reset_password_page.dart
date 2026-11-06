import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_background.dart';
import '../widgets/auth_brand_mark.dart';

/// Halaman khusus untuk mengirim tautan pemulihan password.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _sentEmail;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail?.trim() ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (!mounted || ref.read(authControllerProvider).hasError) return;

    setState(() => _sentEmail = email);
  }

  Future<void> _openGmail() async {
    final uri = Uri.parse('https://mail.google.com/mail/u/0/#inbox');

    if (Platform.isAndroid) {
      try {
        const intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'https://mail.google.com/mail/u/0/#inbox',
          package: 'com.google.android.gm',
        );
        await intent.launch();
        return;
      } catch (_) {
        // Jika Gmail tidak terpasang, coba buka lewat browser.
      }
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Gmail tidak dapat dibuka di perangkat ini.'),
        ),
      );
    }
  }

  void _resetRequestState() {
    ref.read(authControllerProvider.notifier).clearError();
    setState(() => _sentEmail = null);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: colors.onSurface,
          leading: IconButton(
            tooltip: 'Kembali ke halaman masuk',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Atur ulang password'),
          centerTitle: false,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: _sentEmail == null
                    ? _RequestForm(
                        controller: _emailController,
                        formKey: _formKey,
                        isLoading: authState.isLoading,
                        error: authState.hasError
                            ? authState.error.toString()
                            : null,
                        onSubmit: _sendResetLink,
                      )
                    : _ResetEmailSent(
                        email: _sentEmail!,
                        onOpenGmail: _openGmail,
                        onUseAnotherEmail: _resetRequestState,
                        onBackToLogin: () => Navigator.of(context).maybePop(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestForm extends StatelessWidget {
  const _RequestForm({
    required this.controller,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
    this.error,
  });

  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final Future<void> Function() onSubmit;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthBrandMark(),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Lupa password?',
          style: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Masukkan email akunmu. Kami kirim tautan aman untuk membuat password baru.',
          style: textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _PasswordResetSteps(),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.hero),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Alamat email',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) => onSubmit(),
                    decoration: InputDecoration(
                      hintText: 'nama@gmail.com',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      filled: true,
                      fillColor: scheme.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                        borderSide: BorderSide(color: scheme.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                        borderSide: BorderSide(color: scheme.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                        borderSide: BorderSide(color: scheme.error, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Masukkan alamat emailmu.';
                      if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
                        return 'Masukkan alamat email yang valid.';
                      }
                      return null;
                    },
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InlineMessage(
                      icon: Icons.error_outline_rounded,
                      text: error!,
                      tone: _MessageTone.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: isLoading ? null : () => onSubmit(),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mark_email_read_outlined),
                    label: Text(
                      isLoading ? 'Mengirim tautan...' : 'Kirim tautan reset',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Kami tidak pernah menampilkan atau meminta password lamamu.',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResetEmailSent extends StatelessWidget {
  const _ResetEmailSent({
    required this.email,
    required this.onOpenGmail,
    required this.onUseAnotherEmail,
    required this.onBackToLogin,
  });

  final String email;
  final Future<void> Function() onOpenGmail;
  final VoidCallback onUseAnotherEmail;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthBrandMark(compact: true),
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.hero),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Icon(
                    Icons.mark_email_read_rounded,
                    color: scheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Cek Gmailmu',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Jika alamat email ini terdaftar, tautan reset password sudah dikirim.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.alternate_email_rounded, size: 20, color: scheme.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
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
                _InlineMessage(
                  icon: Icons.search_outlined,
                  text: 'Belum masuk? Cek folder Spam atau Promosi, lalu cari email dari Firebase/Dompetku.',
                  tone: _MessageTone.info,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: onOpenGmail,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Buka Gmail'),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: onUseAnotherEmail,
                child: const Text('Gunakan email lain'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: onBackToLogin,
                child: const Text('Kembali ke Masuk'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PasswordResetSteps extends StatelessWidget {
  const _PasswordResetSteps();

  static const _steps = [
    (Icons.alternate_email_rounded, 'Masukkan email'),
    (Icons.mark_email_read_outlined, 'Buka tautan di Gmail'),
    (Icons.lock_reset_rounded, 'Buat password baru'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var index = 0; index < _steps.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Icon(_steps[index].$1, size: 20, color: scheme.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _steps[index].$2,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                ),
              ],
            ),
          ),
          if (index < _steps.length - 1)
            Container(
              width: 18,
              height: 1,
              margin: const EdgeInsets.only(bottom: 22),
              color: scheme.outlineVariant,
            ),
        ],
      ],
    );
  }
}

enum _MessageTone { error, info }

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.text,
    required this.tone,
  });

  final IconData icon;
  final String text;
  final _MessageTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = switch (tone) {
      _MessageTone.error => scheme.error,
      _MessageTone.info => scheme.primary,
    };
    final background = switch (tone) {
      _MessageTone.error => scheme.errorContainer,
      _MessageTone.info => scheme.primaryContainer,
    };

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: foreground.withValues(alpha: .35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: foreground,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
