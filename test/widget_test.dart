import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/core/local_storage/settings_providers.dart';
import 'package:money_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> buildApp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MoneyTrackerApp(),
  );
}

void main() {
  testWidgets('app shell menampilkan navigation bar dan tab beranda', (tester) async {
    await tester.pumpWidget(await buildApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('Beranda')),
      findsOneWidget,
    );
  });

  testWidgets('pindah tab melalui navigation bar', (tester) async {
    await tester.pumpWidget(await buildApp());

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada transaksi'), findsOneWidget);
  });

  testWidgets('quick add sheet memvalidasi nominal kosong', (tester) async {
    await tester.pumpWidget(await buildApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Nominal wajib diisi'), findsOneWidget);
  });
}
