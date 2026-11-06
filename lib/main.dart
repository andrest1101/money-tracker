import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/firebase/auth_providers.dart';
import 'core/local_storage/settings_providers.dart';
import 'core/navigation/app_shell.dart';
import 'core/theme/app_motion.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_landing_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootstrapApp());
}

/// Menyiapkan Firebase dan penyimpanan lokal sebelum UI utama tampil.
///
/// Jika salah satu gagal (misalnya konfigurasi Firebase tidak cocok atau
/// perangkat sedang offline), pengguna melihat layar pemulihan yang bisa
/// dicoba ulang alih-alih layar putih.
class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<SharedPreferences> _bootstrap = _initialize();

  Future<SharedPreferences> _initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return SharedPreferences.getInstance();
  }

  void _retry() {
    setState(() {
      _bootstrap = _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _BootstrapErrorApp(onRetry: _retry);
        }
        final preferences = snapshot.data;
        if (preferences == null) {
          return MaterialApp(
            title: 'Dompetku',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
          child: const _AuthLinkHandler(child: _AuthGate()),
        );
      },
    );
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dompetku',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak dapat terhubung ke Firebase',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Periksa koneksi internet dan konfigurasi Firebase, lalu coba lagi.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AuthLinkHandler extends ConsumerStatefulWidget {
  const _AuthLinkHandler({required this.child});

  final Widget child;

  @override
  ConsumerState<_AuthLinkHandler> createState() => _AuthLinkHandlerState();
}

class _AuthLinkHandlerState extends ConsumerState<_AuthLinkHandler> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _handlingLink = false;
  String? _lastHandledLink;

  @override
  void initState() {
    super.initState();
    _initAuthLinks();
  }

  Future<void> _initAuthLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) await _handleUri(initialUri);
      _subscription = _appLinks.uriLinkStream.listen(_handleUri);
    } catch (_) {
      // The paste-link fallback remains available if platform link delivery fails.
    }
  }

  Future<void> _handleUri(Uri uri) async {
    final link = _emailSignInLink(uri);
    if (link == null) return;
    if (link == _lastHandledLink || !mounted) {
      return;
    }
    _lastHandledLink = link;
    setState(() => _handlingLink = true);
    try {
      final email =
          uri.queryParameters['email'] ??
          Uri.tryParse(link)?.queryParameters['email'] ??
          ref.read(pendingEmailLinkEmailProvider);
      if (email == null || email.trim().isEmpty) return;
      await ref
          .read(authControllerProvider.notifier)
          .completeEmailLink(email: email, link: link);
    } finally {
      if (mounted) setState(() => _handlingLink = false);
    }
  }

  String? _emailSignInLink(Uri uri) {
    Uri candidate = uri;
    final continueUrl = uri.queryParameters['continueUrl'];
    if (continueUrl != null) {
      final nested = Uri.tryParse(Uri.decodeComponent(continueUrl));
      if (nested != null && nested.queryParameters.containsKey('oobCode')) {
        candidate = nested;
      }
    }
    final hasSignInCode =
        candidate.queryParameters.containsKey('oobCode') &&
        candidate.queryParameters['mode'] == 'signIn';
    return hasSignInCode ? candidate.toString() : null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_handlingLink) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return widget.child;
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final auth = ref.watch(authStateChangesProvider);
    final animationsEnabled = !AppMotion.isReduced(context);
    return MaterialApp(
      title: 'Dompetku',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: AnimatedSwitcher(
        duration: animationsEnabled
            ? const Duration(milliseconds: 420)
            : Duration.zero,
        reverseDuration: animationsEnabled
            ? const Duration(milliseconds: 280)
            : Duration.zero,
        switchInCurve: AppMotion.standard,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, .025),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: onboardingCompleted
            ? _AuthContent(key: const ValueKey('auth'), auth: auth)
            : const OnboardingPage(key: ValueKey('onboarding')),
      ),
    );
  }
}

class _AuthContent extends StatelessWidget {
  const _AuthContent({super.key, required this.auth});

  final AsyncValue<User?> auth;

  @override
  Widget build(BuildContext context) {
    return auth.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const AuthLandingPage(),
      data: (user) {
        if (user == null) return const AuthLandingPage();
        final needsVerification =
            !user.isAnonymous &&
            user.providerData.any(
              (provider) => provider.providerId == 'password',
            ) &&
            !user.emailVerified;
        if (needsVerification) return EmailVerificationPage(user: user);
        return const DompetkuApp();
      },
    );
  }
}

class DompetkuApp extends ConsumerWidget {
  const DompetkuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Dompetku',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: theme.colorScheme.surface,
            systemNavigationBarDividerColor: theme.colorScheme.surface,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppShell(),
    );
  }
}
