import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_background.dart';
import '../widgets/auth_error_message.dart';
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
  bool _obscure = true;
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
      if (savedEmail != null) _email.text = savedEmail;
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
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
      if (mounted && !ref.read(authControllerProvider).hasError) {
        setState(() {
          _linkSent = true;
          _successMessage =
              'Link login berhasil dikirim. Periksa Inbox atau Spam Gmail.';
        });
        _startResendCooldown();
        return;
      }
    } else {
      await controller.completeEmailLink(email: _email.text, link: _link.text);
    }
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasValue &&
        (_mode != _EmailMode.link || _linkSent)) {
      final message = _mode == _EmailMode.register
          ? 'Akun berhasil dibuat. Selamat datang di Dompetku.'
          : _mode == _EmailMode.login
          ? 'Login berhasil. Selamat datang kembali.'
          : 'Link login berhasil diverifikasi.';
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
    await ref.read(authControllerProvider.notifier).sendEmailLink(_email.text);
    if (!mounted || ref.read(authControllerProvider).hasError) return;
    setState(() {
      _successMessage =
          'Link login baru berhasil dikirim. Periksa Inbox atau Spam Gmail.';
    });
    _startResendCooldown();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            tooltip: 'Kembali ke beranda',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            'Dompetku',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          titleSpacing: 0,
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final veryCompact = constraints.maxHeight < 680;
              final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
              final horizontalPadding = switch (constraints.maxWidth) {
                < 380 => 18.0,
                < 920 => 24.0,
                _ => 40.0,
              };
              final verticalPadding = veryCompact ? 12.0 : 28.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  keyboardInset + verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - verticalPadding * 2)
                        .clamp(0.0, double.infinity),
                  ),
                  child: Center(
                    child: constraints.maxWidth >= 920
                        ? _buildWideLayout()
                        : _buildCompactLayout(veryCompact: veryCompact),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1080),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: _buildBrandPanel()),
          const SizedBox(width: AppSpacing.xxl),
          Expanded(flex: 6, child: _buildFormCard()),
        ],
      ),
    );
  }

  Widget _buildCompactLayout({required bool veryCompact}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.md,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'DOMPETKU',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          _buildFormCard(compact: veryCompact),
        ],
      ),
    );
  }

  Widget _buildBrandPanel() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 480),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'DOMPETKU',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Catat.\nAtur.\nCapai.',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.02,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Satu akun untuk transaksi, anggaran, dan target tabunganmu.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _BrandPoint(
            icon: Icons.receipt_long_outlined,
            label: 'Transaksi harian',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _BrandPoint(
            icon: Icons.donut_large_outlined,
            label: 'Anggaran terpantau',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _BrandPoint(
            icon: Icons.savings_outlined,
            label: 'Target lebih terarah',
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({bool compact = false}) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isLink = _mode == _EmailMode.link;
    final title = switch (_mode) {
      _EmailMode.login => 'Selamat datang kembali',
      _EmailMode.register => 'Buat akun Dompetku',
      _EmailMode.link =>
        _linkSent ? 'Masukkan link login' : 'Login tanpa password',
    };
    final subtitle = switch (_mode) {
      _EmailMode.login => 'Masuk untuk melanjutkan ke akunmu.',
      _EmailMode.register =>
        'Daftar dan sinkronkan catatanmu ke semua perangkat.',
      _EmailMode.link => 'Kami akan mengirim tautan aman ke emailmu.',
    };
    final submitLabel = switch (_mode) {
      _EmailMode.login => 'Masuk ke Dompetku',
      _EmailMode.register => 'Buat akun',
      _EmailMode.link =>
        isLink && _linkSent ? 'Verifikasi link' : 'Kirim link login',
    };
    final submitIcon = switch (_mode) {
      _EmailMode.login => Icons.login_rounded,
      _EmailMode.register => Icons.person_add_alt_1_rounded,
      _EmailMode.link => Icons.mark_email_read_outlined,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Icon(
                  isLink
                      ? Icons.mark_email_unread_outlined
                      : _mode == _EmailMode.register
                      ? Icons.person_outline_rounded
                      : Icons.lock_open_rounded,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AKUN DOMPETKU',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<_EmailMode>(
            segments: const [
              ButtonSegment(
                value: _EmailMode.login,
                label: Text('Masuk'),
                icon: Icon(Icons.person_outline_rounded, size: 18),
              ),
              ButtonSegment(
                value: _EmailMode.register,
                label: Text('Daftar'),
                icon: Icon(Icons.person_add_alt_rounded, size: 18),
              ),
              ButtonSegment(
                value: _EmailMode.link,
                label: Text('Email link'),
                icon: Icon(Icons.mail_outline_rounded, size: 18),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (value) {
              ref.read(authControllerProvider.notifier).clearError();
              _resendTimer?.cancel();
              setState(() {
                _mode = value.first;
                _linkSent = false;
                _resendSeconds = 0;
                _successMessage = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: _authInputDecoration(
                    scheme: colors,
                    labelText: 'Email',
                    prefixIcon: Icons.alternate_email_rounded,
                  ),
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Masukkan email yang valid',
                ),
                if (!isLink) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    decoration: _authInputDecoration(
                      scheme: colors,
                      labelText: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        tooltip: _obscure
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => value != null && value.length >= 6
                        ? null
                        : 'Password minimal 6 karakter',
                  ),
                ],
                if (_mode == _EmailMode.register) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _confirm,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: _authInputDecoration(
                      scheme: colors,
                      labelText: 'Ulangi password',
                      prefixIcon: Icons.verified_user_outlined,
                    ),
                    validator: (value) =>
                        value == _password.text ? null : 'Password belum sama',
                  ),
                ],
                if (_linkSent) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _link,
                    minLines: 2,
                    maxLines: 4,
                    decoration: _authInputDecoration(
                      scheme: colors,
                      labelText: 'Tempel link dari email di sini',
                      prefixIcon: Icons.link_rounded,
                    ),
                    validator: (value) =>
                        value != null && value.startsWith('http')
                        ? null
                        : 'Tempel link login yang valid',
                  ),
                ],
              ],
            ),
          ),
          if (_mode == _EmailMode.login)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ResetPasswordPage(initialEmail: _email.text.trim()),
                  ),
                ),
                child: const Text('Lupa password?'),
              ),
            ),
          if (_successMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _SuccessMessage(message: _successMessage!, isDark: isDark),
          ],
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: authState.isLoading ? null : _submit,
            icon: authState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(submitIcon),
            label: Text(authState.isLoading ? 'Memproses…' : submitLabel),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
            ),
          ),
          if (authState.hasError) ...[
            const SizedBox(height: AppSpacing.sm),
            AuthErrorMessage(message: authState.error.toString()),
          ],
          if (_linkSent) ...[
            const SizedBox(height: AppSpacing.sm),
            const _InfoMessage(
              icon: Icons.touch_app_outlined,
              text:
                  'Jika link tidak terbuka otomatis, tempel tautan dari email ke kolom di atas.',
            ),
            if (_mode == _EmailMode.link)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: authState.isLoading || _resendSeconds > 0
                      ? null
                      : _resendLink,
                  child: Text(
                    _resendSeconds > 0
                        ? 'Kirim ulang dalam $_resendSeconds detik'
                        : 'Kirim ulang link',
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BrandPoint extends StatelessWidget {
  const _BrandPoint({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({required this.message, required this.isDark});

  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: isDark ? Border.all(color: colors.outlineVariant) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mark_email_read_rounded, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _authInputDecoration({
  required ColorScheme scheme,
  required String labelText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  final borderRadius = BorderRadius.circular(AppRadius.control);

  return InputDecoration(
    labelText: labelText,
    prefixIcon: Icon(prefixIcon),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: scheme.surfaceContainerLow,
    border: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: scheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: scheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: scheme.primary, width: 1.5),
    ),
  );
}
