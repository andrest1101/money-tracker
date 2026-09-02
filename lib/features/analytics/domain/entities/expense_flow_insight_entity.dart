import 'cash_flow_point_entity.dart';

class ExpenseFlowInsightEntity {
  const ExpenseFlowInsightEntity({
    required this.points,
    required this.totalExpense,
    required this.averageDailyExpense,
    required this.activeDays,
    required this.peakDay,
    required this.peakAmount,
    required this.recommendation,
  });

  final List<CashFlowPointEntity> points;
  final double totalExpense;
  final double averageDailyExpense;
  final int activeDays;
  final DateTime? peakDay;
  final double peakAmount;
  final String recommendation;

  int get totalDays => points.length;
}
