import 'dart:typed_data';

import 'package:excel_community/excel_community.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/category_total.dart';
import '../../domain/entities/goal_progress.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/report_transaction_row.dart';
import 'report_palette.dart';
import 'xlsx_postprocessor.dart';

/// Menulis laporan Excel 5 sheet dari [ReportSummary].
class XlsxExporter {
  const XlsxExporter();

  static const String ringkasanSheet = 'Ringkasan';
  static const String transaksiSheet = 'Transaksi';
  static const String categorySheet = 'Per Kategori';
  static const String monthlySheet = 'Bulanan';
  static const String goalsSheet = 'Target Tabungan';

  Uint8List execute(ReportSummary summary) {
    final excel = Excel.createExcel();
    final ringkasan = excel[ringkasanSheet];
    final transaksi = excel[transaksiSheet];
    final kategori = excel[categorySheet];
    final bulanan = excel[monthlySheet];
    final target = excel[goalsSheet];

    _writeRingkasan(ringkasan, summary);
    _writeTransactions(transaksi, summary);
    _writeCategories(kategori, summary);
    _writeMonthly(bulanan, summary);
    _writeGoals(target, summary);

    excel.delete('Sheet1');
    excel.setDefaultSheet(ringkasanSheet);

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('Gagal membuat file Excel.');
    }

