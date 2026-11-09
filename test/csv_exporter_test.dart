import 'package:flutter_test/flutter_test.dart';

import 'package:savu/core/constants/finance_categories.dart';
import 'package:savu/features/export/data/exporters/csv_exporter.dart';
import 'package:savu/features/export/domain/entities/export_options.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';

import 'helpers/export_test_data.dart';

void main() {
  const exporter = CsvExporter();

  test('memakai BOM, CRLF, dan pemisah titik koma secara default', () {
    final summary = buildExportTestSummary(loadExportFixtureTransactions());

    final csv = exporter.execute(summary);

    expect(
      csv.startsWith(
        '\uFEFFNo;Tanggal;Jam;Tipe;Kategori;Target Tabungan;Nominal;Catatan;'
        'Saldo Berjalan\r\n',
      ),
      isTrue,
    );
    expect(csv.endsWith('\r\n'), isTrue);
    expect(csv, isNot(contains('\n\n')));
    expect(csv.split('\r\n').length, 45);
    expect(
      csv.replaceAll('\r\n', ''),
      isNot(anyOf(contains('\n'), contains('\r'))),
      reason: 'semua baris harus memakai CRLF',
    );
    expect(csv, isNot(contains(',Tanggal')));
    expect(csv, isNot(contains('.00')));
    expect(csv, isNot(contains('\uFEFFNo,')));
  });

  test('menulis baris transaksi dalam bahasa Indonesia dan urut terlama', () {
    final summary = buildExportTestSummary(loadExportFixtureTransactions());

    final lines = exporter.execute(summary).split('\r\n');

    expect(
      lines[1],
      '1;2026-08-29;09:00;Pemasukan;Gaji Part-time;;5000000;Gaji Agustus;'
      '5000000',
    );
    expect(
      lines[2],
      '2;2026-08-29;12:00;Pengeluaran;Makanan;;100000;Makan siang;4900000',
    );
    expect(
      lines[3],
      '3;2026-08-29;20:00;Tabungan;Alokasi Tabungan;Mouse;100000;'
      'Menabung untuk Mouse;4800000',
    );
    expect(lines.last, isEmpty);
    expect(
      lines.where((line) => line.contains(';Tabungan;')).length,
      25,
    );
    expect(csvHasColumn(lines, index: 0, lastRow: 43), isTrue);
  });

  test('memakai pemisah koma jika diminta pengguna', () {
    final summary = buildExportTestSummary(loadExportFixtureTransactions());

    final csv = exporter.execute(summary, delimiter: CsvDelimiter.comma);

    expect(
      csv.startsWith(
        '\uFEFFNo,Tanggal,Jam,Tipe,Kategori,Target Tabungan,Nominal,Catatan,'
        'Saldo Berjalan\r\n',
      ),
      isTrue,
    );
  });

  test('meng-quote sel yang memuat pemisah, kutip, atau baris baru', () {
    final summary = buildExportTestSummary([
      TransactionEntity(
        id: '1',
        amount: 12500,
        type: TransactionType.expense,
        category: 'Makanan, siang',
        date: DateTime(2026, 8, 28, 12, 30),
        note: 'Nasi "spesial", pedas\nlevel 5',
      ),
    ]);

    final csv = exporter.execute(summary, delimiter: CsvDelimiter.comma);

    expect(csv, contains('"Makanan, siang"'));
    expect(csv, contains('"Nasi ""spesial"", pedas\nlevel 5"'));
  });

  test('meng-quote sel yang memuat titik koma pada pemisah default', () {
    final summary = buildExportTestSummary([
      TransactionEntity(
        id: '1',
        amount: 12500,
        type: TransactionType.expense,
        category: 'Normal',
        date: DateTime(2026, 8, 28, 12, 30),
        note: 'Harga; diskon',
      ),
    ]);

    final csv = exporter.execute(summary);

    expect(csv, contains('"Harga; diskon"'));
  });

  test('mencegah formula injection pada sel teks', () {
    final summary = buildExportTestSummary([
      TransactionEntity(
        id: '1',
        amount: 1000,
        type: TransactionType.expense,
        category: '+Kategori',
        date: DateTime(2026, 8, 28, 12),
        note: '=SUM(A1:A2)',
      ),
      TransactionEntity(
        id: '2',
        amount: 2000,
        type: TransactionType.expense,
        category: '@Inject',
        date: DateTime(2026, 8, 28, 13),
        note: '-1+1',
      ),
      TransactionEntity(
        id: '3',
        amount: 3000,
        type: TransactionType.expense,
        category: 'Normal',
        date: DateTime(2026, 8, 28, 14),
        note: '\tleading tab',
      ),
    ]);

    final csv = exporter.execute(summary);

    expect(csv, contains("'+Kategori"));
    expect(csv, contains("'=SUM(A1:A2)"));
    expect(csv, contains("'@Inject"));
    expect(csv, contains("'-1+1"));
    expect(csv, contains("'\tleading tab"));
  });

  test('mencegah formula injection pada nama target dan catatan alokasi', () {
    final summary = buildExportTestSummary(
      [
        TransactionEntity(
          id: '1',
          amount: 50000,
          type: TransactionType.expense,
          category: FinanceCategories.savingsAllocation,
          date: DateTime(2026, 8, 28, 12),
          note: '@note',
          goalId: 'malicious-goal',
        ),
      ],
      goals: [
        exportTestGoal(
          id: 'malicious-goal',
          title: '+Target',
          targetAmount: 100000,
          currentAmount: 50000,
        ),
      ],
    );

    final csv = exporter.execute(summary);

    expect(csv, contains(";'+Target;"));
    expect(csv, contains(";'@note;"));
  });

  test('saldo berjalan dimulai dari saldo sebelum periode', () {
    final summary = buildExportTestSummary(
      loadExportFixtureTransactions(),
      period: exportTestRange(DateTime(2026, 11, 1), DateTime(2026, 11, 8)),
    );

    final lines = exporter.execute(summary).split('\r\n');

    expect(
      lines[1],
      '1;2026-11-01;08:00;Pengeluaran;Kos & Tagihan;;350000;'
      'Bayar kos November;7288000',
    );
    expect(lines[12], endsWith(';8508000'));
  });

  test('membulatkan nominal ke rupiah penuh', () {
    final summary = buildExportTestSummary([
      TransactionEntity(
        id: '1',
        amount: 12500.75,
        type: TransactionType.income,
        category: 'Gaji',
        date: DateTime(2026, 8, 28, 12),
        note: 'bonus',
      ),
    ]);

    final csv = exporter.execute(summary);

    expect(csv, contains(';12501;'));
    expect(csv, isNot(contains('12500.75')));
  });

  test('menampilkan (Tidak tercatat) untuk alokasi tanpa target', () {
    final summary = buildExportTestSummary(loadExportFixtureTransactions());

    final csv = exporter.execute(summary);

    expect(csv, contains('(Tidak tercatat)'));
  });

  test('mempertahankan emoji dan karakter non-Latin', () {
    final summary = buildExportTestSummary([
      TransactionEntity(
        id: '1',
        amount: 15000,
        type: TransactionType.expense,
        category: 'Makanan',
        date: DateTime(2026, 8, 28, 12),
        note: '🍜 makan siang favorit',
      ),
    ]);

    final csv = exporter.execute(summary);

    expect(csv, contains('🍜 makan siang favorit'));
  });

  test('menghasilkan header walaupun belum ada transaksi', () {
    final summary = buildExportTestSummary(const []);

    final csv = exporter.execute(summary);

    expect(
      csv,
      '\uFEFFNo;Tanggal;Jam;Tipe;Kategori;Target Tabungan;Nominal;Catatan;'
      'Saldo Berjalan\r\n',
    );
  });
}

bool csvHasColumn(
  List<String> lines, {
  required int index,
  required int lastRow,
}) {
  for (var row = 1; row <= lastRow; row++) {
    if (int.tryParse(lines[row].split(';')[index]) != row) {
      return false;
    }
  }
  return true;
}
