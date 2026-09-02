import 'package:flutter_test/flutter_test.dart';
import 'package:savu/features/transactions/presentation/providers/history_providers.dart';

void main() {
  test('accepts a range of up to 31 inclusive days', () {
    final range = HistoryDateRange(
      start: DateTime(2026, 7, 1),
      end: DateTime(2026, 7, 31, 23, 59, 59),
    );

    expect(range.lengthInDays, 31);
    expect(range.isValid, isTrue);
  });

  test('rejects a range longer than 31 days', () {
    final range = HistoryDateRange(
      start: DateTime(2026, 7, 1),
      end: DateTime(2026, 8, 1, 23, 59, 59),
    );

    expect(range.lengthInDays, 32);
    expect(range.isValid, isFalse);
  });
}
