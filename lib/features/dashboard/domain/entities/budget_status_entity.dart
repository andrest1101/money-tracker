enum BudgetLevel { safe, warning, exceeded }

class BudgetStatusEntity {
  const BudgetStatusEntity({required this.spentRatio, required this.level});

  final double spentRatio;
  final BudgetLevel level;

  bool get isSafe => level == BudgetLevel.safe;
  bool get isWarning => level == BudgetLevel.warning;
  bool get isExceeded => level == BudgetLevel.exceeded;
}
