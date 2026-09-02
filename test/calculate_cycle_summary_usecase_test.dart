import 'package:flutter_test/flutter_test.dart';
import 'package:savu/features/dashboard/domain/usecases/calculate_category_expenses_usecase.dart';
import 'package:savu/features/dashboard/domain/usecases/calculate_monthly_summary_usecase.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  final transactions = [
    TransactionEntity(
      id: 'before',
      amount: 100000,
      type: TransactionType.expense,
      category: 'Makanan',
      date: DateTime(2026, 1, 24, 23, 59),
      note: '',
    ),
    TransactionEntity(
      id: 'start',
      amount: 200000,
      type: TransactionType.expense,
      category: 'Makanan',
      date: DateTime(2026, 1, 25),
      note: '',
    ),
    TransactionEntity(
      id: 'end',
      amount: 300000,
      type: TransactionType.income,
      category: 'Beasiswa',
      date: DateTime(2026, 2, 24, 23, 59),
      note: '',
    ),
    TransactionEntity(
      id: 'after',
      amount: 400000,
      type: TransactionType.expense,
      category: 'Belanja',
      date: DateTime(2026, 2, 25),
      note: '',
    ),
  ];

  test('summary includes both months in a 25-to-24 cycle', () {
    final summary = const CalculateMonthlySummaryUseCase().execute(
      transactions: transactions,
      periodStart: DateTime(2026, 1, 25),
      periodEnd: DateTime(2026, 2, 24, 23, 59, 59, 999),
    );

    expect(summary.totalExpense, 200000);
    expect(summary.totalIncome, 300000);
    expect(summary.transactionCount, 2);
  });

  test('category totals use the same inclusive cycle range', () {
    final categories = const CalculateCategoryExpensesUseCase().execute(
      transactions: transactions,
      periodStart: DateTime(2026, 1, 25),
      periodEnd: DateTime(2026, 2, 24, 23, 59, 59, 999),
    );

    expect(categories, hasLength(1));
    expect(categories.single.category, 'Makanan');
    expect(categories.single.amount, 200000);
  });
}
