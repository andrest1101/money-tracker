/// Format file yang bisa dipilih pengguna.
enum ExportFormat { csv, xlsx }

/// Pemisah kolom CSV. Titik koma menjadi default untuk Excel Indonesia.
enum CsvDelimiter { semicolon, comma }

extension CsvDelimiterX on CsvDelimiter {
  String get character => this == CsvDelimiter.semicolon ? ';' : ',';

  String get label => this == CsvDelimiter.semicolon ? 'Titik koma (;)' : 'Koma (,)';
}

/// Periode yang bisa dipilih pada dialog ekspor.
enum ExportPeriodType { allTime, thisMonth, activeCycle, custom }

extension ExportPeriodTypeX on ExportPeriodType {
  String get label {
    switch (this) {
      case ExportPeriodType.allTime:
        return 'Semua waktu';
      case ExportPeriodType.thisMonth:
        return 'Bulan ini';
      case ExportPeriodType.activeCycle:
        return 'Siklus aktif';
      case ExportPeriodType.custom:
        return 'Pilih tanggal';
    }
  }
}

/// Pilihan lengkap dari dialog ekspor.
class ExportOptions {
  const ExportOptions({
    this.format = ExportFormat.xlsx,
    this.period = ExportPeriodType.allTime,
    this.delimiter = CsvDelimiter.semicolon,
    this.customStart,
    this.customEnd,
  });

  final ExportFormat format;
  final ExportPeriodType period;
  final CsvDelimiter delimiter;
  final DateTime? customStart;
  final DateTime? customEnd;

  ExportOptions copyWith({
    ExportFormat? format,
    ExportPeriodType? period,
    CsvDelimiter? delimiter,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    return ExportOptions(
      format: format ?? this.format,
      period: period ?? this.period,
      delimiter: delimiter ?? this.delimiter,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
    );
  }
}
