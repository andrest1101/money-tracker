import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel_community/excel_community.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savu/features/export/data/exporters/xlsx_exporter.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';

import 'helpers/export_test_data.dart';

void main() {
  const exporter = XlsxExporter();

  test('membuat lima sheet dengan urutan yang benar dan tanpa Sheet1', () {
    final bytes = exporter.execute(buildExportTestSummary(
      loadExportFixtureTransactions(),
    ));

    final excel = Excel.decodeBytes(bytes);

    expect(
      excel.tables.keys.toList(),
      [
        XlsxExporter.ringkasanSheet,
        XlsxExporter.transaksiSheet,
        XlsxExporter.categorySheet,
        XlsxExporter.monthlySheet,
        XlsxExporter.goalsSheet,
      ],
    );
    expect(excel.tables.keys, isNot(contains('Sheet1')));
  });

  test('menulis header Transaksi dan baris data dengan nilai numerik', () {
    final bytes = exporter.execute(buildExportTestSummary(
      loadExportFixtureTransactions(),
    ));

    final sheet = Excel.decodeBytes(bytes).tables[XlsxExporter.transaksiSheet]!;
    final rows = sheet.rows;

    expect(
      rows[0].map(_text).toList(),
      [
        'No',
        'Tanggal',
        'Jam',
        'Tipe',
        'Kategori',
        'Target Tabungan',
        'Pemasukan',
        'Pengeluaran',
        'Ditabung',
        'Catatan',
        'Saldo Berjalan',
      ],
    );
    expect(_number(rows[1][0]), 1);
    expect(_date(rows[1][1]), DateTime(2026, 8, 29));
    expect(_text(rows[1][2]), '09:00');
    expect(_text(rows[1][3]), 'Pemasukan');
    expect(_number(rows[1][6]), 5000000);
    expect(_number(rows[1][7]), isNull);
    expect(_number(rows[1][8]), isNull);
    expect(_number(rows[1][10]), 5000000);

    expect(_text(rows[2][3]), 'Pengeluaran');
    expect(_number(rows[2][6]), isNull);
    expect(_number(rows[2][7]), 100000);
    expect(_number(rows[2][10]), 4900000);

    expect(_text(rows[3][3]), 'Tabungan');
    expect(_text(rows[3][5]), 'Mouse');
    expect(_number(rows[3][8]), 100000);
    expect(_number(rows[3][10]), 4800000);

    expect(_number(rows[0][6]), isNull);
    expect(_numberFormat(rows[1][6]), contains('Rp'));
    expect(_numberFormat(rows[1][10]), contains('Rp'));
    expect(_numberFormat(rows[1][1]), 'dd mmm yyyy');
  });

  test('menulis Ringkasan dengan angka utama dan saldo siklus aktif', () {
    final bytes = exporter.execute(buildExportTestSummary(
      loadExportFixtureTransactions(),
    ));

    final sheet = Excel.decodeBytes(bytes).tables[XlsxExporter.ringkasanSheet]!;

    expect(_text(sheet.rows[0][0]), 'Savu');
    expect(_text(sheet.rows[1][0]), 'Laporan Keuangan');
    expect(_text(sheet.rows[6][0]), 'Saldo akhir periode');
    expect(_number(sheet.rows[7][0]), 8508000);
    expect(_text(sheet.rows[6][2]), 'Total pemasukan');
    expect(_number(sheet.rows[7][2]), 12725000);
    expect(_text(sheet.rows[6][4]), 'Pengeluaran');
    expect(_number(sheet.rows[7][4]), 2002000);
    expect(_text(sheet.rows[8][0]), 'Ditabung');
    expect(_number(sheet.rows[9][0]), 2215000);
    expect(_text(sheet.rows[8][2]), 'Selisih bersih');
    expect(_number(sheet.rows[9][2]), 8508000);
    expect(_numberFormat(sheet.rows[9][4]), '0.0%');
    expect(
      _containsText(sheet, 'Saldo siklus aktif (dashboard): Rp 870.000'),
      isTrue,
    );
  });

  test('menulis Per Kategori dengan Belanja sebagai kategori terbesar', () {
    final bytes = exporter.execute(buildExportTestSummary(
      loadExportFixtureTransactions(),
    ));

    final sheet = Excel.decodeBytes(bytes).tables[XlsxExporter.categorySheet]!;

    expect(_containsText(sheet, 'Pengeluaran'), isTrue);
    expect(_containsText(sheet, 'Belanja'), isTrue);
    expect(_containsText(sheet, 'Kos & Tagihan'), isTrue);
    expect(_containsText(sheet, 'Ditabung (dipisah dari pengeluaran)'), isTrue);
    expect(_containsText(sheet, 'Pemasukan'), isTrue);

    final belanjaRow = _findRowByFirstCell(sheet, 'Belanja');
    expect(belanjaRow, isNotNull);
    expect(_number(belanjaRow![1]), 5);
    expect(_number(belanjaRow[2]), 730000);
    expect(_numberFormat(belanjaRow[2]), contains('Rp'));
    expect(_numberFormat(belanjaRow[3]), '0.0%');

    final totalRow = _findRowByFirstCell(sheet, 'Total');
    expect(totalRow, isNotNull);
    expect(_number(totalRow![2]), 2002000);
  });

  test('menulis Bulanan termasuk bulan Oktober yang kosong dan total', () {
    final bytes = exporter.execute(buildExportTestSummary(
      loadExportFixtureTransactions(),
    ));

    final sheet = Excel.decodeBytes(bytes).tables[XlsxExporter.monthlySheet]!;

    expect(_containsText(sheet, 'Agu 2026'), isTrue);
    expect(_containsText(sheet, 'Okt 2026'), isTrue);
    expect(_containsText(sheet, 'Nov 2026'), isTrue);

    final october = _findRowByFirstCell(sheet, 'Okt 2026');
    expect(october, isNotNull);
    expect(_number(october![1]), 0);
    expect(_number(october[2]), 0);
    expect(_number(october[3]), 0);
    expect(_number(october[4]), 0);

    final total = _findRowByFirstCell(sheet, 'Total');
    expect(total, isNotNull);
    expect(_number(total![1]), 12725000);
    expect(_number(total[2]), 2002000);
    expect(_number(total[3]), 2215000);
    expect(_number(total[4]), 8508000);
  });

  test('menulis Target Tabungan beserta alokasi tanpa target', () {
    final bytes = exporter.execute(buildExportTestSummary(
      loadExportFixtureTransactions(),
    ));

    final sheet = Excel.decodeBytes(bytes).tables[XlsxExporter.goalsSheet]!;

    final mouse = _findRowByFirstCell(sheet, 'Mouse');
    expect(mouse, isNotNull);
    expect(_number(mouse![1]), 1000000);
    expect(_number(mouse[2]), 1500000);
    expect(_numberFormat(mouse[3]), '0.0%');
    expect(_text(mouse[6]), 'Aktif');
    expect(_number(mouse[7]), 1000000);

    expect(_containsText(sheet, 'Alokasi tanpa nama target: 3 transaksi'), isTrue);
    expect(_containsText(sheet, 'Rp 240.000'), isTrue);
  });

  test('menulis sheet sebagai teks agar formula injection tidak dieksekusi', () {
    final summary = buildExportTestSummary([
      TransactionEntity(
        id: '1',
        amount: 1000,
        type: TransactionType.expense,
        category: '=HYPERLINK("https://example.com")',
        date: DateTime(2026, 8, 28, 12),
        note: '=cmd()',
      ),
    ]);

    final bytes = exporter.execute(summary);
    final sheet = Excel.decodeBytes(bytes).tables[XlsxExporter.transaksiSheet]!;

    expect(sheet.rows[1][4]!.value, isA<TextCellValue>());
    expect(sheet.rows[1][9]!.value, isA<TextCellValue>());
    expect(sheet.rows[1][4]!.value, isNot(isA<FormulaCellValue>()));
    expect(sheet.rows[1][9]!.value, isNot(isA<FormulaCellValue>()));
  });

  test('tetap membentuk lima sheet saat belum ada transaksi', () {
    final bytes = exporter.execute(buildExportTestSummary(const []));

    final excel = Excel.decodeBytes(bytes);

    expect(excel.tables.keys.length, 5);
    expect(excel.tables[XlsxExporter.transaksiSheet]!.rows.length, 1);
    expect(
      excel.tables[XlsxExporter.transaksiSheet]!.rows[0].map(_text),
      contains('Saldo Berjalan'),
    );
  });

  test('menetapkan freeze pane, filter otomatis, dan print setup di XML', () {
    final bytes = exporter.execute(buildExportTestSummary(
      loadExportFixtureTransactions(),
    ));

    final archive = ZipDecoder().decodeBytes(bytes);
    final xml = archive.files
        .where((file) => file.name.endsWith('.xml'))
        .map((file) => utf8.decode(file.content))
        .join('\n');

    expect(xml, contains('<pane ySplit="1"'));
    expect(xml, contains('state="frozen"'));
    expect(xml, contains('<autoFilter ref="A1:K44"/>'));
    expect(xml, contains('paperSize="9" orientation="portrait"'));
    expect(xml, contains('fitToPage="1"'));
  });
}

String? _text(Data? cell) {
  final value = cell?.value;
  if (value == null) return null;
  if (value is TextCellValue) return value.value.text;
  if (value is FormulaCellValue) return value.formula;
  return value.toString();
}

num? _number(Data? cell) {
  final value = cell?.value;
  if (value is IntCellValue) return value.value;
  if (value is DoubleCellValue) return value.value;
  return null;
}

DateTime? _date(Data? cell) {
  final value = cell?.value;
  if (value is DateCellValue) {
    return DateTime(value.year, value.month, value.day);
  }
  return null;
}

String? _numberFormat(Data? cell) {
  return cell?.cellStyle?.numberFormat.formatCode;
}

bool _containsText(Sheet sheet, String needle) {
  for (final row in sheet.rows) {
    for (final cell in row) {
      final text = _text(cell);
      if (text != null && text.contains(needle)) return true;
    }
  }
  return false;
}

List<Data?>? _findRowByFirstCell(Sheet sheet, String expected) {
  for (final row in sheet.rows) {
    if (_text(row.first) == expected) return row;
  }
  return null;
}
