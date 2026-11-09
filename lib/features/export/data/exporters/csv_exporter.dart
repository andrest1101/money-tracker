import '../../domain/entities/export_options.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/report_transaction_row.dart';

/// Menulis data mentah satu tabel untuk diolah pengguna.
class CsvExporter {
  const CsvExporter();

  static const List<String> headers = [
    'No',
    'Tanggal',
    'Jam',
    'Tipe',
    'Kategori',
    'Target Tabungan',
    'Nominal',
    'Catatan',
    'Saldo Berjalan',
  ];

  String execute(
    ReportSummary summary, {
    CsvDelimiter delimiter = CsvDelimiter.semicolon,
  }) {
    final separator = delimiter.character;
    final buffer = StringBuffer('\uFEFF');

    buffer
      ..write(headers.join(separator))
      ..write('\r\n');

    for (var index = 0; index < summary.transactions.length; index++) {
      final row = summary.transactions[index];
      final cells = [
        '${index + 1}',
        _formatDate(row.date),
        _formatTime(row.date),
        _typeLabel(row.kind),
        _textCell(row.category, separator),
        _textCell(row.targetName ?? '', separator),
        row.amount.toString(),
        _textCell(row.note, separator),
        row.runningBalance.toString(),
      ];
      buffer
        ..write(cells.join(separator))
        ..write('\r\n');
    }

    return buffer.toString();
  }

  String _typeLabel(ReportTransactionKind kind) {
    switch (kind) {
      case ReportTransactionKind.income:
        return 'Pemasukan';
      case ReportTransactionKind.expense:
        return 'Pengeluaran';
      case ReportTransactionKind.savings:
        return 'Tabungan';
    }
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    return '$year-${_twoDigits(value.month)}-${_twoDigits(value.day)}';
  }

  String _formatTime(DateTime value) {
    return '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _textCell(String value, String separator) {
    final sanitized = _sanitizeFormula(value);
    final escaped = sanitized.replaceAll('"', '""');
    final mustQuote =
        escaped.contains(separator) ||
        escaped.contains('"') ||
        escaped.contains('\n') ||
        escaped.contains('\r');
    return mustQuote ? '"$escaped"' : escaped;
  }

  String _sanitizeFormula(String value) {
    if (value.isEmpty) return value;

    if (_isDangerousCodeUnit(value.codeUnitAt(0))) {
      return "'$value";
    }

    final firstNonWhitespace = value.trimLeft();
    if (firstNonWhitespace.isNotEmpty &&
        _isDangerousCodeUnit(firstNonWhitespace.codeUnitAt(0))) {
      return "'$value";
    }

    return value;
  }

  bool _isDangerousCodeUnit(int codeUnit) {
    switch (codeUnit) {
      case 0x3D: // =
      case 0x2B: // +
      case 0x2D: // -
      case 0x40: // @
      case 0x09: // tab
        return true;
      default:
        return false;
    }
  }
}
