import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/category_expense_entity.dart';

class CalculateCategoryExpensesUseCase {
  const CalculateCategoryExpensesUseCase();

  List<CategoryExpenseEntity> execute({
    required List<TransactionEntity> transactions,
    required DateTime month,
  }) {
    final totalsByCategory = <String, double>{};

    for (final transaction in transactions) {
      final isSameMonth = transaction.date.year == month.year &&
          transaction.date.month == month.month;
      if (!isSameMonth || !transaction.isExpense) continue;

      totalsByCategory[transaction.category] =
          (totalsByCategory[transaction.category] ?? 0) + transaction.amount;
    }

    final entries = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map(
          (entry) => CategoryExpenseEntity(
            category: entry.key,
            amount: entry.value,
          ),
        )
        .toList();
  }
}
