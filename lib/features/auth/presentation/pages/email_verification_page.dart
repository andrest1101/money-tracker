import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_providers.dart';

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

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0) return;
    await ref.read(authControllerProvider.notifier).sendEmailVerification();
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) return;
    setState(() => _secondsRemaining = 60);
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verifikasi dikirim. Cek Inbox atau Spam.'),
      ),
    );
  }

  Future<void> _checkVerification() async {
    final verified = await ref
        .read(authControllerProvider.notifier)
        .reloadCurrentUser();
    if (!mounted) return;
    if (verified) {
      ref.invalidate(authStateChangesProvider);
      return;
    }
    final state = ref.read(authControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.hasError
              ? state.error.toString()
              : 'Email belum terverifikasi. Buka link di email terlebih dahulu.',
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;
    ref.invalidate(authStateChangesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authState = ref.watch(authControllerProvider);
    final email = widget.user.email ?? 'email akunmu';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: colors.primaryContainer,
                        child: Icon(
                          Icons.mark_email_unread_rounded,
                          size: 38,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Verifikasi emailmu',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kami mengirim link verifikasi ke:',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Klik link tersebut untuk memastikan email ini benar-benar milikmu. Jika tidak ada di Inbox, periksa folder Spam atau Promosi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: authState.isLoading
                              ? null
                              : _checkVerification,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Saya sudah verifikasi'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              authState.isLoading || _secondsRemaining > 0
                              ? null
                              : _resend,
                          icon: const Icon(Icons.send_rounded),
                          label: Text(
                            _secondsRemaining > 0
                                ? 'Kirim ulang dalam ${_secondsRemaining}s'
                                : 'Kirim ulang email verifikasi',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: authState.isLoading ? null : _signOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Gunakan akun lain'),
                      ),
                      if (authState.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            authState.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
