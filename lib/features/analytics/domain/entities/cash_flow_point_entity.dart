class CashFlowPointEntity {
  const CashFlowPointEntity({
    required this.date,
    required this.income,
    required this.expense,
  });

  final DateTime date;
  final double income;
  final double expense;

  double get net => income - expense;
  bool get hasActivity => income > 0 || expense > 0;
}
