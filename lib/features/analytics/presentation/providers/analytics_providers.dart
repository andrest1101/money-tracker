import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../dashboard/domain/usecases/calculate_budget_cycle_period_usecase.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/cash_flow_point_entity.dart';
import '../../domain/entities/balance_trend_point_entity.dart';
import '../../domain/usecases/calculate_balance_trend_usecase.dart';
import '../../domain/usecases/calculate_cash_flow_usecase.dart';

enum CashFlowRange { sevenDays, thirtyDays, activeCycle }

class CashFlowRangeController extends Notifier<CashFlowRange> {
  @override
  CashFlowRange build() => CashFlowRange.sevenDays;

  void setRange(CashFlowRange range) => state = range;
}

final cashFlowRangeProvider =
    NotifierProvider<CashFlowRangeController, CashFlowRange>(
      CashFlowRangeController.new,
    );

final cashFlowPointsProvider = Provider<AsyncValue<List<CashFlowPointEntity>>>((
  ref,
) {
  final transactions = ref.watch(transactionsStreamProvider);
  final range = ref.watch(cashFlowRangeProvider);
  final cycleDay = ref.watch(budgetCycleDateProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final cycle = const CalculateBudgetCyclePeriodUseCase().execute(
    date: now,
    cycleDay: cycleDay,
  );
  final start = switch (range) {
    CashFlowRange.sevenDays => today.subtract(const Duration(days: 6)),
    CashFlowRange.thirtyDays => today.subtract(const Duration(days: 29)),
    CashFlowRange.activeCycle => cycle.start,
  };
  return transactions.whenData(
    (items) => const CalculateCashFlowUseCase().execute(
      transactions: items,
      start: start,
      end: today,
    ),
  );
});

final cashFlowTransactionsProvider = Provider<List<TransactionEntity>>((ref) {
  return ref.watch(transactionsStreamProvider).value ?? const [];
});

final balanceTrendPointsProvider =
    Provider<AsyncValue<List<BalanceTrendPointEntity>>>((ref) {
      final transactions = ref.watch(transactionsStreamProvider);
      final range = ref.watch(cashFlowRangeProvider);
      final cycleDay = ref.watch(budgetCycleDateProvider);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final cycle = const CalculateBudgetCyclePeriodUseCase().execute(
        date: now,
        cycleDay: cycleDay,
      );
      final start = switch (range) {
        CashFlowRange.sevenDays => today.subtract(const Duration(days: 6)),
        CashFlowRange.thirtyDays => today.subtract(const Duration(days: 29)),
        CashFlowRange.activeCycle => cycle.start,
      };
      return transactions.whenData(
        (items) => const CalculateBalanceTrendUseCase().execute(
          transactions: items,
          start: start,
          end: today,
        ),
      );
    });
