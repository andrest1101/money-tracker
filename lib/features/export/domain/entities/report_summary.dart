import 'category_total.dart';
import 'goal_progress.dart';
import 'monthly_total.dart';
import 'report_transaction_row.dart';

/// Semua angka dan teks laporan yang dihitung satu kali di Domain.
///
/// Exporter CSV/XLSX hanya memformat nilai di sini; tidak boleh menghitung
/// ulang total, persentase, atau saldo.
class ReportSummary {
  const ReportSummary({
    required this.appName,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.periodLabel,
    required this.isAllTime,
    required this.dataStart,
    required this.dataEnd,
    required this.openingBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.netChange,
    required this.endingBalance,
    required this.transactionCount,
    required this.daysInPeriod,
    required this.daysWithRecords,
    required this.averageExpensePerDay,
    required this.savingsRate,
    required this.activeCycleBalance,
    required this.activeCycleStart,
    required this.activeCycleEnd,
    required this.transactions,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.months,
    required this.goals,
    required this.unmatchedAllocationCount,
    required this.unmatchedAllocationAmount,
    required this.largestExpenseCategory,
    required this.largestExpenseTransaction,
    required this.insights,
  });

  final String appName;
  final DateTime generatedAt;

  /// Periode yang diminta. Untuk "Semua waktu", nilainya sama dengan rentang
  /// data aktual.
  final DateTime periodStart;
  final DateTime periodEnd;
  final String periodLabel;
  final bool isAllTime;

  /// Tanggal transaksi pertama dan terakhir yang benar-benar diekspor.
  final DateTime? dataStart;
  final DateTime? dataEnd;

  final int openingBalance;
  final int totalIncome;
  final int totalExpense;
  final int totalSavings;
  final int netChange;
  final int endingBalance;

  final int transactionCount;
  final int daysInPeriod;
  final int daysWithRecords;
  final double averageExpensePerDay;
  final double savingsRate;

  /// Angka dashboard: pemasukan - seluruh pengeluaran (termasuk tabungan)
  /// dalam siklus anggaran aktif.
  final int activeCycleBalance;
  final DateTime activeCycleStart;
  final DateTime activeCycleEnd;

  final List<ReportTransactionRow> transactions;
  final List<CategoryTotal> expenseCategories;
  final List<CategoryTotal> incomeCategories;
  final List<MonthlyTotal> months;
  final List<GoalProgress> goals;

  final int unmatchedAllocationCount;
  final int unmatchedAllocationAmount;

  final CategoryTotal? largestExpenseCategory;
  final ReportTransactionRow? largestExpenseTransaction;
  final List<String> insights;

  bool get hasTransactions => transactions.isNotEmpty;

  /// Rentang yang dipakai untuk nama file. Memakai tanggal data aktual agar
  /// ekspor "bulan ini" tidak menulis tanggal akhir bulan yang belum terjadi.
  DateTime get rangeStart => dataStart ?? periodStart;
  DateTime get rangeEnd => dataEnd ?? periodEnd;
}
