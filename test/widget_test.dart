import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/core/navigation/app_shell.dart';
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

void main() {
  testWidgets('app shell menampilkan navigation bar dan tab beranda', (
    tester,
  ) async {
    await tester.pumpWidget(await buildApp());

    expect(find.byType(FloatingPillNavigation), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FloatingPillNavigation),
        matching: find.text('Beranda'),
      ),
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

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buat Catatan Baru'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Nominal wajib diisi'), findsOneWidget);
  });

  testWidgets('tombol tambah menampilkan pilihan catatan dan target', (
    tester,
  ) async {
    await tester.pumpWidget(await buildApp());

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Buat Catatan Baru'), findsOneWidget);
    expect(find.text('Buat Target Tabungan Baru'), findsOneWidget);
  });

  testWidgets('placeholder catatan mengikuti kategori yang dipilih', (
    tester,
  ) async {
    await tester.pumpWidget(await buildApp());

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Catatan Baru'));
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
    await tester.pumpWidget(await buildApp());

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Catatan Baru'));
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
    await tester.pumpWidget(await buildApp());

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Catatan Baru'));
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
