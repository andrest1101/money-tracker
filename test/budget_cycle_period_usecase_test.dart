import 'package:flutter_test/flutter_test.dart';

import 'package:money_tracker/features/dashboard/domain/usecases/calculate_budget_cycle_period_usecase.dart';

void main() {
  test('calculates cycle across month boundary', () {
    final period = const CalculateBudgetCyclePeriodUseCase().execute(
      date: DateTime(2026, 9, 2),
      cycleDay: 25,
    );

    expect(period.start, DateTime(2026, 8, 25));
    expect(period.end, DateTime(2026, 9, 24));
    expect(period.contains(DateTime(2026, 9, 2)), isTrue);
  });
}
