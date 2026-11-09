import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:savu/features/export/data/providers/export_repository_provider.dart';
import 'package:savu/features/export/data/repositories/export_repository_impl.dart';
import 'package:savu/features/export/domain/entities/export_options.dart';
import 'package:savu/features/export/domain/entities/report_summary.dart';
import 'package:savu/features/export/domain/repositories/export_repository.dart';
import 'package:savu/features/export/presentation/widgets/export_sheet.dart';
import 'package:savu/features/savings/presentation/providers/savings_providers.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late _FakeExportRepository repository;

  Future<void> openExportSheet(
    WidgetTester tester, {
    List<TransactionEntity> transactions = const [],
    double textScale = 1,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    repository = _FakeExportRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          transactionsStreamProvider.overrideWith(
            (ref) => Stream.value(transactions),
          ),
          savingsGoalsStreamProvider.overrideWith(
            (ref) => Stream.value(const []),
          ),
          exportRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => ExportSheet.show(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan format, periode, pratinjau, dan tombol bagi', (
    tester,
  ) async {
    await openExportSheet(
      tester,
      transactions: _fixtureTransactions(),
    );

    expect(find.text('Ekspor data'), findsOneWidget);
    expect(find.text('Laporan Excel'), findsOneWidget);
    expect(find.text('CSV Data'), findsOneWidget);
    expect(find.text('Periode'), findsOneWidget);
    expect(find.textContaining('43 transaksi'), findsOneWidget);
    expect(find.text('Bagikan Laporan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('beralih ke CSV menampilkan pemisah dan mengirim opsi CSV', (
    tester,
  ) async {
    await openExportSheet(
      tester,
      transactions: _fixtureTransactions(),
    );

    await tester.tap(find.text('CSV Data'));
    await tester.pumpAndSettle();
    expect(find.text('Pemisah CSV'), findsOneWidget);
    expect(find.text('Titik koma (;)'), findsOneWidget);

    await tester.tap(find.text('Koma (,)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bagikan CSV'));
    await tester.pumpAndSettle();

    expect(repository.options?.format, ExportFormat.csv);
    expect(repository.options?.delimiter, CsvDelimiter.comma);
    expect(repository.options?.period, ExportPeriodType.allTime);
    expect(repository.summary?.transactionCount, 43);
    expect(find.text('open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('memilih tanggal menampilkan tombol rentang dan menonaktifkan bagi', (
    tester,
  ) async {
    await openExportSheet(
      tester,
      transactions: _fixtureTransactions(),
    );

    await tester.tap(find.text('Tanggal'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih rentang tanggal'), findsOneWidget);
    expect(
      tester.widget<ButtonStyleButton>(_shareButton()).onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('menonaktifkan berbagi saat periode kosong', (tester) async {
    await openExportSheet(tester);

    expect(find.text('Belum ada transaksi di periode ini.'), findsOneWidget);
    expect(
      tester.widget<ButtonStyleButton>(_shareButton()).onPressed,
      isNull,
    );
  });

  testWidgets('menampilkan snackbar saat ekspor gagal dan tetap membuka sheet', (
    tester,
  ) async {
    await openExportSheet(
      tester,
      transactions: _fixtureTransactions(),
    );
    repository.succeed = false;
    repository.errorMessage = 'Gagal menyiapkan file ekspor. Coba lagi.';

    await tester.tap(find.text('Bagikan Laporan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.text('Gagal menyiapkan file ekspor. Coba lagi.'),
      findsOneWidget,
    );
    expect(find.text('Ekspor data'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('layout ekspor tidak overflow di 360dp dan text scale 1.3', (
    tester,
  ) async {
    await openExportSheet(
      tester,
      transactions: _fixtureTransactions(),
      textScale: 1.3,
    );

    expect(find.text('Ekspor data'), findsOneWidget);
    expect(find.text('Bagikan Laporan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder _shareButton() {
  return find.ancestor(
    of: find.text('Bagikan Laporan'),
    matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  );
}

List<TransactionEntity> _fixtureTransactions() {
  return [
    for (var index = 0; index < 43; index++)
      TransactionEntity(
        id: 'transaction-$index',
        amount: 10000,
        type: index == 0 ? TransactionType.income : TransactionType.expense,
        category: index == 0 ? 'Gaji' : 'Makanan',
        date: DateTime(2026, 9, 29),
        note: 'test',
      ),
  ];
}

class _FakeExportRepository implements ExportRepository {
  bool succeed = true;
  String? errorMessage;
  ExportOptions? options;
  ReportSummary? summary;

  @override
  Future<void> shareReport({
    required ReportSummary summary,
    required ExportOptions options,
  }) async {
    if (!succeed) {
      throw ExportRepositoryException(
        errorMessage ?? 'Gagal menyiapkan file ekspor. Coba lagi.',
      );
    }
    this.summary = summary;
    this.options = options;
  }
}
