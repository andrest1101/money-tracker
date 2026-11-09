import '../../domain/entities/export_options.dart';
import '../../domain/entities/report_summary.dart';

/// Nama file ekspor mengikuti rentang tanggal data yang benar-benar masuk.
String reportFileName(ReportSummary summary, ExportFormat format) {
  final kind = format == ExportFormat.xlsx ? 'Laporan' : 'Transaksi';
  final extension = format == ExportFormat.xlsx ? 'xlsx' : 'csv';
  final app = _sanitizeFileSegment(summary.appName);
  final start = _date(summary.rangeStart);
  final end = _date(summary.rangeEnd);
  return '${app}_${kind}_${start}_sd_$end.$extension';
}

String reportMimeType(ExportFormat format) {
  return switch (format) {
    ExportFormat.csv => 'text/csv',
    ExportFormat.xlsx =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  };
}

String reportSubject(ReportSummary summary, ExportFormat format) {
  return switch (format) {
    ExportFormat.csv => 'Ekspor transaksi ${summary.appName}',
    ExportFormat.xlsx => 'Laporan keuangan ${summary.appName}',
  };
}

String _sanitizeFileSegment(String value) {
  final sanitized = value
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return sanitized.isEmpty ? 'Savu' : sanitized;
}

String _date(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
