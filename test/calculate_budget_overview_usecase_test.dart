import 'package:flutter_test/flutter_test.dart';
import 'package:savu/features/dashboard/domain/entities/budget_status_entity.dart';
import 'package:savu/features/dashboard/domain/usecases/calculate_budget_overview_usecase.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  const useCase = CalculateBudgetOverviewUseCase();

  test('menghitung overview berdasarkan siklus tanggal berjalan', () {
    final overview = useCase.execute(
      now: DateTime(2026, 8, 27),
      cycleDay: 25,
      budgetLimit: 3000000,
      transactions: [
        TransactionEntity(
          id: '1',
          amount: 500000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 8, 26),
          note: '',
        ),
        TransactionEntity(
          id: '2',
          amount: 250000,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 8, 27),
          note: '',
        ),
        TransactionEntity(
          id: '3',
          amount: 2000000,
          type: TransactionType.income,
          category: 'Beasiswa',
          date: DateTime(2026, 8, 26),
          note: '',
        ),
      ],
    );

    expect(overview.periodStart, DateTime(2026, 8, 25));
    expect(overview.periodEnd, DateTime(2026, 9, 24));
    expect(overview.totalExpense, 750000);
    expect(overview.remaining, 2250000);
    expect(overview.level, BudgetLevel.safe);
    expect(overview.transactionCount, 2);
    expect(overview.topCategories.first.category, 'Makanan');
    expect(overview.projectedExpense, closeTo(7750000, 0.01));
  });

  test(
    'menandai anggaran terlampaui dan mengabaikan transaksi di luar periode',
    () {
      final overview = useCase.execute(
        now: DateTime(2026, 8, 10),
        cycleDay: 1,
        budgetLimit: 1000000,
        transactions: [
          TransactionEntity(
            id: '1',
            amount: 1200000,
            type: TransactionType.expense,
            category: 'Belanja',
            date: DateTime(2026, 8, 10),
            note: '',
          ),
          TransactionEntity(
            id: '2',
            amount: 900000,
            type: TransactionType.expense,
            category: 'Lainnya',
            date: DateTime(2026, 7, 31),
            note: '',
          ),
        ],
      );

      expect(overview.totalExpense, 1200000);
      expect(overview.remaining, -200000);
      expect(overview.level, BudgetLevel.exceeded);
    },
  );
}
