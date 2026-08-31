import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/balance_trend_point_entity.dart';

class CalculateBalanceTrendUseCase {
  const CalculateBalanceTrendUseCase();

  List<BalanceTrendPointEntity> execute({
    required List<TransactionEntity> transactions,
    required DateTime start,
    required DateTime end,
  }) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    if (endDay.isBefore(startDay)) return const [];

    final dailyNet = <DateTime, double>{};
    for (
      var day = startDay;
      !day.isAfter(endDay);
      day = day.add(const Duration(days: 1))
    ) {
      dailyNet[day] = 0;
    }
    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (!dailyNet.containsKey(day)) continue;
      final net = transaction.isExpense
          ? -transaction.amount
          : transaction.amount;
      dailyNet[day] = dailyNet[day]! + net;
    }

    var balance = 0.0;
    return dailyNet.entries.map((entry) {
      balance += entry.value;
      return BalanceTrendPointEntity(date: entry.key, balance: balance);
    }).toList();
  }
}
