import '../entities/savings_goal_entity.dart';

abstract interface class SavingsGoalRepository {
  Stream<List<SavingsGoalEntity>> watchGoals();

  Future<void> addGoal(SavingsGoalEntity goal);

  Future<void> updateGoal(SavingsGoalEntity goal);

  Future<void> deleteGoal(String id);
}
