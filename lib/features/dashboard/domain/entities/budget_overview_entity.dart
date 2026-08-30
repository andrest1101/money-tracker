import 'budget_status_entity.dart';
import 'category_expense_entity.dart';

class BudgetOverviewEntity {
  const BudgetOverviewEntity({
    required this.budgetLimit,
    required this.totalExpense,
    required this.spentRatio,
    required this.level,
    required this.periodStart,
    required this.periodEnd,
    required this.elapsedDays,
    required this.totalDays,
    required this.transactionCount,
    required this.averageDailyExpense,
    required this.projectedExpense,
    required this.topCategories,
  });

  final double budgetLimit;
  final double totalExpense;
  final double spentRatio;
  final BudgetLevel level;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int elapsedDays;
  final int totalDays;
  final int transactionCount;
  final double averageDailyExpense;
  final double projectedExpense;
  final List<CategoryExpenseEntity> topCategories;

  double get remaining => budgetLimit - totalExpense;
  bool get isExceeded => level == BudgetLevel.exceeded;
  bool get isWarning => level == BudgetLevel.warning;
  bool get isSafe => level == BudgetLevel.safe;
}
