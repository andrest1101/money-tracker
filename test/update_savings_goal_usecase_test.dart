import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/savings/domain/entities/savings_goal_entity.dart';
import 'package:money_tracker/features/savings/domain/usecases/update_savings_goal_usecase.dart';

void main() {
  final useCase = const UpdateSavingsGoalUseCase();
  final goal = SavingsGoalEntity(
    id: 'goal-1',
    title: 'Handphone',
    targetAmount: 3000000,
    currentAmount: 1200000,
    deadline: DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime(2026, 1, 1),
  );

  test('updates target metadata while preserving allocation amount', () {
    final updated = useCase.execute(
      goal: goal,
      title: 'Handphone baru',
      targetAmount: 4000000,
      deadline: DateTime.now().add(const Duration(days: 60)),
    );

    expect(updated.id, goal.id);
    expect(updated.currentAmount, goal.currentAmount);
    expect(updated.title, 'Handphone baru');
    expect(updated.targetAmount, 4000000);
  });

  test('rejects an empty title', () {
    expect(
      () => useCase.execute(
        goal: goal,
        title: '  ',
        targetAmount: 4000000,
        deadline: goal.deadline,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a non-positive target amount', () {
    expect(
      () => useCase.execute(
        goal: goal,
        title: goal.title,
        targetAmount: 0,
        deadline: goal.deadline,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a deadline in the past', () {
    expect(
      () => useCase.execute(
        goal: goal,
        title: goal.title,
        targetAmount: goal.targetAmount,
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
