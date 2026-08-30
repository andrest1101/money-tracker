import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:money_tracker/features/transactions/domain/usecases/filter_transactions_usecase.dart';

void main() {
  const useCase = FilterTransactionsUseCase();

  final transactions = [
    TransactionEntity(
      id: 'food',
      amount: 50000,
      type: TransactionType.expense,
      category: 'Makanan',
      date: DateTime(2026, 8, 28),
      note: 'Makan siang',
    ),
    TransactionEntity(
      id: 'income',
      amount: 500000,
      type: TransactionType.income,
      category: 'Uang Kiriman',
      date: DateTime(2026, 8, 27),
      note: '',
    ),
    TransactionEntity(
      id: 'shopping',
      amount: 100000,
      type: TransactionType.expense,
      category: 'Belanja',
      date: DateTime(2026, 7, 20),
      note: 'Kebutuhan kos',
    ),
  ];

  test('filters by category and type together', () {
    final result = useCase.execute(
      transactions: transactions,
      type: TransactionType.expense,
      category: 'Makanan',
    );

    expect(result.map((transaction) => transaction.id), ['food']);
  });

  test('filters by search query in note', () {
    final result = useCase.execute(
      transactions: transactions,
      query: 'kebutuhan',
    );

    expect(result.map((transaction) => transaction.id), ['shopping']);
  });

  test('filters only transactions inside the active cycle', () {
    final result = useCase.execute(
      transactions: transactions,
      cycleStart: DateTime(2026, 8, 25),
      cycleEnd: DateTime(2026, 9, 24, 23, 59, 59),
    );

    expect(result.map((transaction) => transaction.id), ['food', 'income']);
  });
}
