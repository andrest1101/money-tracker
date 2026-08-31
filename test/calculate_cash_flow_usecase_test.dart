import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/analytics/domain/usecases/calculate_cash_flow_usecase.dart';
import 'package:money_tracker/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  const useCase = CalculateCashFlowUseCase();

  test('aggregates income and expense by day inclusively', () {
    final points = useCase.execute(
      start: DateTime(2026, 8, 1),
      end: DateTime(2026, 8, 3, 23, 59),
      transactions: [
        TransactionEntity(
          id: 'income',
          amount: 1000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 8, 1, 8),
          note: '',
        ),
        TransactionEntity(
          id: 'expense',
          amount: 150000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 8, 3, 21),
          note: '',
        ),
        TransactionEntity(
          id: 'outside',
          amount: 900000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 8, 4),
          note: '',
        ),
      ],
    );

    expect(points, hasLength(3));
    expect(points[0].income, 1000000);
    expect(points[0].expense, 0);
    expect(points[1].hasActivity, isFalse);
    expect(points[2].expense, 150000);
  });

  test('returns an empty list for an invalid range', () {
    final points = useCase.execute(
      transactions: const [],
      start: DateTime(2026, 8, 3),
      end: DateTime(2026, 8, 1),
    );

    expect(points, isEmpty);
  });
}
