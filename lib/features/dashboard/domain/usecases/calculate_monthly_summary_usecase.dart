import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/monthly_summary_entity.dart';

class CalculateMonthlySummaryUseCase {
  const CalculateMonthlySummaryUseCase();

  MonthlySummaryEntity execute({
    required List<TransactionEntity> transactions,
    required DateTime month,
  }) {
    var totalIncome = 0.0;
    var totalExpense = 0.0;
    var transactionCount = 0;

    for (final transaction in transactions) {
      final isSameMonth = transaction.date.year == month.year &&
          transaction.date.month == month.month;
      if (!isSameMonth) continue;

      transactionCount++;
      if (transaction.isExpense) {
        totalExpense += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    return MonthlySummaryEntity(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      transactionCount: transactionCount,
    );
  }
}