    const postprocessor = XlsxPostprocessor();
    var processed = Uint8List.fromList(bytes);
    processed = postprocessor.freezePanesAndAutofilter(
      processed,
      sheetName: transaksiSheet,
      freezeRows: 1,
      autoFilterRef: 'A1:K${summary.transactionCount + 1}',
    );
    processed = postprocessor.applyRingkasanPageSetup(
      processed,
      sheetName: ringkasanSheet,
    );
    return processed;
  }

  void _writeRingkasan(Sheet sheet, ReportSummary summary) {
    _setColumnWidths(sheet, {
      0: 22,
      1: 16,
      2: 20,
      3: 20,
      4: 20,
      5: 22,
    });

    _mergeText(
      sheet,
      row: 0,
      startColumn: 0,
      endColumn: 5,
      text: summary.appName,
      style: _titleStyle(),
      rowHeight: 32,
    );
    _mergeText(
      sheet,
      row: 1,
      startColumn: 0,
      endColumn: 5,
      text: 'Laporan Keuangan',
      style: _subtitleStyle(),
      rowHeight: 24,
    );
    _mergeText(
      sheet,
      row: 2,
      startColumn: 0,
      endColumn: 5,
      text:
          'Periode: ${_periodText(summary)} '
          '(${_rangeText(summary)})',
      style: _mutedStyle(),
    );
    _mergeText(
      sheet,
      row: 3,
      startColumn: 0,
      endColumn: 5,
      text: 'Diekspor: ${_dateTimeText(summary.generatedAt)}',
      style: _mutedStyle(),
    );
    sheet.setRowHeight(4, 10);

    _mergeText(
      sheet,
      row: 5,
      startColumn: 0,
      endColumn: 5,
      text: 'Angka utama',
      style: _sectionStyle(),
    );

    _kpi(
      sheet,
      row: 6,
      labelColumn: 0,
      labelSpan: 2,
      label: 'Saldo akhir periode',
      valueRow: 7,
      valueColumn: 0,
      valueSpan: 2,
      value: summary.endingBalance,
      valueColor: summary.endingBalance < 0 ? ReportPalette.danger : null,
      isCurrency: true,
    );
    _kpi(
      sheet,
      row: 6,
      labelColumn: 2,
      labelSpan: 2,
      label: 'Total pemasukan',
      valueRow: 7,
      valueColumn: 2,
      valueSpan: 2,
      value: summary.totalIncome,
      valueColor: ReportPalette.income,
      isCurrency: true,
    );
    _kpi(
      sheet,
      row: 6,
      labelColumn: 4,
      labelSpan: 2,
      label: 'Pengeluaran',
      valueRow: 7,
      valueColumn: 4,
      valueSpan: 2,
      value: summary.totalExpense,
      isCurrency: true,
    );
    _kpi(
      sheet,
      row: 8,
      labelColumn: 0,
      labelSpan: 2,
      label: 'Ditabung',
      valueRow: 9,
      valueColumn: 0,
      valueSpan: 2,
      value: summary.totalSavings,
      valueColor: ReportPalette.success,
      isCurrency: true,
    );
    _kpi(
      sheet,
      row: 8,
      labelColumn: 2,
      labelSpan: 2,
      label: 'Selisih bersih',
      valueRow: 9,
      valueColumn: 2,
      valueSpan: 2,
      value: summary.netChange,
      valueColor: summary.netChange < 0 ? ReportPalette.danger : ReportPalette.income,
      isCurrency: true,
    );
    _kpi(
      sheet,
      row: 8,
      labelColumn: 4,
      labelSpan: 2,
      label: 'Tingkat tabungan',
      valueRow: 9,
      valueColumn: 4,
      valueSpan: 2,
      value: summary.savingsRate,
      isCurrency: false,
    );
    sheet.setRowHeight(6, 20);
    sheet.setRowHeight(7, 28);
    sheet.setRowHeight(8, 20);
    sheet.setRowHeight(9, 28);

    _mergeText(
      sheet,
      row: 10,
      startColumn: 0,
      endColumn: 5,
      text:
          'Saldo siklus aktif (dashboard): '
          '${formatRupiah(summary.activeCycleBalance.toDouble())} · '
          '${formatDateShort(summary.activeCycleStart)} – '
          '${formatDateShort(summary.activeCycleEnd)}',
      style: _mutedStyle(),
    );
    sheet.setRowHeight(11, 10);

    _mergeText(
      sheet,
      row: 12,
      startColumn: 0,
      endColumn: 5,
      text: 'Aktivitas',
      style: _sectionStyle(),
    );
    _smallMetric(
      sheet,
      row: 13,
      labelColumn: 0,
      labelSpan: 2,
      label: 'Jumlah transaksi',
      valueRow: 14,
      valueColumn: 0,
      valueSpan: 2,
      value: summary.transactionCount,
    );
    _smallMetric(
      sheet,
      row: 13,
      labelColumn: 2,
      labelSpan: 2,
      label: 'Hari dalam periode',
      valueRow: 14,
      valueColumn: 2,
      valueSpan: 2,
      value: summary.daysInPeriod,
    );
    _smallMetric(
      sheet,
      row: 13,
      labelColumn: 4,
      labelSpan: 2,
      label: 'Hari dengan catatan',
      valueRow: 14,
      valueColumn: 4,
      valueSpan: 2,
      value: summary.daysWithRecords,
    );
    sheet.setRowHeight(13, 20);
    sheet.setRowHeight(14, 24);
    _mergeText(
      sheet,
      row: 15,
      startColumn: 0,
      endColumn: 5,
      text:
          'Rata-rata pengeluaran per hari: '
          '${formatRupiah(summary.averageExpensePerDay)}',
      style: _mutedStyle(),
    );
    sheet.setRowHeight(16, 10);

    _mergeText(
      sheet,
      row: 17,
      startColumn: 0,
      endColumn: 5,
      text: 'Sorotan',
      style: _sectionStyle(),
    );
    _mergeText(
      sheet,
      row: 18,
      startColumn: 0,
      endColumn: 2,
      text: 'Kategori pengeluaran terbesar',
      style: _labelStyle(),
    );
    _mergeText(
      sheet,
      row: 18,
      startColumn: 3,
      endColumn: 5,
      text: 'Transaksi pengeluaran terbesar',
      style: _labelStyle(),
    );
    _mergeText(
      sheet,
      row: 19,
      startColumn: 0,
      endColumn: 2,
      text: summary.largestExpenseCategory?.category ?? 'Belum ada',
      style: _highlightStyle(),
    );
    _mergeText(
      sheet,
      row: 19,
      startColumn: 3,
      endColumn: 5,
      text: summary.largestExpenseTransaction == null
          ? 'Belum ada'
          : formatRupiah(summary.largestExpenseTransaction!.amount.toDouble()),
      style: _highlightStyle(
        color: summary.largestExpenseTransaction == null
            ? null
            : ReportPalette.text,
      ),
    );
    _mergeText(
      sheet,
      row: 20,
      startColumn: 0,
      endColumn: 2,
      text: summary.largestExpenseCategory == null
          ? 'Tidak ada pengeluaran pada periode ini.'
          : '${formatRupiah(summary.largestExpenseCategory!.total.toDouble())} · '
              '${_formatPercent(summary.largestExpenseCategory!.share)} '
              'dari pengeluaran',
      style: _mutedStyle(),
    );
    final largestTransaction = summary.largestExpenseTransaction;
    _mergeText(
      sheet,
      row: 20,
      startColumn: 3,
      endColumn: 5,
      text: largestTransaction == null
          ? 'Tidak ada pengeluaran pada periode ini.'
          : '${largestTransaction.category} · '
              '${formatDateShort(largestTransaction.date)}',
      style: _mutedStyle(),
    );
    sheet.setRowHeight(21, 10);

    _mergeText(
      sheet,
      row: 22,
      startColumn: 0,
      endColumn: 5,
      text: 'Insight',
      style: _sectionStyle(),
    );
    if (summary.insights.isEmpty) {
      _mergeText(
        sheet,
        row: 23,
        startColumn: 0,
        endColumn: 5,
        text: 'Belum ada insight untuk periode ini.',
        style: _mutedStyle(),
      );
      return;
    }

    var row = 23;
    for (final insight in summary.insights) {
      _mergeText(
        sheet,
        row: row,
        startColumn: 0,
        endColumn: 5,
        text: '•  $insight',
        style: _bodyStyle(),
        rowHeight: 22,
      );
      row++;
    }
  }

  void _writeTransactions(Sheet sheet, ReportSummary summary) {
    const headers = [
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
    ];
    _writeTableHeader(sheet, 0, headers);
    sheet.setRowHeight(0, 24);

    for (var index = 0; index < summary.transactions.length; index++) {
      final rowIndex = index + 1;
      final row = summary.transactions[index];

      _setNumber(sheet, rowIndex, 0, index + 1, bold: true);
      _setDate(sheet, rowIndex, 1, row.date);
      _setText(
        sheet,
        rowIndex,
        2,
        _timeText(row.date),
        style: _bodyStyle(alignment: HorizontalAlign.Center),
      );
      _setText(
        sheet,
        rowIndex,
        3,
        _kindLabel(row),
        style: _bodyStyle(),
      );
      _setText(sheet, rowIndex, 4, row.category, style: _bodyStyle());
      _setText(
        sheet,
        rowIndex,
        5,
        row.targetName ?? '',
        style: _bodyStyle(),
      );

      if (row.isIncome) {
        _setCurrency(
          sheet,
          rowIndex,
          6,
          row.amount,
          fontColor: ReportPalette.income,
          bold: true,
        );
      } else if (row.isExpense) {
        _setCurrency(sheet, rowIndex, 7, row.amount);
      } else {
        _setCurrency(
          sheet,
          rowIndex,
          8,
          row.amount,
          fontColor: ReportPalette.success,
        );
      }

      _setText(sheet, rowIndex, 9, row.note, style: _bodyStyle());
      _setCurrency(
        sheet,
        rowIndex,
        10,
        row.runningBalance,
        bold: true,
        fontColor: row.runningBalance < 0 ? ReportPalette.danger : null,
      );
    }

    _setColumnWidths(sheet, {
      0: 6,
      1: 14,
      2: 8,
      3: 16,
      4: 24,
      5: 24,
      6: 18,
      7: 18,
      8: 18,
      9: 48,
      10: 19,
    });
  }

  void _writeCategories(Sheet sheet, ReportSummary summary) {
    _setColumnWidths(sheet, {
      0: 30,
      1: 18,
      2: 19,
      3: 19,
      4: 22,
    });
    _mergeText(
      sheet,
      row: 0,
      startColumn: 0,
      endColumn: 4,
      text: 'Per Kategori',
      style: _titleStyle(),
      rowHeight: 30,
    );
    _mergeText(
      sheet,
      row: 1,
      startColumn: 0,
      endColumn: 4,
      text: 'Periode: ${_periodText(summary)}',
      style: _mutedStyle(),
    );

    _mergeText(
      sheet,
      row: 3,
      startColumn: 0,
      endColumn: 4,
      text: 'Pengeluaran',
      style: _sectionStyle(),
    );
    _writeTableHeader(sheet, 4, [
      'Kategori',
      'Jumlah transaksi',
      'Total',
      '% dari pengeluaran',
      'Rata-rata/transaksi',
    ]);
    var row = 5;
    if (summary.expenseCategories.isEmpty) {
      _mergeText(
        sheet,
        row: row,
        startColumn: 0,
        endColumn: 4,
        text: 'Belum ada data pengeluaran.',
        style: _mutedStyle(),
      );
      row++;
    } else {
      for (final category in summary.expenseCategories) {
        _writeCategoryRow(
          sheet,
          row: row,
          category: category,
        );
        row++;
      }
      _writeCategoryTotalRow(
        sheet,
        row: row,
        categories: summary.expenseCategories,
        base: summary.totalExpense,
      );
      row++;
    }

    _mergeText(
      sheet,
      row: row,
      startColumn: 0,
      endColumn: 4,
      text:
          'Ditabung (dipisah dari pengeluaran): '
          '${formatRupiah(summary.totalSavings.toDouble())}',
      style: _highlightStyle(color: ReportPalette.success),
    );
    row += 2;

    _mergeText(
      sheet,
      row: row,
      startColumn: 0,
      endColumn: 4,
      text: 'Pemasukan',
      style: _sectionStyle(),
    );
    _writeTableHeader(sheet, row + 1, [
      'Kategori',
      'Jumlah transaksi',
      'Total',
      '% dari pemasukan',
      'Rata-rata/transaksi',
    ]);
    var incomeRow = row + 2;
    if (summary.incomeCategories.isEmpty) {
      _mergeText(
        sheet,
        row: incomeRow,
        startColumn: 0,
        endColumn: 4,
        text: 'Belum ada data pemasukan.',
        style: _mutedStyle(),
      );
      return;
    }
    for (final category in summary.incomeCategories) {
      _writeCategoryRow(
        sheet,
        row: incomeRow,
        category: category,
      );
      incomeRow++;
    }
    _writeCategoryTotalRow(
      sheet,
      row: incomeRow,
      categories: summary.incomeCategories,
      base: summary.totalIncome,
    );
  }

  void _writeMonthly(Sheet sheet, ReportSummary summary) {
    _setColumnWidths(sheet, {
      0: 16,
      1: 19,
      2: 19,
      3: 19,
      4: 19,
      5: 20,
    });
    _mergeText(
      sheet,
      row: 0,
      startColumn: 0,
      endColumn: 5,
      text: 'Bulanan',
      style: _titleStyle(),
      rowHeight: 30,
    );
    _mergeText(
      sheet,
      row: 1,
      startColumn: 0,
      endColumn: 5,
      text: 'Periode: ${_periodText(summary)}',
      style: _mutedStyle(),
    );
    _writeTableHeader(sheet, 3, [
      'Bulan',
      'Pemasukan',
      'Pengeluaran',
      'Ditabung',
      'Selisih',
      'Tingkat tabungan',
    ]);

    var totalIncome = 0;
    var totalExpense = 0;
    var totalSavings = 0;
    var row = 4;
    for (final month in summary.months) {
      _setText(
        sheet,
        row,
        0,
        _monthLabel(month.year, month.month),
        style: _bodyStyle(),
      );
      _setCurrency(sheet, row, 1, month.income, fontColor: ReportPalette.income);
      _setCurrency(sheet, row, 2, month.expense);
      _setCurrency(
        sheet,
        row,
        3,
        month.savings,
        fontColor: ReportPalette.success,
      );
      _setCurrency(
        sheet,
        row,
        4,
        month.net,
        fontColor: month.net < 0 ? ReportPalette.danger : null,
      );
      _setPercent(sheet, row, 5, month.savingsRate);
      totalIncome += month.income;
      totalExpense += month.expense;
      totalSavings += month.savings;
      row++;
    }

    _writeMonthlyTotalRow(
      sheet,
      row: summary.months.length + 4,
      income: totalIncome,
      expense: totalExpense,
      savings: totalSavings,
    );
  }

  void _writeGoals(Sheet sheet, ReportSummary summary) {
    _setColumnWidths(sheet, {
      0: 26,
      1: 20,
      2: 20,
      3: 12,
      4: 16,
      5: 12,
      6: 14,
      7: 21,
    });
    _mergeText(
      sheet,
      row: 0,
      startColumn: 0,
      endColumn: 7,
      text: 'Target Tabungan',
      style: _titleStyle(),
      rowHeight: 30,
    );
    _mergeText(
      sheet,
      row: 1,
      startColumn: 0,
      endColumn: 7,
      text: 'Periode: ${_periodText(summary)}',
      style: _mutedStyle(),
    );
    _writeTableHeader(sheet, 3, [
      'Target',
      'Terkumpul (saat ini)',
      'Target nominal',
      'Progres',
      'Deadline',
      'Sisa hari',
      'Status',
      'Alokasi di periode',
    ]);

    var row = 4;
    if (summary.goals.isEmpty) {
      _mergeText(
        sheet,
        row: row,
        startColumn: 0,
        endColumn: 7,
        text: 'Belum ada target tabungan.',
        style: _mutedStyle(),
      );
      row++;
    } else {
      for (final goal in summary.goals) {
        _setText(sheet, row, 0, goal.title, style: _bodyStyle());
        _setCurrency(sheet, row, 1, goal.currentAmount);
        _setCurrency(sheet, row, 2, goal.targetAmount);
        _setPercent(sheet, row, 3, goal.progress);
        _setDate(sheet, row, 4, goal.deadline);
        _setNumber(sheet, row, 5, goal.daysRemaining);
        _setText(
          sheet,
          row,
          6,
          _goalStatusLabel(goal.status),
          style: _bodyStyle(
            fontColor: switch (goal.status) {
              GoalStatus.active => ReportPalette.brand,
              GoalStatus.completed => ReportPalette.success,
              GoalStatus.archived => ReportPalette.muted,
            },
          ),
        );
        _setCurrency(
          sheet,
          row,
          7,
          goal.allocatedInPeriod,
          bold: goal.allocatedInPeriod > 0,
        );
        row++;
      }
    }

    if (summary.unmatchedAllocationCount > 0) {
      _mergeText(
        sheet,
        row: row + 1,
        startColumn: 0,
        endColumn: 7,
        text:
            'Alokasi tanpa nama target: '
            '${summary.unmatchedAllocationCount} transaksi · '
            '${formatRupiah(summary.unmatchedAllocationAmount.toDouble())}',
        style: _mutedStyle(),
      );
    }
  }

  void _writeTableHeader(
    Sheet sheet,
    int row,
    List<String> headers,
  ) {
    for (var column = 0; column < headers.length; column++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column),
      );
      cell.value = TextCellValue(headers[column]);
      cell.cellStyle = _headerStyle(
        alignment: column >= headers.length - 1
            ? HorizontalAlign.Right
            : HorizontalAlign.Left,
      );
    }
  }

  void _writeCategoryRow(
    Sheet sheet, {
    required int row,
    required CategoryTotal category,
  }) {
    _setText(sheet, row, 0, category.category, style: _bodyStyle());
    _setNumber(sheet, row, 1, category.transactionCount);
    _setCurrency(sheet, row, 2, category.total);
    _setPercent(sheet, row, 3, category.share);
    _setCurrency(sheet, row, 4, category.averagePerTransaction.round());
    sheet.setRowHeight(row, 22);
  }

  void _writeCategoryTotalRow(
    Sheet sheet, {
    required int row,
    required List<CategoryTotal> categories,
    required int base,
  }) {
    final total = categories.fold<int>(0, (sum, item) => sum + item.total);
    final count = categories.fold<int>(
      0,
      (sum, item) => sum + item.transactionCount,
    );
    _setText(sheet, row, 0, 'Total', style: _totalStyle());
    _setNumber(sheet, row, 1, count, style: _totalStyle(align: HorizontalAlign.Right));
    _setCurrency(sheet, row, 2, total, bold: true);
    _setPercent(sheet, row, 3, base <= 0 ? 0 : total / base, bold: true);
    _setCurrency(
      sheet,
      row,
      4,
      count == 0 ? 0 : (total / count).round(),
      bold: true,
    );
    for (var column = 0; column <= 4; column++) {
      sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column),
      ).cellStyle = sheet
          .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column))
          .cellStyle
          ?.copyWith(topBorderVal: _topBorder());
    }
  }

  void _writeMonthlyTotalRow(
    Sheet sheet, {
    required int row,
    required int income,
    required int expense,
    required int savings,
  }) {
    _setText(sheet, row, 0, 'Total', style: _totalStyle());
    _setCurrency(sheet, row, 1, income, bold: true);
    _setCurrency(sheet, row, 2, expense, bold: true);
    _setCurrency(
      sheet,
      row,
      3,
      savings,
      bold: true,
      fontColor: ReportPalette.success,
    );
    _setCurrency(sheet, row, 4, income - expense - savings, bold: true);
    _setPercent(sheet, row, 5, income <= 0 ? 0 : savings / income, bold: true);
    for (var column = 0; column <= 5; column++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column),
      );
      cell.cellStyle = cell.cellStyle?.copyWith(topBorderVal: _topBorder());
    }
  }

  void _kpi(
    Sheet sheet, {
    required int row,
    required int labelColumn,
    required int labelSpan,
    required String label,
    required int valueRow,
    required int valueColumn,
    required int valueSpan,
    required num value,
    required bool isCurrency,
    ExcelColor? valueColor,
  }) {
    _mergeText(
      sheet,
      row: row,
      startColumn: labelColumn,
      endColumn: labelColumn + labelSpan - 1,
      text: label,
      style: _labelStyle(),
    );
    if (isCurrency) {
      _mergeCurrency(
        sheet,
        row: valueRow,
        startColumn: valueColumn,
        endColumn: valueColumn + valueSpan - 1,
        value: value.toInt(),
        fontColor: valueColor,
      );
      return;
    }
    _mergePercent(
      sheet,
      row: valueRow,
      startColumn: valueColumn,
      endColumn: valueColumn + valueSpan - 1,
      value: value.toDouble(),
      fontColor: valueColor,
    );
  }

  void _smallMetric(
    Sheet sheet, {
    required int row,
    required int labelColumn,
    required int labelSpan,
    required String label,
    required int valueRow,
    required int valueColumn,
    required int valueSpan,
    required int value,
  }) {
    _mergeText(
      sheet,
      row: row,
      startColumn: labelColumn,
      endColumn: labelColumn + labelSpan - 1,
      text: label,
      style: _labelStyle(),
    );
    _mergeText(
      sheet,
      row: valueRow,
      startColumn: valueColumn,
      endColumn: valueColumn + valueSpan - 1,
      text: value.toString(),
      style: _metricValueStyle(),
    );
  }

  void _mergeText(
    Sheet sheet, {
    required int row,
    required int startColumn,
    required int endColumn,
    required String text,
    required CellStyle style,
    int? rowHeight,
  }) {
    if (startColumn != endColumn) {
      for (var column = startColumn; column <= endColumn; column++) {
        sheet
            .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column))
            .cellStyle = style;
      }
      sheet.merge(
        CellIndex.indexByColumnRow(rowIndex: row, columnIndex: startColumn),
        CellIndex.indexByColumnRow(rowIndex: row, columnIndex: endColumn),
      );
    }
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: startColumn),
    );
    cell
      ..value = TextCellValue(text)
      ..cellStyle = style;
    if (rowHeight != null) sheet.setRowHeight(row, rowHeight.toDouble());
  }

  void _mergeCurrency(
    Sheet sheet, {
    required int row,
    required int startColumn,
    required int endColumn,
    required int value,
    ExcelColor? fontColor,
  }) {
    final style = _currencyStyle(
      bold: true,
      fontColor: fontColor,
      fontSize: 15,
    );
    for (var column = startColumn; column <= endColumn; column++) {
      sheet
          .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column))
          .cellStyle = style;
    }
    sheet.merge(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: startColumn),
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: endColumn),
    );
    sheet.cell(
          CellIndex.indexByColumnRow(rowIndex: row, columnIndex: startColumn),
        )
      ..value = IntCellValue(value)
      ..cellStyle = style;
  }

  void _mergePercent(
    Sheet sheet, {
    required int row,
    required int startColumn,
    required int endColumn,
    required double value,
    ExcelColor? fontColor,
  }) {
    final style = _percentStyle(
      bold: true,
      fontColor: fontColor,
      fontSize: 15,
    );
    for (var column = startColumn; column <= endColumn; column++) {
      sheet
          .cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column))
          .cellStyle = style;
    }
    sheet.merge(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: startColumn),
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: endColumn),
    );
    sheet.cell(
          CellIndex.indexByColumnRow(rowIndex: row, columnIndex: startColumn),
        )
      ..value = DoubleCellValue(value)
      ..cellStyle = style;
  }

  void _setText(
    Sheet sheet,
    int row,
    int column,
    String text, {
    required CellStyle style,
  }) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column),
    );
    cell
      ..value = TextCellValue(text)
      ..cellStyle = style;
  }

  void _setNumber(
    Sheet sheet,
    int row,
    int column,
    num value, {
    bool bold = false,
    CellStyle? style,
  }) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column),
    );
    cell
      ..value = value is int ? IntCellValue(value) : DoubleCellValue(value.toDouble())
      ..cellStyle = style ??
          CellStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            bold: bold,
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
            fontColorHex: ReportPalette.text,
          );
  }

  void _setCurrency(
    Sheet sheet,
    int row,
    int column,
    num value, {
    bool bold = false,
    ExcelColor? fontColor,
    int? fontSize,
  }) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column),
    );
    cell
      ..value = IntCellValue(value.round())
      ..cellStyle = _currencyStyle(
        bold: bold,
        fontColor: fontColor,
        fontSize: fontSize ?? 11,
      );
  }

  void _setPercent(
    Sheet sheet,
    int row,
    int column,
    double value, {
    bool bold = false,
    ExcelColor? fontColor,
  }) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column),
    );
    cell
      ..value = DoubleCellValue(value)
      ..cellStyle = _percentStyle(bold: bold, fontColor: fontColor);
  }

  void _setDate(Sheet sheet, int row, int column, DateTime value) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: column),
    );
    cell
      ..value = DateCellValue.fromDateTime(value)
      ..cellStyle = CellStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        verticalAlign: VerticalAlign.Center,
        fontColorHex: ReportPalette.text,
        numberFormat: _dateFormat,
      );
  }

  void _setColumnWidths(Sheet sheet, Map<int, double> widths) {
    for (final entry in widths.entries) {
      sheet.setColumnWidth(entry.key, entry.value);
    }
  }

  CellStyle _titleStyle() => CellStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    bold: true,
    fontColorHex: ReportPalette.brand,
    verticalAlign: VerticalAlign.Center,
  );

  CellStyle _subtitleStyle() => CellStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    bold: true,
    fontColorHex: ReportPalette.text,
    verticalAlign: VerticalAlign.Center,
  );

  CellStyle _sectionStyle() => CellStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    bold: true,
    fontColorHex: ReportPalette.brand,
    verticalAlign: VerticalAlign.Center,
  );

  CellStyle _labelStyle() => CellStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontColorHex: ReportPalette.muted,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
  );

  CellStyle _mutedStyle() => CellStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontColorHex: ReportPalette.muted,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
  );

  CellStyle _bodyStyle({
    HorizontalAlign alignment = HorizontalAlign.Left,
    ExcelColor? fontColor,
    bool bold = false,
  }) {
    return CellStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      bold: bold,
      fontColorHex: fontColor ?? ReportPalette.text,
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: alignment,
      textWrapping: TextWrapping.WrapText,
    );
  }

  CellStyle _highlightStyle({ExcelColor? color}) => CellStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    bold: true,
    fontColorHex: color ?? ReportPalette.brand,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
  );

  CellStyle _metricValueStyle() => CellStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    bold: true,
    fontColorHex: ReportPalette.text,
    verticalAlign: VerticalAlign.Center,
  );

  CellStyle _headerStyle({HorizontalAlign alignment = HorizontalAlign.Left}) {
    return CellStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      bold: true,
      fontColorHex: ReportPalette.onBrand,
      backgroundColorHex: ReportPalette.brand,
      horizontalAlign: alignment,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
    );
  }

  CellStyle _currencyStyle({
    bool bold = false,
    ExcelColor? fontColor,
    int fontSize = 11,
  }) {
    return CellStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      bold: bold,
      fontColorHex: fontColor ?? ReportPalette.text,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: _currencyFormat,
    );
  }

  CellStyle _percentStyle({
    bool bold = false,
    ExcelColor? fontColor,
    int fontSize = 11,
  }) {
    return CellStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      bold: bold,
      fontColorHex: fontColor ?? ReportPalette.text,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: _percentFormat,
    );
  }

  CellStyle _totalStyle({HorizontalAlign align = HorizontalAlign.Left}) {
    return CellStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      bold: true,
      fontColorHex: ReportPalette.text,
      horizontalAlign: align,
      verticalAlign: VerticalAlign.Center,
      topBorder: _topBorder(),
    );
  }

  Border _topBorder() {
    return Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ReportPalette.outline,
    );
  }

  String _periodText(ReportSummary summary) {
    return summary.periodLabel;
  }

  String _rangeText(ReportSummary summary) {
    final start = formatDateShort(summary.rangeStart);
    final end = formatDateShort(summary.rangeEnd);
    if (start == end) return start;
    return '$start – $end';
  }

  String _dateTimeText(DateTime value) {
    return '${formatDateShort(value)} ${_timeText(value)}';
  }

  String _timeText(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _kindLabel(ReportTransactionRow row) {
    return switch (row.kind) {
      ReportTransactionKind.income => 'Pemasukan',
      ReportTransactionKind.expense => 'Pengeluaran',
      ReportTransactionKind.savings => 'Tabungan',
    };
  }

  String _goalStatusLabel(GoalStatus status) {
    return switch (status) {
      GoalStatus.active => 'Aktif',
      GoalStatus.completed => 'Selesai',
      GoalStatus.archived => 'Diarsipkan',
    };
  }

  String _monthLabel(int year, int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${names[month - 1]} $year';
  }

  String _formatPercent(double fraction) {
    return '${(fraction * 100).toStringAsFixed(1).replaceAll('.', ',')}%';
  }

  static final String _fontFamily = getFontFamily(FontFamily.Calibri);
  static final NumFormat _currencyFormat = NumFormat.custom(
    formatCode: '"Rp" #,##0',
  );
  static final NumFormat _percentFormat = NumFormat.custom(
    formatCode: '0.0%',
  );
  static final NumFormat _dateFormat = NumFormat.custom(
    formatCode: 'dd mmm yyyy',
  );
}
