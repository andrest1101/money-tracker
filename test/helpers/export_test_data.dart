import 'dart:io';

import 'package:savu/features/export/domain/entities/export_period.dart';
import 'package:savu/features/export/domain/entities/report_summary.dart';
import 'package:savu/features/export/domain/usecases/build_report_summary.dart';
import 'package:savu/features/savings/domain/entities/savings_goal_entity.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';

final exportTestGeneratedAt = DateTime(2026, 11, 9, 10, 30);
final exportTestCycleStart = DateTime(2026, 11, 1);
final exportTestCycleEnd = DateTime(2026, 11, 30);

const exportTestAllTimePeriod = ExportPeriod(
  label: 'Semua waktu',
  isAllTime: true,
);

ExportPeriod exportTestRange(DateTime start, DateTime end) {
  return ExportPeriod(
    start: start,
    end: end,
    label: 'Rentang tanggal',
    isAllTime: false,
  );
}

List<TransactionEntity> loadExportFixtureTransactions() {
  final lines = File(
    'test/fixtures/export_sample_v1.csv',
  ).readAsLinesSync();
  return lines
      .skip(1)
      .where((line) => line.trim().isNotEmpty)
      .map(transactionFromFixtureLine)
      .toList();
}

TransactionEntity transactionFromFixtureLine(String line) {
  final cells = line.split(',');
  return TransactionEntity(
    id: cells[0],
    date: DateTime.parse(cells[1]),
    type: cells[2] == 'income'
        ? TransactionType.income
        : TransactionType.expense,
    category: cells[3],
    amount: double.parse(cells[4]),
    note: cells.length > 5 ? cells[5] : '',
  );
}

List<SavingsGoalEntity> exportTestGoals() {
  return [
    exportTestGoal(
      id: 'goal-mouse',
      title: 'Mouse',
      targetAmount: 1500000,
      currentAmount: 1000000,
      deadline: DateTime(2026, 12, 31),
    ),
    exportTestGoal(
      id: 'goal-laptop',
      title: 'Laptop',
      targetAmount: 8000000,
      currentAmount: 560000,
      deadline: DateTime(2027, 6, 30),
    ),
    exportTestGoal(
      id: 'goal-emergency',
      title: 'Dana Darurat',
      targetAmount: 5000000,
      currentAmount: 415000,
      deadline: DateTime(2027, 1, 31),
    ),
  ];
}

ReportSummary buildExportTestSummary(
  List<TransactionEntity>? transactions, {
  List<SavingsGoalEntity>? goals,
  ExportPeriod period = exportTestAllTimePeriod,
  double? budgetLimit,
}) {
  return const BuildReportSummaryUseCase().execute(
    transactions: transactions ?? loadExportFixtureTransactions(),
    goals: goals ?? exportTestGoals(),
    period: period,
    generatedAt: exportTestGeneratedAt,
    activeCycleStart: exportTestCycleStart,
    activeCycleEnd: exportTestCycleEnd,
    budgetLimit: budgetLimit,
  );
}

SavingsGoalEntity exportTestGoal({
  required String id,
  required String title,
  required double targetAmount,
  required double currentAmount,
  DateTime? deadline,
  DateTime? createdAt,
  bool isArchived = false,
}) {
  return SavingsGoalEntity(
    id: id,
    title: title,
    targetAmount: targetAmount,
    currentAmount: currentAmount,
    deadline: deadline ?? DateTime(2027, 1, 31),
    createdAt: createdAt ?? DateTime(2026, 8, 1),
    isArchived: isArchived,
  );
}
