import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/savings/domain/entities/savings_goal_entity.dart';
import 'package:money_tracker/features/savings/domain/usecases/allocate_to_goal_usecase.dart';

void main() {
  const useCase = AllocateToGoalUseCase();

  final goal = SavingsGoalEntity(
    id: 'goal-1',
    title: 'UKT Semester 3',
    targetAmount: 5000000,
    currentAmount: 1000000,
    deadline: DateTime(2026, 12, 31),
    createdAt: DateTime(2026, 8, 1),
  );

  group('AllocateToGoalUseCase', () {
    test('alokasi valid menambahkan currentAmount', () {
      final newCurrent = useCase.execute(
        goal: goal,
        amount: 500000,
        availableBalance: 2000000,
      );

      expect(newCurrent, 1500000);
    });

    test('nominal nol atau negatif ditolak', () {
      expect(
        () => useCase.execute(goal: goal, amount: 0, availableBalance: 100),
        throwsA(isA<InvalidAllocationException>()),
      );
      expect(
        () => useCase.execute(
          goal: goal,
          amount: -50000,
          availableBalance: 100000,
        ),
        throwsA(isA<InvalidAllocationException>()),
      );
    });

    test('nominal melebihi saldo utama ditolak', () {
      expect(
        () => useCase.execute(
          goal: goal,
          amount: 300000,
          availableBalance: 250000,
        ),
        throwsA(isA<InvalidAllocationException>()),
      );
    });

    test('nominal tepat sebesar saldo masih diterima', () {
      final newCurrent = useCase.execute(
        goal: goal,
        amount: 250000,
        availableBalance: 250000,
      );

      expect(newCurrent, 1250000);
    });

    test('nominal melebihi sisa target ditolak', () {
      expect(
        () => useCase.execute(
          goal: goal,
          amount: 4500000,
          availableBalance: 5000000,
        ),
        throwsA(isA<InvalidAllocationException>()),
      );
    });

    test('nominal tepat sebesar sisa target diterima', () {
      final newCurrent = useCase.execute(
        goal: goal,
        amount: 4000000,
        availableBalance: 5000000,
      );

      expect(newCurrent, 5000000);
    });

    test('edit alokasi mengembalikan nominal lama ke saldo yang tersedia', () {
      final newCurrent = useCase.executeEdit(
        goal: goal,
        oldAmount: 100000,
        newAmount: 405000,
        availableBalance: 305000,
      );

      expect(newCurrent, 1305000);
    });

    test('edit alokasi melebihi saldo tersedia ditolak', () {
      expect(
        () => useCase.executeEdit(
          goal: goal,
          oldAmount: 100000,
          newAmount: 410000,
          availableBalance: 305000,
        ),
        throwsA(
          isA<InvalidAllocationException>().having(
            (error) => error.message,
            'message',
            'Saldo utama tidak cukup untuk nominal alokasi baru',
          ),
        ),
      );
    });
  });
}
