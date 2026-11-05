import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/savings/presentation/providers/savings_providers.dart';
import 'package:savu/features/savings/presentation/pages/savings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpSavings(WidgetTester tester, {double textScale = 1}) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          savingsGoalsStreamProvider.overrideWith(
            (ref) => Stream.value(const []),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const SavingsPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('menu target menyediakan arsip dan opsi urutan', (tester) async {
    await pumpSavings(tester);

    await tester.tap(find.byTooltip('Opsi target'));
    await tester.pumpAndSettle();
    expect(find.text('Diarsipkan'), findsOneWidget);
    expect(find.text('Urutkan'), findsOneWidget);
    await tester.tap(find.text('Urutkan'));
    await tester.pumpAndSettle();
    expect(find.text('Urutkan target'), findsOneWidget);
    expect(find.text('Progres tertinggi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state target tersedia di tab Aktif dan Selesai', (
    tester,
  ) async {
    await pumpSavings(tester, textScale: 1.3);

    expect(find.text('Belum ada target aktif'), findsOneWidget);
    expect(find.textContaining('tombol +'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada target selesai'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
