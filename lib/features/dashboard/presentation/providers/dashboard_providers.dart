import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/data/providers/transaction_repository_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_expense_entity.dart';
import '../../domain/entities/monthly_summary_entity.dart';
import '../../domain/usecases/calculate_category_expenses_usecase.dart';
import '../../domain/usecases/calculate_monthly_summary_usecase.dart';

const _calculateMonthlySummary = CalculateMonthlySummaryUseCase();
const _calculateCategoryExpenses = CalculateCategoryExpensesUseCase();

final transactionsStreamProvider =
    StreamProvider<List<TransactionEntity>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions();
});

final monthlySummaryProvider =
    Provider<AsyncValue<MonthlySummaryEntity>>((ref) {
  final asyncTransactions = ref.watch(transactionsStreamProvider);

  return asyncTransactions.whenData(
    (transactions) => _calculateMonthlySummary.execute(
      transactions: transactions,
      month: DateTime.now(),
    ),
  );
});

final categoryExpensesProvider =
    Provider<AsyncValue<List<CategoryExpenseEntity>>>((ref) {
  final asyncTransactions = ref.watch(transactionsStreamProvider);

  return asyncTransactions.whenData(
    (transactions) => _calculateCategoryExpenses.execute(
      transactions: transactions,
      month: DateTime.now(),
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

const _defaultIncomeCategories = [
  'Uang Kiriman',
  'Beasiswa',
  'Gaji Part-time',
];

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
