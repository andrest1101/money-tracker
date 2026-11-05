import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> buildApp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const SavuApp(),
  );
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(await buildApp());
  await tester.pumpAndSettle();
}

Finder navBarLabel(String label) {
  return find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
}

void main() {
  testWidgets('app shell menampilkan navigation bar empat tab dan FAB', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Beranda', 'Target', 'Riwayat', 'Pengaturan']) {
      expect(navBarLabel(label), findsOneWidget);
    }
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byTooltip('Catat transaksi'), findsOneWidget);
  });

  testWidgets('pindah tab melalui navigation bar', (tester) async {
    await pumpApp(tester);

    await tester.tap(navBarLabel('Riwayat'));
    await tester.pumpAndSettle();

    expect(navBarLabel('Riwayat'), findsOneWidget);
    expect(find.text('Cari transaksi'), findsNothing);

    expect(find.byTooltip('Cari transaksi'), findsOneWidget);
  });

  testWidgets('Riwayat membuka pencarian inline dan filter sheet', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(navBarLabel('Riwayat'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((widget) => widget is SegmentedButton),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Cari transaksi'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.byTooltip('Tutup pencarian'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Terapkan'), findsOneWidget);
  });

  testWidgets('tab pengaturan tidak menampilkan FAB', (tester) async {
    await pumpApp(tester);

    await tester.tap(navBarLabel('Pengaturan'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('FAB beranda membuka form transaksi baru', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Catat transaksi'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Transaksi'), findsOneWidget);
    expect(find.text('Nominal'), findsOneWidget);
  });

  testWidgets('quick add sheet memvalidasi nominal kosong', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Catat transaksi'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Nominal wajib diisi'), findsOneWidget);
  });

  testWidgets('FAB tab target membuka form target tabungan', (tester) async {
    await pumpApp(tester);

    await tester.tap(navBarLabel('Target'));
    await tester.pumpAndSettle();

    expect(find.text('Target Tabungan'), findsOneWidget);

    await tester.tap(find.byTooltip('Buat target'));
    await tester.pumpAndSettle();

    expect(find.text('Target Tabungan Baru'), findsOneWidget);
  });

  testWidgets('placeholder catatan mengikuti kategori yang dipilih', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Catat transaksi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Makanan'));
    await tester.pump();
    expect(find.text('Contoh: makan siang di warung'), findsOneWidget);

    await tester.tap(find.text('Bensin'));
    await tester.pump();
    expect(find.text('Contoh: isi bensin motor'), findsOneWidget);

    await tester.tap(find.text('Hiburan'));
    await tester.pump();
    expect(find.text('Contoh: nonton film bioskop'), findsOneWidget);
  });

  testWidgets('placeholder kategori custom memakai nama kategori', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Catat transaksi'));
    await tester.pumpAndSettle();

    final newCategoryChip = find.widgetWithText(ActionChip, 'Baru');
    await tester.scrollUntilVisible(
      newCategoryChip,
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(newCategoryChip);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Perbaikan kendaraan');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Contoh: detail Perbaikan kendaraan'), findsOneWidget);
  });

  testWidgets('kategori custom pengeluaran tidak muncul di pemasukan', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Catat transaksi'));
    await tester.pumpAndSettle();

    final newCategoryChip = find.widgetWithText(ActionChip, 'Baru');
    await tester.ensureVisible(newCategoryChip);
    await tester.tap(newCategoryChip);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Kosmetik');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Kosmetik'), findsOneWidget);
    await tester.tap(find.text('Pemasukan'));
    await tester.pump();

    expect(find.text('Kosmetik'), findsNothing);
  });
}
