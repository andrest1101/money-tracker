import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
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

final allocationTransactionsProvider = Provider.family<
    List<TransactionEntity>,
    String>((ref, goalId) {
  final allTransactions = ref.watch(transactionsStreamProvider).value ?? [];
  return allTransactions
      .where((t) => t.goalId == goalId)
      .toList();
});

enum SavingsSortOption { newest, oldest, progress }

class SavingsSortController extends Notifier<SavingsSortOption> {
  @override
  SavingsSortOption build() {
    final settingsService = ref.watch(settingsServiceProvider);
    final stored = settingsService.getSavingsSortOption();
    
    switch (stored) {
      case 'oldest':
        return SavingsSortOption.oldest;
      case 'progress':
        return SavingsSortOption.progress;
      default:
        return SavingsSortOption.newest;
    }
  }

  Future<void> setSortOption(SavingsSortOption option) async {
    final settingsService = ref.read(settingsServiceProvider);
    await settingsService.setSavingsSortOption(option.name);
    state = option;
  }
}

final savingsSortControllerProvider =
    NotifierProvider<SavingsSortController, SavingsSortOption>(
  SavingsSortController.new,
);

final sortedSavingsGoalsProvider =
    Provider<AsyncValue<List<SavingsGoalEntity>>>((ref) {
  final goalsAsync = ref.watch(savingsGoalsStreamProvider);
  final sortOption = ref.watch(savingsSortControllerProvider);

  return goalsAsync.whenData((goals) {
    final sorted = List<SavingsGoalEntity>.from(goals);
    
    switch (sortOption) {
      case SavingsSortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SavingsSortOption.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SavingsSortOption.progress:
        sorted.sort((a, b) => b.progress.compareTo(a.progress));
        break;
    }
    
    return sorted;
  });
});

final activeGoalsProvider =
    Provider<AsyncValue<List<SavingsGoalEntity>>>((ref) {
  return ref.watch(sortedSavingsGoalsProvider).whenData(
        (goals) => goals.where((g) => !g.isCompleted).toList(),
      );
});

final completedGoalsProvider =
    Provider<AsyncValue<List<SavingsGoalEntity>>>((ref) {
  return ref.watch(sortedSavingsGoalsProvider).whenData(
        (goals) => goals.where((g) => g.isCompleted).toList(),
      );
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

  Future<bool> deleteGoal(SavingsGoalEntity goal) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(savingsGoalRepositoryProvider)
          .deleteGoalWithAllocations(goal.id);
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
        goalId: goal.id,
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
