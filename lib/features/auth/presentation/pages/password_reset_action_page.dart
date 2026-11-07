import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/errors/app_error_message.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_step_indicator.dart';
import '../widgets/auth_text_field.dart';
import 'password_reset_success_page.dart';

/// Halaman untuk menyelesaikan password reset dari email/action link.
class PasswordResetActionPage extends StatefulWidget {
  const PasswordResetActionPage({
    super.key,
    required this.actionCode,
    required this.onContinue,
  });

  final String actionCode;
  final VoidCallback onContinue;

  @override
  State<PasswordResetActionPage> createState() => _PasswordResetActionPageState();
}

class _PasswordResetActionPageState extends State<PasswordResetActionPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isVerifying = true;
  bool _isSubmitting = false;
  bool _completed = false;
  String? _email;
  String? _error;

  @override
  void initState() {
    super.initState();
    _verifyCode();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final email = await FirebaseAuth.instance.verifyPasswordResetCode(
        widget.actionCode,
      );
      if (!mounted) return;
      setState(() {
        _email = email;
        _isVerifying = false;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = authErrorMessage(error);
        _isVerifying = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Tautan tidak dapat diverifikasi. Coba lagi.';
        _isVerifying = false;
      });
    }
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Masukkan password baru.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    return null;
  }

  String? _validateConfirmation(String? value) {
    if ((value ?? '').isEmpty) return 'Konfirmasi password baru.';
    if (value != _passwordController.text) return 'Password belum sama.';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.actionCode,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      TextInput.finishAutofillContext(shouldSave: false);
      setState(() {
        _completed = true;
        _isSubmitting = false;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = authErrorMessage(error);
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Password gagal diganti. Periksa koneksi lalu coba lagi.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return PasswordResetSuccessPage(onContinue: widget.onContinue);
    }

    if (_isVerifying) {
      return const _VerifyingPasswordResetPage();
    }

    if (_email == null) {
      return _InvalidPasswordResetLink(
        message: _error ?? 'Tautan tidak valid atau sudah kedaluwarsa.',
        onBackToLogin: widget.onContinue,
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AuthScaffold(
      panel: const AuthBrandPanel(
        description:
            'Buat password baru yang kuat agar akun Dompetku tetap aman.',
      ),
      onBack: widget.onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Buat password baru',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tautan terverifikasi untuk akun $_email.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AuthStepIndicator(currentStep: 2),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.hero),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthPasswordField(
                      controller: _passwordController,
                      label: 'Password baru',
                      hint: 'Minimal 6 karakter',
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AuthPasswordField(
                      controller: _confirmController,
                      label: 'Konfirmasi password',
                      hint: 'Ulangi password baru',
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmation,
                      enabled: !_isSubmitting,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AuthMessageBanner(message: _error!),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AuthPrimaryButton(
                      label: _isSubmitting
                          ? 'Menyimpan password…'
                          : 'Ganti password',
                      icon: Icons.lock_reset_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AuthFooter(
            text:
                'Password diproses aman oleh sistem autentikasi dan tidak disimpan di Dompetku.',
          ),
        ],
      ),
    );
  }
}

class _VerifyingPasswordResetPage extends StatelessWidget {
  const _VerifyingPasswordResetPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AuthScaffold(
      showBack: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Memeriksa tautan…',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pastikan tautan masih berlaku sebelum membuat password baru.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvalidPasswordResetLink extends StatelessWidget {
  const _InvalidPasswordResetLink({
    required this.message,
    required this.onBackToLogin,
  });

  final String message;
  final VoidCallback onBackToLogin;

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
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.error.withValues(alpha: .3),
                ),
              ),
              child: Icon(
                Icons.link_off_rounded,
                color: scheme.onErrorContainer,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tautan tidak bisa dipakai',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthPrimaryButton(
            label: 'Kembali ke Masuk',
            icon: Icons.login_rounded,
            onPressed: onBackToLogin,
          ),
        ],
      ),
    );
  }
}
