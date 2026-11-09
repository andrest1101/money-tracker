/// Rentang periode yang sudah diselesaikan sebelum data difilter.
class ExportPeriod {
  const ExportPeriod({
    this.start,
    this.end,
    required this.label,
    required this.isAllTime,
  });

  /// Null jika [isAllTime] bernilai true.
  final DateTime? start;
  final DateTime? end;

  final String label;
  final bool isAllTime;

  bool get hasRange => start != null && end != null;
}
