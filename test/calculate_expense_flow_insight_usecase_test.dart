import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/analytics/domain/usecases/calculate_expense_flow_insight_usecase.dart';
import 'package:money_tracker/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  const useCase = CalculateExpenseFlowInsightUseCase();

  test('summarizes expenses and identifies the peak day', () {
    final insight = useCase.execute(
      start: DateTime(2026, 8, 1),
      end: DateTime(2026, 8, 3),
      transactions: [
        TransactionEntity(
          id: 'one',
          amount: 100000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 8, 1),
          note: '',
        ),
        TransactionEntity(
          id: 'two',
          amount: 500000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 8, 3),
          note: '',
        ),
      ],
    );

    expect(insight.totalExpense, 600000);
    expect(insight.averageDailyExpense, 200000);
    expect(insight.activeDays, 2);
    expect(insight.peakDay, DateTime(2026, 8, 3));
    expect(insight.peakAmount, 500000);
    expect(insight.recommendation, isNotEmpty);
  });
}
