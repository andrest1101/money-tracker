import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../utils/auth_error_text.dart';
import '../utils/mail_launcher.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_message_banner.dart';
import '../widgets/auth_mode_switcher.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import 'reset_password_page.dart';

enum _EmailMode { login, register, link }

class EmailAuthPage extends ConsumerStatefulWidget {
  const EmailAuthPage({super.key, this.initialLink, this.initialEmail});

  final String? initialLink;
  final String? initialEmail;

  @override
  ConsumerState<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends ConsumerState<EmailAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _link = TextEditingController();
  _EmailMode _mode = _EmailMode.login;
  bool _linkSent = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialLink != null) {
      _mode = _EmailMode.link;
      _linkSent = true;
      _link.text = widget.initialLink!;
      final savedEmail =
          widget.initialEmail ?? ref.read(pendingEmailLinkEmailProvider);
      if (savedEmail != null && savedEmail.trim().isNotEmpty) {
        _email.text = savedEmail.trim();
      }
    } else if (widget.initialEmail != null &&
        widget.initialEmail!.trim().isNotEmpty) {
      _email.text = widget.initialEmail!.trim();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _link.dispose();
    super.dispose();
  }

  bool get _isLink => _mode == _EmailMode.link;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (ref.read(authControllerProvider).isLoading) return;

    final controller = ref.read(authControllerProvider.notifier);
    if (_mode == _EmailMode.login) {
      await controller.signInWithEmail(
        email: _email.text,
        password: _password.text,
      );
    } else if (_mode == _EmailMode.register) {
      await controller.registerWithEmail(
        email: _email.text,
        password: _password.text,
      );
    } else if (!_linkSent) {
      await controller.sendEmailLink(_email.text);
      if (!mounted || ref.read(authControllerProvider).hasError) return;
      setState(() {
        _linkSent = true;
        _successMessage =
            'Tautan masuk dikirim ke ${_email.text.trim()}. Buka tautan di email, atau tempel di kolom bawah.';
      });
      _startResendCooldown();
      return;
    } else {
      await controller.completeEmailLink(email: _email.text, link: _link.text);
    }

    if (!mounted) return;
    if (ref.read(authControllerProvider).hasValue &&
        (_mode != _EmailMode.link || _linkSent)) {
      final message = switch (_mode) {
        _EmailMode.register => 'Akun berhasil dibuat. Selamat datang di Dompetku.',
        _EmailMode.login => 'Login berhasil. Selamat datang kembali.',
        _EmailMode.link => 'Link login berhasil diverifikasi.',
      };
      TextInput.finishAutofillContext(shouldSave: true);
      Navigator.pop(context, message);
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _resendLink() async {
    if (_resendSeconds > 0 || _email.text.trim().isEmpty) return;
    if (ref.read(authControllerProvider).isLoading) return;
    await ref.read(authControllerProvider.notifier).sendEmailLink(_email.text);
    if (!mounted || ref.read(authControllerProvider).hasError) return;
    setState(() {
      _successMessage =
          'Tautan masuk baru sudah dikirim. Periksa Inbox atau Spam.';
    });
    _startResendCooldown();
  }

  void _switchMode(_EmailMode mode) {
    ref.read(authControllerProvider.notifier).clearError();
    _resendTimer?.cancel();
    FocusScope.of(context).unfocus();
    setState(() {
      _mode = mode;
      _linkSent = false;
      _resendSeconds = 0;
      _successMessage = null;
      _link.clear();
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Masukkan alamat emailmu.';
    if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Masukkan password.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    return null;
  }

  String? _validateConfirmation(String? value) {
    if ((value ?? '').isEmpty) return 'Ulangi password baru.';
    if (value != _password.text) return 'Password belum sama.';
    return null;
  }

  String? _validateLink(String? value) {
    final link = value?.trim() ?? '';
    if (link.isEmpty) return 'Tempel tautan dari email.';
    if (!link.startsWith('http')) return 'Tautan login tidak valid.';
    return null;
  }

  void _openResetPassword() {
    final email = _email.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(
          initialEmail: email.isEmpty ? null : email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final error = authErrorText(authState);
    final isLoading = authState.isLoading;
    final showEmailField = !(_isLink && _linkSent);

    final title = switch (_mode) {
      _EmailMode.login => 'Selamat datang kembali',
      _EmailMode.register => 'Buat akun Dompetku',
      _EmailMode.link => _linkSent ? 'Cek emailmu' : 'Masuk tanpa password',
    };
    final subtitle = switch (_mode) {
      _EmailMode.login => 'Masuk untuk melanjutkan ke akunmu.',
      _EmailMode.register =>
        'Satu akun untuk sinkronisasi transaksi, anggaran, dan target tabungan.',
      _EmailMode.link => _linkSent
          ? 'Tautan masuk sudah dikirim. Buka tautan di email, atau tempel di kolom bawah.'
          : 'Kami kirim tautan aman ke emailmu. Tidak perlu mengingat password.',
    };
    final submitLabel = switch (_mode) {
      _EmailMode.login => 'Masuk ke Dompetku',
      _EmailMode.register => 'Buat akun',
      _EmailMode.link =>
        _linkSent ? 'Verifikasi tautan' : 'Kirim tautan masuk',
    };
    final submitIcon = switch (_mode) {
      _EmailMode.login => Icons.login_rounded,
      _EmailMode.register => Icons.person_add_alt_1_rounded,
      _EmailMode.link => _linkSent
          ? Icons.mark_email_read_rounded
          : Icons.send_rounded,
    };

    return AuthScaffold(
      panel: const AuthBrandPanel(
        description: 'Satu akun untuk transaksi, anggaran, dan target tabunganmu.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
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
                    AuthModeSwitcher(
                      labels: const ['Masuk', 'Daftar'],
                      selectedIndex: _mode == _EmailMode.register ? 1 : 0,
                      onChanged: (index) => _switchMode(
                        index == 0 ? _EmailMode.login : _EmailMode.register,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (showEmailField)
                      AuthTextField(
                        controller: _email,
                        label: 'Email',
                        hint: 'nama@gmail.com',
                        prefixIcon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: _isLink
                            ? TextInputAction.done
                            : TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: _validateEmail,
                        enabled: !isLoading,
                        onFieldSubmitted: _isLink ? (_) => _submit() : null,
                      ),
                    if (!_isLink) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AuthPasswordField(
                        controller: _password,
                        hint: 'Minimal 6 karakter',
                        textInputAction: _mode == _EmailMode.register
                            ? TextInputAction.next
                            : TextInputAction.done,
                        autofillHints: _mode == _EmailMode.register
                            ? const [AutofillHints.newPassword]
                            : const [AutofillHints.password],
                        validator: _validatePassword,
                        enabled: !isLoading,
                        onFieldSubmitted: _mode == _EmailMode.register
                            ? null
                            : (_) => _submit(),
                      ),
                      if (_mode == _EmailMode.login)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading ? null : _openResetPassword,
                            style: TextButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                            ),
                            child: const Text('Lupa password?'),
                          ),
                        ),
                    ],
                    if (_mode == _EmailMode.register) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AuthPasswordField(
                        controller: _confirm,
                        label: 'Ulangi password',
                        hint: 'Ketik ulang password baru',
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _validateConfirmation,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                    if (_isLink && _linkSent) ...[
                      AuthTextField(
                        controller: _link,
                        label: 'Tempel tautan dari email',
                        hint: 'https://…',
                        helperText:
                            'Gunakan kolom ini bila tautan tidak terbuka otomatis.',
                        prefixIcon: Icons.link_rounded,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 2,
                        maxLines: 4,
                        validator: _validateLink,
                        enabled: !isLoading,
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AuthMessageBanner(message: error),
                    ] else if (_successMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AuthMessageBanner(
                        message: _successMessage!,
                        tone: AuthMessageTone.success,
                        icon: Icons.mark_email_read_rounded,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AuthPrimaryButton(
                      label: isLoading ? 'Memproses…' : submitLabel,
                      icon: submitIcon,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    if (_mode == _EmailMode.login) ...[
                      const SizedBox(height: AppSpacing.xs),
                      TextButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => _switchMode(_EmailMode.link),
                        icon: const Icon(Icons.link_rounded, size: 18),
                        label: const Text('Masuk tanpa password'),
                      ),
                    ],
                    if (_isLink && !_linkSent) ...[
                      const SizedBox(height: AppSpacing.xs),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => _switchMode(_EmailMode.login),
                        child: const Text('Gunakan password'),
                      ),
                    ],
                    if (_isLink && _linkSent) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.xs,
                        runSpacing: 0,
                        children: [
                          TextButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => openGmail(context),
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            label: const Text('Buka Gmail'),
                          ),
                          TextButton(
                            onPressed:
                                isLoading || _resendSeconds > 0
                                ? null
                                : _resendLink,
                            child: Text(
                              _resendSeconds > 0
                                  ? 'Kirim ulang dalam $_resendSeconds detik'
                                  : 'Kirim ulang tautan',
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => _switchMode(_EmailMode.login),
                            child: const Text('Gunakan password'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthFooter(
            text: _isLink
                ? 'Tautan masuk hanya bisa dipakai sekali dan berlaku terbatas.'
                : 'Data akun dan transaksi tersimpan aman.',
          ),
        ],
      ),
    );
  }
}
