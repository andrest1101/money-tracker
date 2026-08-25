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

class BudgetLimit extends Notifier<double?> {
  @override
  double? build() => null;

  void setBudgetLimit(double? limit) {
    state = limit;
  }
}

final budgetLimitProvider =
    NotifierProvider<BudgetLimit, double?>(BudgetLimit.new);
