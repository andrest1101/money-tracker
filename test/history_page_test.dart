import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';
import 'package:savu/features/transactions/presentation/pages/history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpHistory(
    WidgetTester tester, {
    List<TransactionEntity> transactions = const [],
    double textScale = 1,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          transactionsStreamProvider.overrideWith(
            (ref) => Stream.value(transactions),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const HistoryPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state mengarahkan ke FAB tanpa CTA duplikat', (
    tester,
  ) async {
    await pumpHistory(tester);

    expect(find.text('Belum ada transaksi'), findsOneWidget);
    expect(find.textContaining('tombol +'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Riwayat tidak overflow pada 360dp dan text scale 1.3', (
    tester,
  ) async {
    await pumpHistory(tester, textScale: 1.3);

    expect(tester.takeException(), isNull);
  });

  testWidgets('filter sheet menerapkan kategori dan rentang tanggal aktif', (
    tester,
  ) async {
    await pumpHistory(
      tester,
      transactions: [
        TransactionEntity(
          id: 'expense-food',
          amount: 25000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime.now(),
          note: 'Makan siang',
        ),
        TransactionEntity(
          id: 'expense-fuel',
          amount: 50000,
          type: TransactionType.expense,
          category: 'Bensin',
          date: DateTime.now(),
          note: 'Isi bensin',
        ),
      ],
    );

    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Makanan').last);
    await tester.tap(find.text('7 hari'));
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('Makanan'), findsNWidgets(2));
    expect(find.text('Siklus aktif'), findsNothing);
    expect(find.textContaining('Makan siang'), findsOneWidget);
    expect(find.textContaining('Isi bensin'), findsNothing);
    expect(find.byTooltip('Hapus filter Makanan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter siklus aktif tetap bisa dihapus dari chip', (
    tester,
  ) async {
    await pumpHistory(
      tester,
      transactions: [
        TransactionEntity(
          id: 'expense',
          amount: 25000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime.now(),
          note: 'Makan siang',
        ),
      ],
    );

    await tester.tap(find.byTooltip('Filter transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siklus anggaran aktif'));
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Hapus filter Siklus aktif'), findsOneWidget);
    await tester.tap(find.byTooltip('Hapus filter Siklus aktif'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus filter Siklus aktif'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
