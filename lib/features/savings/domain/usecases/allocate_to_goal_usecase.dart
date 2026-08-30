import '../entities/savings_goal_entity.dart';

class InvalidAllocationException implements Exception {
  const InvalidAllocationException(this.message);

  final String message;

  @override
  String toString() => 'InvalidAllocationException: $message';
}

class AllocateToGoalUseCase {
  const AllocateToGoalUseCase();

  double execute({
    required SavingsGoalEntity goal,
    required double amount,
    required double availableBalance,
  }) {
    if (amount <= 0) {
      throw const InvalidAllocationException('Nominal alokasi harus lebih dari 0');
    }
    if (amount > availableBalance) {
      throw const InvalidAllocationException('Saldo utama tidak cukup untuk alokasi ini');
    }
    if (amount > goal.remainingAmount) {
      throw InvalidAllocationException(
        'Nominal melebihi sisa target (${goal.remainingAmount.round()}). '
        'Maksimal alokasi: ${goal.remainingAmount.round()}',
      );
    }
    return goal.currentAmount + amount;
  }

  double executeEdit({
    required SavingsGoalEntity goal,
    required double oldAmount,
    required double newAmount,
    required double availableBalance,
  }) {
    if (newAmount < 0) {
      throw const InvalidAllocationException(
        'Nominal alokasi tidak boleh negatif',
      );
    }

    final availableForEdit = availableBalance + oldAmount;
    if (newAmount > availableForEdit) {
      throw const InvalidAllocationException(
        'Saldo utama tidak cukup untuk nominal alokasi baru',
      );
    }

    final newGoalAmount = goal.currentAmount - oldAmount + newAmount;
    if (newGoalAmount < 0) {
      throw const InvalidAllocationException('Nominal edit membuat target tabungan negatif');
    }
    if (newGoalAmount > goal.targetAmount) {
      throw InvalidAllocationException(
        'Nominal melebihi sisa target (${(goal.targetAmount - goal.currentAmount + oldAmount).round()})',
      );
    }
    return newGoalAmount;
  }
}
