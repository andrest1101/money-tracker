import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/financial_insight_entity.dart';
import 'calculate_budget_cycle_period_usecase.dart';

enum FinancialInsightPeriod { weekly, monthly }

class CalculateFinancialInsightUseCase {
  const CalculateFinancialInsightUseCase();

  static const _cyclePeriod = CalculateBudgetCyclePeriodUseCase();

  FinancialInsightEntity execute({
    required List<TransactionEntity> transactions,
    required DateTime now,
    required FinancialInsightPeriod period,
    int cycleDay = 1,
  }) {
    final currentStart = period == FinancialInsightPeriod.weekly
        ? _day(now, now.subtract(const Duration(days: 6)))
        : _cyclePeriod.execute(date: now, cycleDay: cycleDay).start;
    final previousStart = period == FinancialInsightPeriod.weekly
        ? currentStart.subtract(const Duration(days: 7))
        : _cyclePeriod
              .execute(
                date: DateTime(currentStart.year, currentStart.month, 1),
                cycleDay: cycleDay,
              )
              .start;
    final previousEnd = currentStart.subtract(const Duration(days: 1));
    var income = 0.0;
    var expense = 0.0;
    var previousExpense = 0.0;
    var count = 0;
    final categories = <String, double>{};
    for (final transaction in transactions) {
      if (transaction.date.isBefore(currentStart) ||
          transaction.date.isAfter(now)) {
        if (transaction.isExpense &&
            !transaction.date.isBefore(previousStart) &&
            !transaction.date.isAfter(previousEnd)) {
          previousExpense += transaction.amount;
        }
        continue;
      }
      count++;
      if (transaction.isExpense) {
        expense += transaction.amount;
        categories[transaction.category] =
            (categories[transaction.category] ?? 0) + transaction.amount;
      } else {
        income += transaction.amount;
      }
    }
    final top = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final days = period == FinancialInsightPeriod.weekly
        ? 7
        : now.difference(currentStart).inDays + 1;
    return FinancialInsightEntity(
      income: income,
      expense: expense,
      previousExpense: previousExpense,
      transactionCount: count,
      topCategory: top.isEmpty ? null : top.first.key,
      averageDailyExpense: expense / days,
      periodLabel: period == FinancialInsightPeriod.weekly
          ? '7 hari terakhir'
          : 'siklus anggaran aktif',
    );
  }

  DateTime _day(DateTime reference, DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
