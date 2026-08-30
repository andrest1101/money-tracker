import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../savings/data/providers/savings_goal_repository_provider.dart';
import '../../../savings/domain/usecases/allocate_to_goal_usecase.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/providers/transaction_repository_provider.dart';
import '../../domain/entities/transaction_entity.dart';

class QuickAddController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> submit(TransactionEntity transaction) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.addTransaction(transaction);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading();
    try {
      if (transaction.isAllocation) {
        await _updateAllocationTransaction(transaction);
      } else {
        final repository = ref.read(transactionRepositoryProvider);
        await repository.updateTransaction(transaction);
      }
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading();
    try {
      if (transaction.isAllocation && transaction.goalId != null) {
        // Delete allocation transaction and restore goal amount
        final savingsRepo = ref.read(savingsGoalRepositoryProvider);
        final goal = await savingsRepo.getGoalById(transaction.goalId!);
        final newGoalAmount = goal.currentAmount - transaction.amount;

        if (newGoalAmount < 0) {
          throw Exception('Tidak dapat menghapus alokasi: saldo target menjadi negatif');
        }

        await savingsRepo.deleteAllocation(
          goalId: goal.id,
          newGoalAmount: newGoalAmount,
          transactionId: transaction.id,
        );
      } else {
        // Regular transaction, just delete
        final repository = ref.read(transactionRepositoryProvider);
        await repository.deleteTransaction(transaction.id);
      }
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> _updateAllocationTransaction(
    TransactionEntity transaction,
  ) async {
    final savingsRepo = ref.read(savingsGoalRepositoryProvider);
    final transactionRepo = ref.read(transactionRepositoryProvider);

    final goal = await savingsRepo.getGoalById(transaction.goalId!);
    final oldTransaction = await transactionRepo.getTransactionById(transaction.id);

    final oldAmount = oldTransaction.amount;
    final newAmount = transaction.amount;

    // If newAmount is 0, delete transaction and restore goal amount
    if (newAmount == 0) {
      final restoredAmount = goal.currentAmount - oldAmount;

      if (restoredAmount < 0) {
        throw Exception('Nominal edit membuat target tabungan negatif');
      }

      await savingsRepo.deleteAllocation(
        goalId: goal.id,
        newGoalAmount: restoredAmount,
        transactionId: transaction.id,
      );
      return;
    }

    final summary = ref.read(monthlySummaryProvider).value;
    final now = DateTime.now();
    final oldAllocationIsInCurrentMonth =
        oldTransaction.date.year == now.year &&
        oldTransaction.date.month == now.month;
    final monthlyBalance = summary?.balance ?? 0;
    final availableBalance = oldAllocationIsInCurrentMonth
        ? monthlyBalance + oldAmount
        : monthlyBalance;
    final newGoalAmount = const AllocateToGoalUseCase().executeEdit(
      goal: goal,
      oldAmount: oldAmount,
      newAmount: newAmount,
      availableBalance: availableBalance,
    );

    // Pastikan transaksi alokasi tetap bertipe expense dengan goalId yang sama
    final correctedTransaction = TransactionEntity(
      id: transaction.id,
      amount: newAmount,
      type: oldTransaction.type,
      category: oldTransaction.category,
      date: transaction.date,
      note: transaction.note.isNotEmpty ? transaction.note : oldTransaction.note,
      goalId: oldTransaction.goalId,
    );

    await savingsRepo.updateAllocation(
      goalId: goal.id,
      newGoalAmount: newGoalAmount,
      updatedTransaction: correctedTransaction,
    );
  }
}

final quickAddControllerProvider =
    NotifierProvider<QuickAddController, AsyncValue<void>>(
  QuickAddController.new,
);
