import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/budget_overview_entity.dart';
import '../entities/category_expense_entity.dart';
import 'check_budget_status_usecase.dart';
import 'calculate_budget_cycle_period_usecase.dart';

class CalculateBudgetOverviewUseCase {
  const CalculateBudgetOverviewUseCase();

  static const _checkStatus = CheckBudgetStatusUseCase();
  static const _calculatePeriod = CalculateBudgetCyclePeriodUseCase();

  BudgetOverviewEntity execute({
    required List<TransactionEntity> transactions,
    required double budgetLimit,
    required int cycleDay,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final period = _calculatePeriod.execute(date: today, cycleDay: cycleDay);
    final start = period.start;
    final end = period.end;
    final totalDays = end.difference(start).inDays + 1;
    final elapsedDays = (today.difference(start).inDays + 1).clamp(
      1,
      totalDays,
    );

    final categoryTotals = <String, double>{};
    var totalExpense = 0.0;
    var transactionCount = 0;
    for (final transaction in transactions) {
      if (!transaction.isExpense ||
          transaction.date.isBefore(start) ||
          transaction.date.isAfter(today)) {
        continue;
      }
      totalExpense += transaction.amount;
      transactionCount++;
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    final categories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final average = totalExpense / elapsedDays;

    return BudgetOverviewEntity(
      budgetLimit: budgetLimit,
      totalExpense: totalExpense,
      spentRatio: totalExpense / budgetLimit,
      level: _checkStatus
          .execute(totalExpense: totalExpense, budgetLimit: budgetLimit)
          .level,
      periodStart: start,
      periodEnd: end,
      elapsedDays: elapsedDays,
      totalDays: totalDays,
      transactionCount: transactionCount,
      averageDailyExpense: average,
      projectedExpense: average * totalDays,
      topCategories: categories
          .take(3)
          .map(
            (entry) =>
                CategoryExpenseEntity(category: entry.key, amount: entry.value),
          )
          .toList(),
    );
  }
}
