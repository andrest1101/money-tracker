/// Ringkasan satu bulan kalender di dalam periode ekspor.
class MonthlyTotal {
  const MonthlyTotal({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.savings,
    required this.transactionCount,
  });

  final int year;
  final int month;
  final int income;
  final int expense;
  final int savings;
  final int transactionCount;

  int get net => income - expense - savings;

  double get savingsRate => income <= 0 ? 0 : savings / income;
}
