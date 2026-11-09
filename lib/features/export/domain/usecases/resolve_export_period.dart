import '../../../dashboard/domain/usecases/calculate_budget_cycle_period_usecase.dart';
import '../entities/export_options.dart';
import '../entities/export_period.dart';

/// Mengubah pilihan periode UI menjadi rentang tanggal yang pasti.
class ResolveExportPeriodUseCase {
  const ResolveExportPeriodUseCase();

  static const _calculateCycle = CalculateBudgetCyclePeriodUseCase();

  ExportPeriod execute({
    required ExportPeriodType type,
    required DateTime now,
    required int cycleDay,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final today = DateTime(now.year, now.month, now.day);

    switch (type) {
      case ExportPeriodType.allTime:
        return const ExportPeriod(
          label: 'Semua waktu',
          isAllTime: true,
        );
      case ExportPeriodType.thisMonth:
        return ExportPeriod(
          start: DateTime(today.year, today.month),
          end: DateTime(today.year, today.month + 1, 0),
          label: 'Bulan ini',
          isAllTime: false,
        );
      case ExportPeriodType.activeCycle:
        final cycle = _calculateCycle.execute(date: today, cycleDay: cycleDay);
        return ExportPeriod(
          start: _dateOnly(cycle.start),
          end: _dateOnly(cycle.end),
          label: 'Siklus anggaran aktif',
          isAllTime: false,
        );
      case ExportPeriodType.custom:
        if (customStart == null || customEnd == null) {
          throw ArgumentError(
            'Periode kustom membutuhkan tanggal awal dan akhir.',
          );
        }
        final first = _dateOnly(customStart);
        final second = _dateOnly(customEnd);
        return ExportPeriod(
          start: first.isBefore(second) ? first : second,
          end: first.isBefore(second) ? second : first,
          label: 'Rentang tanggal',
          isAllTime: false,
        );
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
