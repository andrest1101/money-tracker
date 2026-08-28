import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/savings_goal_entity.dart';

abstract interface class SavingsGoalRepository {
  Stream<List<SavingsGoalEntity>> watchGoals();

  Future<void> addGoal(SavingsGoalEntity goal);

  Future<void> updateGoal(SavingsGoalEntity goal);

  Future<void> deleteGoal(String id);

  /// Hapus goal beserta semua transaksi alokasi-nya dalam satu batch atomik.
  Future<void> deleteGoalWithAllocations(String goalId);

  /// Menghapus seluruh target dan transaksi dalam batch berukuran aman.
  Future<void> deleteAllData();

  Future<SavingsGoalEntity> getGoalById(String id);

  Future<void> allocateToGoal({
    required SavingsGoalEntity goal,
    required double newCurrentAmount,
    required TransactionEntity allocationTransaction,
  });

  Future<void> updateAllocation({
    required String goalId,
    required double newGoalAmount,
    required TransactionEntity updatedTransaction,
  });

  Future<void> deleteAllocation({
    required String goalId,
    required double newGoalAmount,
    required String transactionId,
  });
}
