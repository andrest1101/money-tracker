import 'package:flutter_test/flutter_test.dart';

import 'package:savu/features/savings/domain/entities/savings_goal_entity.dart';

void main() {
  SavingsGoalEntity goalWithDeadline(DateTime deadline) => SavingsGoalEntity(
    id: 'goal-1',
    title: 'Dana darurat',
    targetAmount: 1000000,
    currentAmount: 250000,
    deadline: deadline,
    createdAt: DateTime(2026, 1, 1),
  );

  test('marks a goal due within seven days as near deadline', () {
    final today = DateTime.now();
    final goal = goalWithDeadline(today.add(const Duration(days: 7)));

    expect(goal.isDeadlineNear, isTrue);
    expect(goal.isOverdue, isFalse);
  });

  test('marks an incomplete goal before today as overdue', () {
    final goal = goalWithDeadline(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    expect(goal.isOverdue, isTrue);
    expect(goal.isDeadlineNear, isFalse);
  });

  test('completed goal is not overdue even after its deadline', () {
    final goal = goalWithDeadline(
      DateTime.now().subtract(const Duration(days: 1)),
    ).copyWith(currentAmount: 1000000);

    expect(goal.isCompleted, isTrue);
    expect(goal.isOverdue, isFalse);
  });
}
