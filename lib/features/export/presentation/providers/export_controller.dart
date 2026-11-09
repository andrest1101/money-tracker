import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_message.dart';
import '../../../../core/local_storage/settings_providers.dart';
import '../../../dashboard/domain/usecases/calculate_budget_cycle_period_usecase.dart';
import '../../../savings/domain/entities/savings_goal_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../data/providers/export_repository_provider.dart';
import '../../data/repositories/export_repository_impl.dart';
import '../../domain/entities/export_options.dart';
import '../../domain/usecases/build_report_summary.dart';
import '../../domain/usecases/resolve_export_period.dart';

class ExportController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> export({
    required ExportOptions options,
    required List<TransactionEntity> transactions,
    required List<SavingsGoalEntity> goals,
    DateTime? now,
  }) async {
    if (transactions.isEmpty) return false;

    state = const AsyncLoading();
    try {
      final reference = now ?? DateTime.now();
      final cycleDay = ref.read(budgetCycleDateProvider);
      final budgetLimit = ref.read(budgetLimitProvider);
      const cycleUseCase = CalculateBudgetCyclePeriodUseCase();
      const resolvePeriod = ResolveExportPeriodUseCase();

      final period = resolvePeriod.execute(
        type: options.period,
        now: reference,
        cycleDay: cycleDay,
        customStart: options.customStart,
        customEnd: options.customEnd,
      );
      final cycle = cycleUseCase.execute(
        date: reference,
        cycleDay: cycleDay,
      );
      final summary = const BuildReportSummaryUseCase().execute(
        transactions: transactions,
        goals: goals,
        period: period,
        generatedAt: reference,
        activeCycleStart: cycle.start,
        activeCycleEnd: cycle.end,
        budgetLimit: budgetLimit,
      );

      if (!summary.hasTransactions) {
        state = const AsyncData(null);
        return false;
      }

      await ref
          .read(exportRepositoryProvider)
          .shareReport(summary: summary, options: options);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      final message = error is ExportRepositoryException
          ? error.message
          : appErrorMessage(
              error,
              fallback: 'Ekspor gagal. Coba lagi.',
            );
      state = AsyncError(message, stackTrace);
      return false;
    }
  }
}

final exportControllerProvider =
    NotifierProvider<ExportController, AsyncValue<void>>(ExportController.new);
