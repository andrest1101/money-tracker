import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/group_transactions_by_date_usecase.dart';

const _groupByDate = GroupTransactionsByDateUseCase();

class _HistoryFilterNotifier extends Notifier<TransactionType?> {
  @override
  TransactionType? build() => null;

  void setType(TransactionType? type) => state = type;
}

final historyFilterProvider =
    NotifierProvider<_HistoryFilterNotifier, TransactionType?>(
  _HistoryFilterNotifier.new,
);

class _HistorySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final historySearchQueryProvider =
    NotifierProvider<_HistorySearchNotifier, String>(
  _HistorySearchNotifier.new,
);

final groupedTransactionsProvider =
    Provider<Map<String, List<TransactionEntity>>>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? const [];
  return _groupByDate.execute(transactions: transactions);
});

final filteredGroupedTransactionsProvider =
    Provider<Map<String, List<TransactionEntity>>>((ref) {
  final grouped = ref.watch(groupedTransactionsProvider);
  final filter = ref.watch(historyFilterProvider);
  final query = ref.watch(historySearchQueryProvider).toLowerCase().trim();

  if (filter == null && query.isEmpty) return grouped;

  final result = <String, List<TransactionEntity>>{};

  for (final entry in grouped.entries) {
    final filtered = entry.value.where((t) {
      final matchType = filter == null || t.type == filter;
      final matchQuery = query.isEmpty ||
          t.category.toLowerCase().contains(query) ||
          t.note.toLowerCase().contains(query);
      return matchType && matchQuery;
    }).toList();

    if (filtered.isNotEmpty) {
      result[entry.key] = filtered;
    }
  }

  return result;
});

final dailySummaryProvider =
    Provider<Map<String, ({double income, double expense})>>((ref) {
  final grouped = ref.watch(groupedTransactionsProvider);

  final summary = <String, ({double income, double expense})>{};

  for (final entry in grouped.entries) {
    var income = 0.0;
    var expense = 0.0;
    for (final t in entry.value) {
      if (t.isExpense) {
        expense += t.amount;
      } else {
        income += t.amount;
      }
    }
    summary[entry.key] = (income: income, expense: expense);
  }

  return summary;
});
