import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/firebase/auth_providers.dart';
import 'core/local_storage/settings_providers.dart';
import 'core/navigation/app_shell.dart';
import 'core/theme/money_tracker_theme.dart';
import 'features/auth/presentation/pages/auth_landing_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const _AuthLinkHandler(child: _AuthGate()),
    ),
  );
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
    final auth = ref.watch(authStateChangesProvider);
    return auth.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthLandingPage(),
      ),
      data: (user) {
        if (user == null) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AuthLandingPage(),
          );
        }
        final needsVerification =
            !user.isAnonymous &&
            user.providerData.any(
              (provider) => provider.providerId == 'password',
            ) &&
            !user.emailVerified;
        if (needsVerification) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: EmailVerificationPage(user: user),
          );
        }
        return const MoneyTrackerApp();
      },
    );
  }
}

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MoneyTracker',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(appThemeModeProvider),
      theme: MoneyTrackerTheme.light(),
      darkTheme: MoneyTrackerTheme.dark(),
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
            statusBarBrightness: isDark
                ? Brightness.dark
                : Brightness.light,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppShell(),
    );
  }
}
