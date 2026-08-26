import '../entities/budget_status_entity.dart';

class CheckBudgetStatusUseCase {
  const CheckBudgetStatusUseCase();

  static const double warningThreshold = 0.8;

  BudgetStatusEntity execute({
    required double totalExpense,
    required double budgetLimit,
  }) {
    if (budgetLimit <= 0) {
      return const BudgetStatusEntity(
        spentRatio: 0,
        level: BudgetLevel.safe,
      );
    }

    final spentRatio = totalExpense / budgetLimit;

    final level = spentRatio >= 1
        ? BudgetLevel.exceeded
        : spentRatio >= warningThreshold
            ? BudgetLevel.warning
            : BudgetLevel.safe;

    return BudgetStatusEntity(spentRatio: spentRatio, level: level);
  }
}
