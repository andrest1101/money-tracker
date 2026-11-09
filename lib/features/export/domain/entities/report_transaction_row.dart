/// Jenis transaksi setelah dipetakan ke bahasa laporan.
enum ReportTransactionKind { income, expense, savings }

/// Satu baris transaksi yang sudah siap ditulis exporter.
///
/// [amount] dan [runningBalance] sudah berupa rupiah bulat supaya CSV dan XLSX
/// tidak membulatkan ulang dengan cara yang berbeda.
class ReportTransactionRow {
  const ReportTransactionRow({
    required this.id,
    required this.date,
    required this.kind,
    required this.category,
    required this.amount,
    required this.note,
    required this.targetName,
    required this.targetGoalId,
    required this.runningBalance,
  });

  final String id;
  final DateTime date;
  final ReportTransactionKind kind;
  final String category;
  final int amount;
  final String note;

  /// Nama target tabungan. Hanya terisi untuk [ReportTransactionKind.savings].
  final String? targetName;

  /// ID target yang berhasil dicocokkan dari `goalId` atau catatan lama.
  final String? targetGoalId;

  final int runningBalance;

  bool get isIncome => kind == ReportTransactionKind.income;
  bool get isExpense => kind == ReportTransactionKind.expense;
  bool get isSavings => kind == ReportTransactionKind.savings;
}
