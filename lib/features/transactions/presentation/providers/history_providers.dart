import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/domain/usecases/calculate_budget_cycle_period_usecase.dart';
import '../../../../core/local_storage/settings_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/group_transactions_by_date_usecase.dart';
import '../../domain/usecases/filter_transactions_usecase.dart';

const _groupByDate = GroupTransactionsByDateUseCase();
const _calculatePeriod = CalculateBudgetCyclePeriodUseCase();
const _filterTransactions = FilterTransactionsUseCase();

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

class _HistoryCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setCategory(String? category) => state = category;
}

final historyCategoryProvider =
    NotifierProvider<_HistoryCategoryNotifier, String?>(
      _HistoryCategoryNotifier.new,
    );

class _HistoryCycleNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final historyCycleProvider = NotifierProvider<_HistoryCycleNotifier, bool>(
  _HistoryCycleNotifier.new,
);

class HistoryDateRange {
  const HistoryDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get lengthInDays => end.difference(start).inDays + 1;
  bool get isValid => !end.isBefore(start) && lengthInDays <= 31;
}

class _HistoryDateRangeNotifier extends Notifier<HistoryDateRange?> {
  @override
  HistoryDateRange? build() => null;

  bool setRange(DateTime start, DateTime end) {
    final value = HistoryDateRange(
      start: DateTime(start.year, start.month, start.day),
      end: DateTime(end.year, end.month, end.day, 23, 59, 59, 999),
    );
    if (!value.isValid) return false;
    state = value;
    return true;
  }

  void clear() => state = null;
}

final historyDateRangeProvider =
    NotifierProvider<_HistoryDateRangeNotifier, HistoryDateRange?>(
      _HistoryDateRangeNotifier.new,
    );

enum HistoryNavigationTarget { activeCycle, categoryInActiveCycle }

class HistoryNavigationIntent {
  const HistoryNavigationIntent._({required this.target, this.category});

  const HistoryNavigationIntent.activeCycle()
    : this._(target: HistoryNavigationTarget.activeCycle);

  const HistoryNavigationIntent.categoryInActiveCycle(String category)
    : this._(
        target: HistoryNavigationTarget.categoryInActiveCycle,
        category: category,
      );

  final HistoryNavigationTarget target;
  final String? category;
}

class HistoryNavigationController extends Notifier<HistoryNavigationIntent?> {
  @override
  HistoryNavigationIntent? build() => null;

  void openActiveCycle() {
    state = const HistoryNavigationIntent.activeCycle();
  }

  void openCategoryInActiveCycle(String category) {
    state = HistoryNavigationIntent.categoryInActiveCycle(category);
  }

  void consume() => state = null;
}

final historyNavigationIntentProvider =
    NotifierProvider<HistoryNavigationController, HistoryNavigationIntent?>(
      HistoryNavigationController.new,
    );

void resetHistoryFilters(WidgetRef ref) {
  ref.read(historyFilterProvider.notifier).setType(null);
  ref.read(historyCategoryProvider.notifier).setCategory(null);
  ref.read(historySearchQueryProvider.notifier).setQuery('');
  ref.read(historyDateRangeProvider.notifier).clear();
  if (ref.read(historyCycleProvider)) {
    ref.read(historyCycleProvider.notifier).toggle();
  }
}

final historyCategoriesProvider = Provider<List<String>>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? const [];
  final counts = <String, int>{};
  for (final transaction in transactions) {
    counts[transaction.category] = (counts[transaction.category] ?? 0) + 1;
  }
  return counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
});

final groupedTransactionsProvider =
    Provider<Map<String, List<TransactionEntity>>>((ref) {
      final transactions =
          ref.watch(transactionsStreamProvider).value ?? const [];
      return _groupByDate.execute(transactions: transactions);
    });

final filteredGroupedTransactionsProvider =
    Provider<Map<String, List<TransactionEntity>>>((ref) {
      final grouped = ref.watch(groupedTransactionsProvider);
      final filter = ref.watch(historyFilterProvider);
      final category = ref.watch(historyCategoryProvider);
      final cycleOnly = ref.watch(historyCycleProvider);
      final dateRange = ref.watch(historyDateRangeProvider);
      final cycleDay = ref.watch(budgetCycleDateProvider);
      final cycle = _calculatePeriod.execute(
        date: DateTime.now(),
        cycleDay: cycleDay,
      );
      final query = ref.watch(historySearchQueryProvider).toLowerCase().trim();

      if (filter == null &&
          category == null &&
          !cycleOnly &&
          dateRange == null &&
          query.isEmpty) {
        return grouped;
      }

      final result = <String, List<TransactionEntity>>{};

      for (final entry in grouped.entries) {
        final filtered = _filterTransactions.execute(
          transactions: entry.value,
          type: filter,
          category: category,
          query: query,
          cycleStart: cycleOnly ? cycle.start : null,
          cycleEnd: cycleOnly ? cycle.end : null,
          dateRangeStart: dateRange?.start,
          dateRangeEnd: dateRange?.end,
        );

        if (filtered.isNotEmpty) {
          result[entry.key] = filtered;
        }
      }

      return result;
    });

final dailySummaryProvider =
    Provider<Map<String, ({double income, double expense})>>((ref) {
      final grouped = ref.watch(filteredGroupedTransactionsProvider);

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
