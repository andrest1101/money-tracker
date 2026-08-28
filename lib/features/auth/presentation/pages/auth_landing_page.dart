import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_providers.dart';

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
        if (mounted) _showEmailAuth(initialLink: link);
      });
    }
  }

  Future<void> _google() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  Future<void> _guest() async {
    await ref.read(authControllerProvider.notifier).continueAsGuest();
  }

  Future<void> _showEmailAuth({String? initialLink}) async {
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => EmailAuthSheet(initialLink: initialLink),
    );
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, colors.surface],
            stops: const [0, .62],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: .25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 40,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 34),
                  Text(
                    'Keuangan lebih tertata,\nmulai dari sini.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Catat pengeluaran tanpa ribet, pantau batas anggaran, dan wujudkan target tabunganmu sedikit demi sedikit.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _BenefitRow(
                    icon: Icons.bolt_rounded,
                    title: 'Catat dalam hitungan detik',
                    subtitle: 'Tidak ada formulir panjang yang mengganggu.',
                  ),
                  const _BenefitRow(
                    icon: Icons.insights_rounded,
                    title: 'Pahami pola pengeluaranmu',
                    subtitle: 'Insight sederhana untuk keputusan lebih baik.',
                  ),
                  const _BenefitRow(
                    icon: Icons.shield_outlined,
                    title: 'Data tetap milikmu',
                    subtitle:
                        'Simpan lokal sebagai guest atau amankan dengan akun.',
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state.isLoading ? null : _google,
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                      label: const Text('Lanjutkan dengan Google'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoading ? null : _showEmailAuth,
                      icon: const Icon(Icons.mail_outline_rounded),
                      label: const Text('Masuk dengan email atau link'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: state.isLoading ? null : _guest,
                      child: const Text('Coba sebagai Guest'),
                    ),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Dengan melanjutkan, kamu menyetujui penggunaan Firebase Authentication untuk menjaga sesi akunmu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: colors.surface.withValues(alpha: .75),
            child: Icon(icon, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _EmailMode { login, register, link }

class EmailAuthSheet extends ConsumerStatefulWidget {
  const EmailAuthSheet({super.key, this.initialLink});

  final String? initialLink;

  @override
  ConsumerState<EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends ConsumerState<EmailAuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _link = TextEditingController();
  _EmailMode _mode = _EmailMode.login;
  bool _obscure = true;
  bool _linkSent = false;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialLink != null) {
      _mode = _EmailMode.link;
      _linkSent = true;
      _link.text = widget.initialLink!;
      final savedEmail = ref.read(pendingEmailLinkEmailProvider);
      if (savedEmail != null) _email.text = savedEmail;
    }
  }

  @override
  void dispose() {
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
        return;
      }
    } else {
      await controller.completeEmailLink(email: _email.text, link: _link.text);
    }
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasValue &&
        (_mode != _EmailMode.link || _linkSent)) {
      final message = _mode == _EmailMode.register
          ? 'Akun berhasil dibuat. Selamat datang di MoneyTracker.'
          : _mode == _EmailMode.login
          ? 'Login berhasil. Selamat datang kembali.'
          : 'Link login berhasil diverifikasi.';
      Navigator.pop(context, message);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan email yang valid terlebih dahulu.'),
        ),
      );
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text);
    if (!mounted) return;
    if (!ref.read(authControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link reset password dikirim ke emailmu.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final isLink = _mode == _EmailMode.link;
    final title = switch (_mode) {
      _EmailMode.login => 'Selamat datang kembali',
      _EmailMode.register => 'Buat akun MoneyTracker',
      _EmailMode.link =>
        _linkSent ? 'Masukkan link login' : 'Login tanpa password',
    };
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isLink
                  ? 'Kami kirim link aman ke emailmu. Tidak perlu mengingat password.'
                  : 'Gunakan email asli agar akun dan catatanmu mudah dipulihkan.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            SegmentedButton<_EmailMode>(
              segments: const [
                ButtonSegment(value: _EmailMode.login, label: Text('Masuk')),
                ButtonSegment(
                  value: _EmailMode.register,
                  label: Text('Daftar'),
                ),
                ButtonSegment(
                  value: _EmailMode.link,
                  label: Text('Email link'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (value) => setState(() {
                _mode = value.first;
                _linkSent = false;
              }),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Masukkan email yang valid',
                  ),
                  if (!isLink) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : 'Password minimal 6 karakter',
                    ),
                  ],
                  if (_mode == _EmailMode.register) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Ulangi password',
                        prefixIcon: Icon(Icons.verified_user_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == _password.text
                          ? null
                          : 'Password belum sama',
                    ),
                  ],
                  if (_linkSent) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _link,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Tempel link dari email di sini',
                        prefixIcon: Icon(Icons.link_rounded),
                        border: OutlineInputBorder(),
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
                  onPressed: authState.isLoading ? null : _resetPassword,
                  child: const Text('Lupa password?'),
                ),
              ),
            const SizedBox(height: 6),
            if (_successMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.mark_email_read_rounded, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: authState.isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isLink && _linkSent
                            ? 'Verifikasi link'
                            : isLink
                            ? 'Kirim link login'
                            : _mode == _EmailMode.login
                            ? 'Masuk ke akun'
                            : 'Buat akun',
                      ),
              ),
            ),
            if (authState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  authState.error.toString(),
                  style: TextStyle(color: colors.error),
                ),
              ),
            if (_linkSent)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Setelah menekan link di Gmail, halaman ini akan menyelesaikan login. Jika belum, tempel link lengkap di atas.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Password diproses oleh Firebase Authentication, bukan disimpan di database aplikasi.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
