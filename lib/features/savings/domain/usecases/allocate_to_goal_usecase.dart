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
}
