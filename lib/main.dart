import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/firebase/auth_providers.dart';
import 'core/local_storage/settings_providers.dart';
import 'core/navigation/app_shell.dart';
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
      child: const _AuthGate(),
    ),
  );
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ref.watch(appThemeModeProvider),
      home: const AppShell(),
    );
  }
}
