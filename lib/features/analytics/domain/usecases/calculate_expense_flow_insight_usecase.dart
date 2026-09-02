import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/cash_flow_point_entity.dart';
import '../entities/expense_flow_insight_entity.dart';

class CalculateExpenseFlowInsightUseCase {
  const CalculateExpenseFlowInsightUseCase();

  ExpenseFlowInsightEntity execute({
    required List<TransactionEntity> transactions,
    required DateTime start,
    required DateTime end,
  }) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    if (endDay.isBefore(startDay)) {
      return const ExpenseFlowInsightEntity(
        points: [],
        totalExpense: 0,
        averageDailyExpense: 0,
        activeDays: 0,
        peakDay: null,
        peakAmount: 0,
        recommendation: 'Belum ada data pengeluaran untuk dianalisis.',
      );
    }

    final totals = <DateTime, double>{};
    for (
      var day = startDay;
      !day.isAfter(endDay);
      day = day.add(const Duration(days: 1))
    ) {
      totals[day] = 0;
    }
    for (final transaction in transactions) {
      if (!transaction.isExpense) {
        continue;
      }
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (totals.containsKey(day)) {
        totals[day] = totals[day]! + transaction.amount;
      }
    }

    final points = totals.entries
        .map(
          (entry) => CashFlowPointEntity(
            date: entry.key,
            income: 0,
            expense: entry.value,
          ),
        )
        .toList();
    final total = points.fold<double>(0, (sum, point) => sum + point.expense);
    final activeDays = points.where((point) => point.expense > 0).length;
    final peak = points.fold<CashFlowPointEntity?>(null, (current, point) {
      if (point.expense <= 0) return current;
      return current == null || point.expense > current.expense
          ? point
          : current;
    });

    final recommendation = total == 0
        ? 'Belum ada pengeluaran. Pertahankan kebiasaan mencatat agar pola keuanganmu tetap terpantau.'
        : activeDays == 1
        ? 'Sebagian besar pengeluaran terjadi dalam satu hari. Periksa transaksi pada hari tersebut agar tidak melewati batas harian.'
        : peak != null && peak.expense >= total * .5
        ? 'Pengeluaran terbesar menyumbang lebih dari separuh total. Pertimbangkan membagi kebutuhan besar ke dalam rencana anggaran.'
        : 'Pola pengeluaranmu tersebar. Tetapkan batas harian agar pengeluaran tetap terkendali.';

    return ExpenseFlowInsightEntity(
      points: points,
      totalExpense: total,
      averageDailyExpense: total / points.length,
      activeDays: activeDays,
      peakDay: peak?.date,
      peakAmount: peak?.expense ?? 0,
      recommendation: recommendation,
    );
  }
}
