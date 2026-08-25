class MonthlySummaryEntity {
  const MonthlySummaryEntity({
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
  });

  final double totalIncome;
  final double totalExpense;
  final int transactionCount;

  double get balance => totalIncome - totalExpense;
}
