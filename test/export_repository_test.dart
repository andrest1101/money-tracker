import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:savu/features/export/data/repositories/export_repository_impl.dart';
import 'package:savu/features/export/data/services/report_share_service.dart';
import 'package:savu/features/export/domain/entities/export_options.dart';

import 'helpers/export_test_data.dart';

void main() {
  late _FakeShareService shareService;
  late ExportRepositoryImpl repository;

  setUp(() {
    shareService = _FakeShareService();
    repository = ExportRepositoryImpl(shareService: shareService);
  });

  test('membagikan CSV dengan nama file, MIME, dan isi yang benar', () async {
    final summary = buildExportTestSummary(loadExportFixtureTransactions());

    await repository.shareReport(
      summary: summary,
      options: const ExportOptions(format: ExportFormat.csv),
    );

    expect(shareService.shareCount, 1);
    expect(
      shareService.name,
      'Savu_Transaksi_2026-08-29_sd_2026-11-08.csv',
    );
    expect(shareService.mimeType, 'text/csv');
    expect(shareService.subject, 'Ekspor transaksi Savu');
    expect(shareService.bytes!.take(3).toList(), [0xEF, 0xBB, 0xBF]);
    final csv = utf8.decode(shareService.bytes!);
    expect(csv.startsWith('No;Tanggal;'), isTrue);
    expect(csv, contains('1;2026-08-29;09:00;Pemasukan'));
  });

  test('membagikan CSV dengan pemisah koma jika dipilih', () async {
    final summary = buildExportTestSummary(loadExportFixtureTransactions());

    await repository.shareReport(
      summary: summary,
      options: const ExportOptions(
        format: ExportFormat.csv,
        delimiter: CsvDelimiter.comma,
      ),
    );

    final csv = utf8.decode(shareService.bytes!);
    expect(shareService.bytes!.take(3).toList(), [0xEF, 0xBB, 0xBF]);
    expect(csv.startsWith('No,Tanggal,'), isTrue);
  });

  test('membagikan laporan XLSX dengan nama file dan MIME yang benar', () async {
    final summary = buildExportTestSummary(loadExportFixtureTransactions());

    await repository.shareReport(
      summary: summary,
      options: const ExportOptions(format: ExportFormat.xlsx),
    );

    expect(shareService.shareCount, 1);
    expect(
      shareService.name,
      'Savu_Laporan_2026-08-29_sd_2026-11-08.xlsx',
    );
    expect(
      shareService.mimeType,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    expect(shareService.subject, 'Laporan keuangan Savu');
    expect(shareService.bytes, isNotNull);
    expect(shareService.bytes!.length > 1000, isTrue);
    expect(shareService.bytes![0], 0x50); // P
    expect(shareService.bytes![1], 0x4B); // K (ZIP signature)
  });

  test('nama file memakai rentang tanggal data untuk periode terfilter', () async {
    final summary = buildExportTestSummary(
      loadExportFixtureTransactions(),
      period: exportTestRange(DateTime(2026, 11, 1), DateTime(2026, 11, 8)),
    );

    await repository.shareReport(
      summary: summary,
      options: const ExportOptions(format: ExportFormat.csv),
    );

    expect(
      shareService.name,
      'Savu_Transaksi_2026-11-01_sd_2026-11-08.csv',
    );
  });

  test('menolak ekspor saat tidak ada transaksi dan tidak memanggil share', () async {
    final summary = buildExportTestSummary(const []);

    expect(
      () => repository.shareReport(
        summary: summary,
        options: const ExportOptions(format: ExportFormat.csv),
      ),
      throwsA(isA<ExportRepositoryException>()),
    );
    expect(shareService.shareCount, 0);
  });
}

class _FakeShareService extends ReportShareService {
  _FakeShareService();

  int shareCount = 0;
  Uint8List? bytes;
  String? name;
  String? mimeType;
  String? subject;

  @override
  Future<void> shareFile({
    required Uint8List bytes,
    required String name,
    required String mimeType,
    required String subject,
  }) async {
    shareCount++;
    this.bytes = bytes;
    this.name = name;
    this.mimeType = mimeType;
    this.subject = subject;
  }
}
