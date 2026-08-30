import '../entities/transaction_entity.dart';

class FilterTransactionsUseCase {
  const FilterTransactionsUseCase();

  List<TransactionEntity> execute({
    required List<TransactionEntity> transactions,
    TransactionType? type,
    String? category,
    String query = '',
    DateTime? cycleStart,
    DateTime? cycleEnd,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return transactions.where((transaction) {
      final matchesType = type == null || transaction.type == type;
      final matchesCategory = category == null || transaction.category == category;
      final matchesCycle = cycleStart == null ||
          cycleEnd == null ||
          !transaction.date.isBefore(cycleStart) &&
              !transaction.date.isAfter(cycleEnd);
      final matchesQuery = normalizedQuery.isEmpty ||
          transaction.category.toLowerCase().contains(normalizedQuery) ||
          transaction.note.toLowerCase().contains(normalizedQuery);

      return matchesType && matchesCategory && matchesCycle && matchesQuery;
    }).toList();
  }
}
