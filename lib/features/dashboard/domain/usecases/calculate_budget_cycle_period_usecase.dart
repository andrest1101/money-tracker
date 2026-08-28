import '../entities/budget_cycle_period_entity.dart';

class CalculateBudgetCyclePeriodUseCase {
  const CalculateBudgetCyclePeriodUseCase();

  BudgetCyclePeriodEntity execute({
    required DateTime date,
    required int cycleDay,
  }) {
    final start = _periodStart(date, cycleDay);
    final next = DateTime(start.year, start.month + 1);
    final end = DateTime(
      next.year,
      next.month,
      _validDay(next.year, next.month, cycleDay),
    ).subtract(const Duration(days: 1));
    return BudgetCyclePeriodEntity(start: start, end: end);
  }

  DateTime _periodStart(DateTime date, int cycleDay) {
    final day = cycleDay.clamp(1, 31);
    if (date.day >= day) {
      return DateTime(
        date.year,
        date.month,
        _validDay(date.year, date.month, day),
      );
    }
    final previous = DateTime(date.year, date.month - 1);
    return DateTime(
      previous.year,
      previous.month,
      _validDay(previous.year, previous.month, day),
    );
  }

  int _validDay(int year, int month, int requested) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return requested.clamp(1, lastDay);
  }
}
