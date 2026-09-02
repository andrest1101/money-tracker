import 'package:flutter_test/flutter_test.dart';
import 'package:savu/features/dashboard/domain/entities/budget_status_entity.dart';
import 'package:savu/features/dashboard/domain/usecases/check_budget_status_usecase.dart';

void main() {
  const useCase = CheckBudgetStatusUseCase();

  group('CheckBudgetStatusUseCase', () {
    test('pengeluaran di bawah 80% berstatus aman', () {
      final status = useCase.execute(
        totalExpense: 790000,
        budgetLimit: 1000000,
      );

      expect(status.level, BudgetLevel.safe);
      expect(status.isSafe, isTrue);
      expect(status.spentRatio, closeTo(0.79, 0.001));
    });

    test('tepat 80% sudah masuk status siaga (aturan PRD: >= 80%)', () {
      final status = useCase.execute(
        totalExpense: 800000,
        budgetLimit: 1000000,
      );

      expect(status.level, BudgetLevel.warning);
      expect(status.isWarning, isTrue);
    });

    test('tepat 100% berstatus lewat', () {
      final status = useCase.execute(
        totalExpense: 1000000,
        budgetLimit: 1000000,
      );

      expect(status.level, BudgetLevel.exceeded);
      expect(status.isExceeded, isTrue);
    });

    test('melebihi 100% tetap lewat dengan rasio di atas 1', () {
      final status = useCase.execute(
        totalExpense: 1500000,
        budgetLimit: 1000000,
      );

      expect(status.level, BudgetLevel.exceeded);
      expect(status.spentRatio, closeTo(1.5, 0.001));
    });

    test('batas nol atau negatif dianggap aman tanpa menghitung rasio', () {
      final zero = useCase.execute(totalExpense: 50000, budgetLimit: 0);
      final negative = useCase.execute(totalExpense: 50000, budgetLimit: -100);

      expect(zero.level, BudgetLevel.safe);
      expect(zero.spentRatio, 0);
      expect(negative.level, BudgetLevel.safe);
      expect(negative.spentRatio, 0);
    });
  });
}
