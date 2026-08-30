import 'package:flutter_test/flutter_test.dart';

import 'package:money_tracker/features/savings/domain/usecases/calculate_allocation_summary_usecase.dart';
import 'package:money_tracker/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  test('summarizes allocation amount, count, and latest transaction', () {
    final summary = const CalculateAllocationSummaryUseCase().execute([
      TransactionEntity(
        id: 'old',
        amount: 100,
        type: TransactionType.expense,
        category: 'Alokasi Tabungan',
        date: DateTime(2026, 1, 1),
        note: '',
      ),
      TransactionEntity(
        id: 'new',
        amount: 250,
        type: TransactionType.expense,
        category: 'Alokasi Tabungan',
        date: DateTime(2026, 1, 2),
        note: '',
      ),
    ]);

    expect(summary.totalAmount, 350);
    expect(summary.count, 2);
    expect(summary.latest?.id, 'new');
  });
}
