import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../utils/auth_error_text.dart';
import '../utils/mail_launcher.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_step_indicator.dart';
import '../widgets/auth_text_field.dart';

/// Halaman untuk mengirim tautan pemulihan password.
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
    if (ref.read(authControllerProvider).isLoading) return;

    final email = _emailController.text.trim();
    await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (!mounted || ref.read(authControllerProvider).hasError) return;

    setState(() => _sentEmail = email);
  }

  void _resetRequestState() {
    ref.read(authControllerProvider.notifier).clearError();
    FocusScope.of(context).unfocus();
    setState(() => _sentEmail = null);
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Masukkan alamat emailmu.';
    if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final error = authErrorText(authState);
    final isLoading = authState.isLoading;
    final sentEmail = _sentEmail;

    return AuthScaffold(
      panel: const AuthBrandPanel(
        description:
            'Amankan akunmu dengan tautan pemulihan yang dikirim ke email terdaftar.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            sentEmail == null ? 'Lupa password?' : 'Cek Gmailmu',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            sentEmail == null
                ? 'Masukkan email akunmu. Kami kirim tautan aman untuk membuat password baru.'
                : 'Jika $sentEmail terdaftar, tautan reset password sudah dikirim.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthStepIndicator(currentStep: sentEmail == null ? 0 : 1),
          const SizedBox(height: AppSpacing.lg),
          if (sentEmail == null)
            _RequestCard(
              formKey: _formKey,
              controller: _emailController,
              isLoading: isLoading,
              error: error,
              onSubmit: _sendResetLink,
              validator: _validateEmail,
            )
          else
            _SentCard(
              email: sentEmail,
              onOpenGmail: () => openGmail(context),
              onUseAnotherEmail: _resetRequestState,
              onBackToLogin: () => Navigator.of(context).maybePop(),
            ),
          const SizedBox(height: AppSpacing.lg),
          AuthFooter(
            text: sentEmail == null
                ? 'Kami tidak pernah menampilkan atau meminta password lamamu.'
                : 'Tautan reset hanya berlaku untuk akun yang terdaftar di Dompetku.',
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.formKey,
    required this.controller,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
    required this.validator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onSubmit;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: controller,
                label: 'Email',
                hint: 'nama@gmail.com',
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                autofillHints: const [AutofillHints.email],
                validator: validator,
                enabled: !isLoading,
                onFieldSubmitted: (_) => onSubmit(),
              ),
              if (error != null) ...[
                const SizedBox(height: AppSpacing.md),
                AuthMessageBanner(message: error!),
              ],
              const SizedBox(height: AppSpacing.lg),
              AuthPrimaryButton(
                label: isLoading ? 'Mengirim tautan…' : 'Kirim tautan reset',
                icon: Icons.mark_email_read_outlined,
                isLoading: isLoading,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SentCard extends StatelessWidget {
  const _SentCard({
    required this.email,
    required this.onOpenGmail,
    required this.onUseAnotherEmail,
    required this.onBackToLogin,
  });

  final String email;
  final VoidCallback onOpenGmail;
  final VoidCallback onUseAnotherEmail;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const AuthMessageBanner(
            message:
                'Belum masuk? Cek folder Spam atau Promosi, lalu cari email dari Dompetku.',
            tone: AuthMessageTone.info,
            icon: Icons.search_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthPrimaryButton(
            label: 'Buka Gmail',
            icon: Icons.open_in_new_rounded,
            onPressed: onOpenGmail,
          ),
          const SizedBox(height: AppSpacing.xs),
          AuthSecondaryButton(
            label: 'Gunakan email lain',
            icon: Icons.alternate_email_rounded,
            onPressed: onUseAnotherEmail,
          ),
          const SizedBox(height: AppSpacing.xxs),
          TextButton(
            onPressed: onBackToLogin,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            child: const Text('Kembali ke Masuk'),
          ),
        ],
      ),
    );
  }
}
