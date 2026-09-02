import '../entities/savings_goal_entity.dart';

class UpdateSavingsGoalUseCase {
  const UpdateSavingsGoalUseCase();

  SavingsGoalEntity execute({
    required SavingsGoalEntity goal,
    required String title,
    required double targetAmount,
    required DateTime deadline,
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw const FormatException('Judul target wajib diisi');
    }
    if (targetAmount <= 0) {
      throw const FormatException('Nominal target harus lebih dari 0');
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final deadlineOnly = DateTime(deadline.year, deadline.month, deadline.day);
    if (deadlineOnly.isBefore(todayOnly)) {
      throw const FormatException('Tenggat tidak boleh sudah lewat');
    }

    return goal.copyWith(
      title: cleanTitle,
      targetAmount: targetAmount,
      deadline: deadline,
    );
  }
}
