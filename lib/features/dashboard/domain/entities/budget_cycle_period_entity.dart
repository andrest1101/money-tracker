class BudgetCyclePeriodEntity {
  const BudgetCyclePeriodEntity({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get totalDays => end.difference(start).inDays + 1;

  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);
}
