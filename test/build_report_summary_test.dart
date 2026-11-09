import 'package:flutter_test/flutter_test.dart';

import 'package:savu/features/export/domain/entities/export_options.dart';
import 'package:savu/features/export/domain/entities/goal_progress.dart';
import 'package:savu/features/export/domain/entities/report_transaction_row.dart';
import 'package:savu/features/export/domain/usecases/resolve_export_period.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';

import 'helpers/export_test_data.dart';

void main() {
  group('BuildReportSummaryUseCase', () {
    test('menghitung seluruh metrik periode penuh sesuai data uji', () {
      final summary = buildExportTestSummary(loadExportFixtureTransactions());

      expect(summary.transactionCount, 43);
      expect(summary.periodStart, DateTime(2026, 8, 29));
      expect(summary.periodEnd, DateTime(2026, 11, 8));
      expect(summary.daysInPeriod, 72);
      expect(summary.daysWithRecords, 10);
      expect(summary.openingBalance, 0);
      expect(summary.totalIncome, 12725000);
      expect(summary.totalExpense, 2002000);
      expect(summary.totalSavings, 2215000);
      expect(summary.netChange, 8508000);
      expect(summary.endingBalance, 8508000);
      expect(
        summary.savingsRate,
        closeTo(2215000 / 12725000, 0.0000001),
      );
      expect(
        summary.averageExpensePerDay,
        closeTo(2002000 / 72, 0.0000001),
      );
      expect(summary.activeCycleBalance, 870000);
      expect(summary.activeCycleStart, exportTestCycleStart);
      expect(summary.activeCycleEnd, exportTestCycleEnd);
    });

    test('mengurutkan transaksi terlama ke terbaru dan menghitung saldo', () {
      final summary = buildExportTestSummary(loadExportFixtureTransactions());

      expect(summary.transactions.first.id, '1794147328405701');
      expect(summary.transactions.first.runningBalance, 5000000);
      expect(summary.transactions.last.id, '1794147328405743');
      expect(summary.transactions.last.runningBalance, 8508000);
      expect(
        summary.transactions.map((row) => row.date).toList(),
        orderedEquals(
          [...summary.transactions.map((row) => row.date)]
            ..sort((a, b) => a.compareTo(b)),
        ),
      );
    });

    test('memisahkan tabungan dari pengeluaran dan kategori terbesar', () {
      final summary = buildExportTestSummary(loadExportFixtureTransactions());

      expect(summary.expenseCategories, isNotEmpty);
      expect(summary.expenseCategories.first.category, 'Belanja');
      expect(summary.expenseCategories.first.total, 730000);
      expect(
        summary.expenseCategories.first.share,
        closeTo(730000 / 2002000, 0.0000001),
      );
      expect(summary.expenseCategories[1].category, 'Kos & Tagihan');
      expect(summary.expenseCategories[1].total, 700000);
      expect(
        summary.expenseCategories.any(
          (category) => category.category == 'Alokasi Tabungan',
        ),
        isFalse,
      );
      expect(summary.largestExpenseCategory?.category, 'Belanja');
      expect(summary.largestExpenseTransaction?.category, 'Kos & Tagihan');
      expect(summary.largestExpenseTransaction?.amount, 350000);
      expect(summary.largestExpenseTransaction?.date, DateTime(2026, 9, 1, 7));
    });

    test('menghitung baris bulanan dan tetap menampilkan bulan kosong', () {
      final summary = buildExportTestSummary(loadExportFixtureTransactions());

      expect(summary.months.length, 4);
      expect(
        summary.months.map((month) => '${month.year}-${month.month}'),
        ['2026-8', '2026-9', '2026-10', '2026-11'],
      );

      final august = summary.months[0];
      expect(august.income, 5000000);
      expect(august.expense, 375000);
      expect(august.savings, 700000);
      expect(august.net, 3925000);
      expect(august.transactionCount, 11);

      final september = summary.months[1];
      expect(september.income, 5725000);
      expect(september.expense, 977000);
      expect(september.savings, 1035000);
      expect(september.net, 3713000);
      expect(september.transactionCount, 20);

      final october = summary.months[2];
      expect(october.income, 0);
      expect(october.expense, 0);
      expect(october.savings, 0);
      expect(october.transactionCount, 0);

      final november = summary.months[3];
      expect(november.income, 2000000);
      expect(november.expense, 650000);
      expect(november.savings, 480000);
      expect(november.net, 870000);
      expect(november.transactionCount, 12);
    });

    test('mencocokkan target lewat catatan lama dan menandai yang tidak cocok', () {
      final summary = buildExportTestSummary(loadExportFixtureTransactions());
      final savingsRows = summary.transactions
          .where((row) => row.kind == ReportTransactionKind.savings)
          .toList();

      expect(savingsRows.length, 25);
      expect(
        savingsRows.where((row) => row.targetName == 'Mouse').length,
        10,
      );
      expect(
        savingsRows.where((row) => row.targetName == 'Laptop').length,
        7,
      );
      expect(
        savingsRows.where((row) => row.targetName == 'Dana Darurat').length,
        5,
      );
      expect(
        savingsRows.where((row) => row.targetName == '(Tidak tercatat)').length,
        3,
      );
      expect(summary.unmatchedAllocationCount, 3);
      expect(summary.unmatchedAllocationAmount, 240000);
    });

    test('goalId menjadi penanda utama meskipun catatan berbeda', () {
      final goal = exportTestGoals().first;
      final transaction = TransactionEntity(
        id: 'goal-id-primary',
        amount: 125000,
        type: TransactionType.expense,
        category: 'Alokasi Tabungan',
        date: DateTime(2026, 11, 2, 20),
        note: 'catatan bebas tanpa nama target',
        goalId: goal.id,
      );

      final summary = buildExportTestSummary([transaction]);

      expect(summary.transactions.single.targetName, 'Mouse');
      expect(summary.transactions.single.targetGoalId, goal.id);
      expect(summary.unmatchedAllocationCount, 0);
    });

    test('menghitung saldo awal untuk ekspor periode terfilter', () {
      final summary = buildExportTestSummary(
        loadExportFixtureTransactions(),
        period: exportTestRange(DateTime(2026, 11, 1), DateTime(2026, 11, 8)),
      );

      expect(summary.openingBalance, 7638000);
      expect(summary.totalIncome, 2000000);
      expect(summary.totalExpense, 650000);
      expect(summary.totalSavings, 480000);
      expect(summary.netChange, 870000);
      expect(summary.endingBalance, 8508000);
      expect(summary.transactionCount, 12);
      expect(summary.dataStart, DateTime(2026, 11, 1));
      expect(summary.dataEnd, DateTime(2026, 11, 8));
      expect(summary.transactions.first.runningBalance, 7638000 - 350000);
    });

    test('menghitung progress target dan alokasi di dalam periode', () {
      final summary = buildExportTestSummary(loadExportFixtureTransactions());

      expect(summary.goals.length, 3);
      final mouse = summary.goals.firstWhere((goal) => goal.title == 'Mouse');
      expect(mouse.currentAmount, 1000000);
      expect(mouse.targetAmount, 1500000);
      expect(mouse.progress, closeTo(2 / 3, 0.0000001));
      expect(mouse.allocatedInPeriod, 1000000);
      expect(mouse.allocationCountInPeriod, 10);
      expect(mouse.status, GoalStatus.active);
      expect(mouse.daysRemaining, greaterThanOrEqualTo(0));

      final laptop = summary.goals.firstWhere(
        (goal) => goal.title == 'Laptop',
      );
      expect(laptop.allocatedInPeriod, 560000);
      expect(laptop.allocationCountInPeriod, 7);

      final emergency = summary.goals.firstWhere(
        (goal) => goal.title == 'Dana Darurat',
      );
      expect(emergency.allocatedInPeriod, 415000);
      expect(emergency.allocationCountInPeriod, 5);
    });

    test('membuat insight deterministik sesuai kondisi data', () {
      final summary = buildExportTestSummary(loadExportFixtureTransactions());

      expect(
        summary.insights,
        contains(
          'Kamu menabung 17,4% dari pemasukan periode ini.',
        ),
      );
      expect(
        summary.insights,
        contains(
          'Pengeluaran terbesarmu ada di Belanja: Rp 730.000 '
          '(36,5% dari pengeluaran).',
        ),
      );
      expect(
        summary.insights,
        contains('Rata-rata kamu mengeluarkan Rp 27.806 per hari.'),
      );
      expect(
        summary.insights,
        contains(
          'Tidak ada catatan di Okt 2026. '
          'Pencatatan yang rutin bikin angka ini lebih akurat.',
        ),
      );
      expect(
        summary.insights,
        contains(
          '3 alokasi tabungan belum punya nama target, '
          'jadi tidak bisa dihitung per target.',
        ),
      );
    });

    test('menambahkan insight anggaran hanya saat pemakaian minimal 80%', () {
      final withoutBudget = buildExportTestSummary(loadExportFixtureTransactions());
      expect(
        withoutBudget.insights.any(
          (insight) => insight.contains('batas anggaranmu'),
        ),
        isFalse,
      );

      final withBudget = buildExportTestSummary(
        loadExportFixtureTransactions(),
        budgetLimit: 800000,
      );
      expect(
        withBudget.insights,
        contains(
          'Pengeluaran bulan ini sudah 81,3% dari batas anggaranmu.',
        ),
      );
    });

    test('tetap aman saat data kosong', () {
      final summary = buildExportTestSummary(const []);

      expect(summary.transactionCount, 0);
      expect(summary.endingBalance, 0);
      expect(summary.months.length, 1);
      expect(summary.transactions, isEmpty);
      expect(summary.expenseCategories, isEmpty);
      expect(summary.insights, isEmpty);
    });

    test('memetakan status target aktif, selesai, dan diarsipkan', () {
      final goals = [
        exportTestGoal(
          id: 'active',
          title: 'Aktif',
          targetAmount: 1000000,
          currentAmount: 250000,
        ),
        exportTestGoal(
          id: 'completed',
          title: 'Selesai',
          targetAmount: 500000,
          currentAmount: 500000,
        ),
        exportTestGoal(
          id: 'archived',
          title: 'Arsip',
          targetAmount: 750000,
          currentAmount: 100000,
          isArchived: true,
        ),
      ];

      final summary = buildExportTestSummary(
        loadExportFixtureTransactions(),
        goals: goals,
      );

      expect(summary.goals[0].status, GoalStatus.active);
      expect(summary.goals[1].status, GoalStatus.completed);
      expect(summary.goals[2].status, GoalStatus.archived);
    });
  });

  group('ResolveExportPeriodUseCase', () {
    const resolver = ResolveExportPeriodUseCase();

    test('semua waktu tidak membatasi tanggal', () {
      final period = resolver.execute(
        type: ExportPeriodType.allTime,
        now: exportTestGeneratedAt,
        cycleDay: 1,
      );

      expect(period.isAllTime, isTrue);
      expect(period.start, isNull);
      expect(period.end, isNull);
      expect(period.label, 'Semua waktu');
    });

    test('bulan ini memakai awal dan akhir bulan', () {
      final period = resolver.execute(
        type: ExportPeriodType.thisMonth,
        now: exportTestGeneratedAt,
        cycleDay: 1,
      );

      expect(period.start, DateTime(2026, 11, 1));
      expect(period.end, DateTime(2026, 11, 30));
    });

    test('siklus aktif mengikuti tanggal siklus anggaran', () {
      final period = resolver.execute(
        type: ExportPeriodType.activeCycle,
        now: exportTestGeneratedAt,
        cycleDay: 25,
      );

      expect(period.start, DateTime(2026, 10, 25));
      expect(period.end, DateTime(2026, 11, 24));
    });

    test('rentang kustom diurutkan dan tanggalnya dinormalisasi', () {
      final period = resolver.execute(
        type: ExportPeriodType.custom,
        now: exportTestGeneratedAt,
        cycleDay: 1,
        customStart: DateTime(2026, 11, 8, 22),
        customEnd: DateTime(2026, 11, 1, 7),
      );

      expect(period.start, DateTime(2026, 11, 1));
      expect(period.end, DateTime(2026, 11, 8));
    });

    test('rentang kustom tanpa tanggal ditolak', () {
      expect(
        () => resolver.execute(
          type: ExportPeriodType.custom,
          now: exportTestGeneratedAt,
          cycleDay: 1,
        ),
        throwsArgumentError,
      );
    });
  });
}
