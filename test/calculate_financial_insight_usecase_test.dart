import 'package:flutter_test/flutter_test.dart';

import 'package:savu/features/dashboard/domain/usecases/calculate_financial_insight_usecase.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  test('calculates monthly insight and compares previous cycle', () {
    final result = const CalculateFinancialInsightUseCase().execute(
      now: DateTime(2026, 8, 28),
      cycleDay: 25,
      period: FinancialInsightPeriod.monthly,
      transactions: [
        TransactionEntity(
          id: 'current-expense',
          amount: 300,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 8, 26),
          note: '',
        ),
        TransactionEntity(
          id: 'current-income',
          amount: 1000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 8, 27),
          note: '',
        ),
        TransactionEntity(
          id: 'previous-expense',
          amount: 500,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 8, 20),
          note: '',
        ),
      ],
    );

    expect(result.expense, 300);
    expect(result.income, 1000);
    expect(result.net, 700);
    expect(result.previousExpense, 500);
    expect(result.topCategory, 'Makanan');
    expect(result.transactionCount, 2);
    expect(result.expenseChangeRatio, -0.4);
  });

  test('calculates weekly insight without previous data', () {
    final result = const CalculateFinancialInsightUseCase().execute(
      now: DateTime(2026, 8, 28),
      period: FinancialInsightPeriod.weekly,
      transactions: [
        TransactionEntity(
          id: 'expense',
          amount: 700,
          type: TransactionType.expense,
          category: 'Kos',
          date: DateTime(2026, 8, 24),
          note: '',
        ),
      ],
    );

    expect(result.expense, 700);
    expect(result.averageDailyExpense, 100);
    expect(result.periodLabel, '7 hari terakhir');
  });
}
