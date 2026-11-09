import '../entities/export_options.dart';
import '../entities/report_summary.dart';

/// Pintu keluar untuk membagikan laporan ke proses sistem (share sheet).
abstract interface class ExportRepository {
  Future<void> shareReport({
    required ReportSummary summary,
    required ExportOptions options,
  });
}
