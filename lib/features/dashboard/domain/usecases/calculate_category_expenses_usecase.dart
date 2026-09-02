import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/category_expense_entity.dart';

class CalculateCategoryExpensesUseCase {
  const CalculateCategoryExpensesUseCase();

  List<CategoryExpenseEntity> execute({
    required List<TransactionEntity> transactions,
    DateTime? month,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    final totalsByCategory = <String, double>{};

    for (final transaction in transactions) {
      final isInPeriod = periodStart != null && periodEnd != null
          ? !transaction.date.isBefore(periodStart) &&
                !transaction.date.isAfter(periodEnd)
          : month != null &&
                transaction.date.year == month.year &&
                transaction.date.month == month.month;
      if (!isInPeriod || !transaction.isExpense) continue;

      totalsByCategory[transaction.category] =
          (totalsByCategory[transaction.category] ?? 0) + transaction.amount;
    }

    final entries = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map(
          (entry) =>
              CategoryExpenseEntity(category: entry.key, amount: entry.value),
        )
        .toList();
  }
}
