import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/cash_flow_point_entity.dart';

class CalculateCashFlowUseCase {
  const CalculateCashFlowUseCase();

  List<CashFlowPointEntity> execute({
    required List<TransactionEntity> transactions,
    required DateTime start,
    required DateTime end,
  }) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    if (endDay.isBefore(startDay)) return const [];

    final totals = <DateTime, ({double income, double expense})>{};
    for (
      var day = startDay;
      !day.isAfter(endDay);
      day = day.add(const Duration(days: 1))
    ) {
      totals[day] = (income: 0, expense: 0);
    }

    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      final current = totals[day];
      if (current == null) continue;
      totals[day] = transaction.isExpense
          ? (
              income: current.income,
              expense: current.expense + transaction.amount,
            )
          : (
              income: current.income + transaction.amount,
              expense: current.expense,
            );
    }

    return totals.entries
        .map(
          (entry) => CashFlowPointEntity(
            date: entry.key,
            income: entry.value.income,
            expense: entry.value.expense,
          ),
        )
        .toList();
  }
}
