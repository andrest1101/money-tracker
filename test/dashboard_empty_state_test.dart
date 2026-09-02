import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/features/dashboard/presentation/widgets/dashboard_empty_state.dart';

void main() {
  testWidgets('empty state menampilkan greeting dan CTA transaksi', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardEmptyState(
            userName: 'Andre Robert',
            onAdd: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Halo, Andre Robert!'), findsOneWidget);
    expect(find.text('Mulai perjalanan finansialmu'), findsOneWidget);
    expect(find.text('Catat transaksi'), findsOneWidget);

    await tester.tap(find.text('Catat transaksi'));
    expect(tapped, isTrue);
  });

  testWidgets('empty state aman untuk nama pengguna panjang', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardEmptyState(
            userName: 'Nama Pengguna Dengan Identitas Sangat Panjang',
            onAdd: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Mulai perjalanan finansialmu'), findsOneWidget);
  });
}
