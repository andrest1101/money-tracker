import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/errors/app_error_message.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_background.dart';
import '../widgets/auth_brand_mark.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
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

    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: scheme.onSurface,
          leading: IconButton(
            tooltip: 'Kembali ke halaman masuk',
            onPressed: widget.onContinue,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Buat password baru'),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthBrandMark(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Atur password baru',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tautan terverifikasi. Buat password baru untuk akun $_email.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SecurityNotice(),
                    const SizedBox(height: AppSpacing.md),
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
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Password baru',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: const [AutofillHints.newPassword],
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Minimal 6 karakter',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Tampilkan password'
                                        : 'Sembunyikan password',
                                    onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.control),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Konfirmasi password',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _obscureConfirmation,
                                autofillHints: const [AutofillHints.newPassword],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  hintText: 'Ulangi password baru',
                                  prefixIcon: const Icon(Icons.verified_user_outlined),
                                  suffixIcon: IconButton(
                                    tooltip: _obscureConfirmation
                                        ? 'Tampilkan konfirmasi password'
                                        : 'Sembunyikan konfirmasi password',
                                    onPressed: () => setState(
                                      () => _obscureConfirmation =
                                          !_obscureConfirmation,
                                    ),
                                    icon: Icon(
                                      _obscureConfirmation
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.control),
                                  ),
                                ),
                                validator: _validateConfirmation,
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                _InlineError(message: _error!),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              FilledButton.icon(
                                onPressed: _isSubmitting ? null : _submit,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.control),
                                  ),
                                ),
                                icon: _isSubmitting
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.lock_reset_rounded),
                                label: Text(
                                  _isSubmitting
                                      ? 'Menyimpan password...'
                                      : 'Ganti password',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

class _SecurityNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.shield_outlined, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Password hanya diproses oleh Firebase Authentication dan tidak disimpan di Dompetku.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: scheme.error.withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                    height: 1.35,
                  ),
            ),
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
    final scheme = Theme.of(context).colorScheme;

    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthBrandMark(),
                    const SizedBox(height: AppSpacing.xl),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Pastikan tautan masih berlaku sebelum membuat password baru.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
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

    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthBrandMark(),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      width: 88,
                      height: 88,
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.error.withValues(alpha: .3),
                        ),
                      ),
                      child: Icon(
                        Icons.link_off_rounded,
                        color: scheme.error,
                        size: 38,
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
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: onBackToLogin,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                        ),
                      ),
                      child: const Text('Kembali ke Masuk'),
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
