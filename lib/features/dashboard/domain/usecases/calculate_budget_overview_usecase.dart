import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/budget_overview_entity.dart';
import '../entities/category_expense_entity.dart';
import 'check_budget_status_usecase.dart';

class CalculateBudgetOverviewUseCase {
  const CalculateBudgetOverviewUseCase();

  static const _checkStatus = CheckBudgetStatusUseCase();

  BudgetOverviewEntity execute({
    required List<TransactionEntity> transactions,
    required double budgetLimit,
    required int cycleDay,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final start = _periodStart(today, cycleDay);
    final end = _periodEnd(start, cycleDay);
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

  DateTime _periodStart(DateTime date, int cycleDay) {
    final day = cycleDay.clamp(1, 31);
    if (date.day >= day) {
      return DateTime(
        date.year,
        date.month,
        _validDay(date.year, date.month, day),
      );
    }
    final previous = DateTime(date.year, date.month - 1);
    return DateTime(
      previous.year,
      previous.month,
      _validDay(previous.year, previous.month, day),
    );
  }

  DateTime _periodEnd(DateTime start, int cycleDay) {
    final next = DateTime(start.year, start.month + 1);
    return DateTime(
      next.year,
      next.month,
      _validDay(next.year, next.month, cycleDay),
    ).subtract(const Duration(days: 1));
  }

  int _validDay(int year, int month, int requested) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return requested.clamp(1, lastDay);
  }
}
