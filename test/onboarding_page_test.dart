import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpOnboarding(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tombol Lanjutkan berpindah ke slide berikutnya', (tester) async {
    await pumpOnboarding(tester);

    expect(find.textContaining('Catat Transaksi'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Lanjutkan'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Lanjutkan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pantau Anggaran'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tombol Lanjutkan tetap bekerja di layar pendek', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Lanjutkan'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Lanjutkan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pantau Anggaran'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
