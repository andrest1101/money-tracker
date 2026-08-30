class FinancialInsightEntity {
  const FinancialInsightEntity({
    required this.income,
    required this.expense,
    required this.previousExpense,
    required this.transactionCount,
    required this.topCategory,
    required this.averageDailyExpense,
    required this.periodLabel,
  });

  final double income;
  final double expense;
  final double previousExpense;
  final int transactionCount;
  final String? topCategory;
  final double averageDailyExpense;
  final String periodLabel;

  double get net => income - expense;
  double get expenseChangeRatio => previousExpense == 0
      ? (expense == 0 ? 0 : 1)
      : (expense - previousExpense) / previousExpense;
}
