import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/main.dart';

void main() {
  testWidgets('app shell menampilkan navigation bar dan tab beranda', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MoneyTrackerApp()));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('Beranda')),
      findsOneWidget,
    );
  });

  testWidgets('pindah tab melalui navigation bar', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MoneyTrackerApp()));

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat transaksi akan dibangun di Task 10-12'), findsOneWidget);
  });
}
