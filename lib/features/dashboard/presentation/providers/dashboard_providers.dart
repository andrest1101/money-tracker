import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../transactions/data/providers/transaction_repository_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_expense_entity.dart';
import '../../domain/entities/budget_overview_entity.dart';
import '../../domain/entities/monthly_summary_entity.dart';
import '../../domain/usecases/calculate_category_expenses_usecase.dart';
import '../../domain/usecases/calculate_budget_overview_usecase.dart';
import '../../domain/usecases/calculate_monthly_summary_usecase.dart';
import '../../domain/entities/financial_insight_entity.dart';
import '../../domain/usecases/calculate_financial_insight_usecase.dart';

const _calculateMonthlySummary = CalculateMonthlySummaryUseCase();
const _calculateCategoryExpenses = CalculateCategoryExpensesUseCase();
const _calculateBudgetOverview = CalculateBudgetOverviewUseCase();
const _calculateFinancialInsight = CalculateFinancialInsightUseCase();

final transactionsStreamProvider = StreamProvider<List<TransactionEntity>>((
  ref,
) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions();
});

final monthlySummaryProvider = Provider<AsyncValue<MonthlySummaryEntity>>((
  ref,
) {
  final asyncTransactions = ref.watch(transactionsStreamProvider);
  final cycleDay = ref.watch(budgetCycleDateProvider);

  return asyncTransactions.whenData((transactions) {
    final cycleStart = _cycleStartFor(DateTime.now(), cycleDay);
    return _calculateMonthlySummary.execute(
      transactions: transactions,
      month: cycleStart,
    );
  });
});

/// Returns the start date of the active budget cycle so that monthly summary
/// always matches the budget cycle window, not the calendar month.
DateTime _cycleStartFor(DateTime now, int cycleDay) {
  final day = cycleDay.clamp(1, 28);
  if (now.day >= day) {
    return DateTime(now.year, now.month, day);
  } else {
    final prevMonth = DateTime(now.year, now.month - 1);
    return DateTime(prevMonth.year, prevMonth.month, day);
  }
}

final categoryExpensesProvider =
    Provider<AsyncValue<List<CategoryExpenseEntity>>>((ref) {
      final asyncTransactions = ref.watch(transactionsStreamProvider);
      final cycleDay = ref.watch(budgetCycleDateProvider);

      return asyncTransactions.whenData((transactions) {
        final cycleStart = _cycleStartFor(DateTime.now(), cycleDay);
        return _calculateCategoryExpenses.execute(
          transactions: transactions,
          month: cycleStart,
        );
      });
    });

final budgetOverviewProvider = Provider<AsyncValue<BudgetOverviewEntity>>((
  ref,
) {
  final asyncTransactions = ref.watch(transactionsStreamProvider);
  final budgetLimit = ref.watch(budgetLimitProvider);
  final cycleDay = ref.watch(budgetCycleDateProvider);

  if (budgetLimit == null || budgetLimit <= 0) {
    return const AsyncValue.loading();
  }

  return asyncTransactions.whenData(
    (transactions) => _calculateBudgetOverview.execute(
      transactions: transactions,
      budgetLimit: budgetLimit,
      cycleDay: cycleDay,
    ),
  );
});

final financialInsightProvider = Provider<AsyncValue<FinancialInsightEntity>>((
  ref,
) {
  final transactions = ref.watch(transactionsStreamProvider);
  final cycleDay = ref.watch(budgetCycleDateProvider);
  return transactions.whenData(
    (items) => _calculateFinancialInsight.execute(
      transactions: items,
      now: DateTime.now(),
      period: FinancialInsightPeriod.monthly,
      cycleDay: cycleDay,
    ),
  );
});

const _defaultExpenseCategories = [
  'Makanan',
  'Transportasi',
  'Bensin',
  'Pulsa & Kuota',
  'Hiburan',
  'Kos & Tagihan',
  'Belanja',
  'Lainnya',
];

const _defaultIncomeCategories = ['Uang Kiriman', 'Beasiswa', 'Gaji Part-time'];

final expenseCategoriesProvider = Provider<List<String>>((ref) {
  return _mergeCategories(
    defaults: _defaultExpenseCategories,
    transactions: ref.watch(transactionsStreamProvider).value ?? const [],
    type: TransactionType.expense,
  );
});

final incomeCategoriesProvider = Provider<List<String>>((ref) {
  return _mergeCategories(
    defaults: _defaultIncomeCategories,
    transactions: ref.watch(transactionsStreamProvider).value ?? const [],
    type: TransactionType.income,
  );
});

List<String> _mergeCategories({
  required List<String> defaults,
  required List<TransactionEntity> transactions,
  required TransactionType type,
}) {
  final merged = [...defaults];
  for (final transaction in transactions) {
    if (transaction.type != type) continue;
    if (!merged.contains(transaction.category)) {
      merged.add(transaction.category);
    }
  }
  return merged;
}
