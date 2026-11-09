import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/export_options.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/export_repository.dart';
import '../exporters/csv_exporter.dart';
import '../exporters/xlsx_exporter.dart';
import '../services/report_file_namer.dart';
import '../services/report_share_service.dart';

class ExportRepositoryException implements Exception {
  const ExportRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    return 'ExportRepositoryException: $message'
        '${cause == null ? '' : ' | cause: $cause'}';
  }
}

class ExportRepositoryImpl implements ExportRepository {
  ExportRepositoryImpl({
    CsvExporter? csvExporter,
    XlsxExporter? xlsxExporter,
    ReportShareService? shareService,
  }) : _csvExporter = csvExporter ?? const CsvExporter(),
       _xlsxExporter = xlsxExporter ?? const XlsxExporter(),
       _shareService = shareService ?? const ReportShareService();

  final CsvExporter _csvExporter;
  final XlsxExporter _xlsxExporter;
  final ReportShareService _shareService;

  @override
  Future<void> shareReport({
    required ReportSummary summary,
    required ExportOptions options,
  }) async {
    if (!summary.hasTransactions) {
      throw const ExportRepositoryException(
        'Belum ada transaksi untuk diekspor.',
      );
    }

    final payload = _buildPayload(summary, options);
    try {
      await _shareService.shareFile(
        bytes: payload.bytes,
        name: payload.name,
        mimeType: payload.mimeType,
        subject: payload.subject,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ExportRepositoryException(
          'File tidak bisa dibagikan. Coba lagi.',
          error,
        ),
        stackTrace,
      );
    }
  }

  _ExportPayload _buildPayload(
    ReportSummary summary,
    ExportOptions options,
  ) {
    try {
      return switch (options.format) {
        ExportFormat.csv => _buildCsv(summary, options),
        ExportFormat.xlsx => _buildXlsx(summary),
      };
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        ExportRepositoryException(
          'Gagal menyiapkan file ekspor. Coba lagi.',
          error,
        ),
        stackTrace,
      );
    }
  }

  _ExportPayload _buildCsv(
    ReportSummary summary,
    ExportOptions options,
  ) {
    final csv = _csvExporter.execute(
      summary,
      delimiter: options.delimiter,
    );
    return _ExportPayload(
      bytes: Uint8List.fromList(utf8.encode(csv)),
      name: reportFileName(summary, ExportFormat.csv),
      mimeType: reportMimeType(ExportFormat.csv),
      subject: reportSubject(summary, ExportFormat.csv),
    );
  }

  _ExportPayload _buildXlsx(ReportSummary summary) {
    return _ExportPayload(
      bytes: _xlsxExporter.execute(summary),
      name: reportFileName(summary, ExportFormat.xlsx),
      mimeType: reportMimeType(ExportFormat.xlsx),
      subject: reportSubject(summary, ExportFormat.xlsx),
    );
  }
}

class _ExportPayload {
  const _ExportPayload({
    required this.bytes,
    required this.name,
    required this.mimeType,
    required this.subject,
  });

  final Uint8List bytes;
  final String name;
  final String mimeType;
  final String subject;
}
