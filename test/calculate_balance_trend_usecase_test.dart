import 'package:flutter_test/flutter_test.dart';
import 'package:savu/features/analytics/domain/usecases/calculate_balance_trend_usecase.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  const useCase = CalculateBalanceTrendUseCase();

  test('calculates cumulative balance from income and expenses', () {
    final points = useCase.execute(
      start: DateTime(2026, 8, 1),
      end: DateTime(2026, 8, 3),
      transactions: [
        TransactionEntity(
          id: 'income',
          amount: 1000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 8, 1),
          note: '',
        ),
        TransactionEntity(
          id: 'expense',
          amount: 150000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 8, 2),
          note: '',
        ),
      ],
    );

    expect(points, hasLength(3));
    expect(points[0].balance, 1000000);
    expect(points[1].balance, 850000);
    expect(points[2].balance, 850000);
  });
}
