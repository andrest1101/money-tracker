import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../data/providers/savings_goal_repository_provider.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/usecases/allocate_to_goal_usecase.dart';

final savingsGoalsStreamProvider =
    StreamProvider<List<SavingsGoalEntity>>((ref) {
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return repository.watchGoals();
});

class SavingsActionsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> addGoal(SavingsGoalEntity goal) async {
    state = const AsyncLoading();
    try {
      await ref.read(savingsGoalRepositoryProvider).addGoal(goal);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> allocateToGoal({
    required SavingsGoalEntity goal,
    required double amount,
  }) async {
    state = const AsyncLoading();
    try {
      const allocateToGoal = AllocateToGoalUseCase();
      final availableBalance =
          ref.read(monthlySummaryProvider).value?.balance ?? 0;

      final newCurrentAmount = allocateToGoal.execute(
        goal: goal,
        amount: amount,
        availableBalance: availableBalance,
      );

      final transaction = TransactionEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        amount: amount,
        type: TransactionType.expense,
        category: 'Alokasi Tabungan',
        date: DateTime.now(),
        note: 'Menabung untuk ${goal.title}',
      );

      await ref
          .read(savingsGoalRepositoryProvider)
          .allocateToGoal(
            goal: goal,
            newCurrentAmount: newCurrentAmount,
            allocationTransaction: transaction,
          );

      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final savingsActionsControllerProvider =
    NotifierProvider<SavingsActionsController, AsyncValue<void>>(
  SavingsActionsController.new,
);
