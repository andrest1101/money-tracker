import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/finance_categories.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../savings/domain/entities/savings_goal_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/category_total.dart';
import '../entities/export_period.dart';
import '../entities/goal_progress.dart';
import '../entities/monthly_total.dart';
import '../entities/report_summary.dart';
import '../entities/report_transaction_row.dart';

/// Menghitung seluruh angka dan insight laporan satu kali di Domain.
///
/// Use case ini Dart murni: tidak mengakses Flutter, Firestore, atau file.
class BuildReportSummaryUseCase {
  const BuildReportSummaryUseCase();

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  ReportSummary execute({
    required List<TransactionEntity> transactions,
    required List<SavingsGoalEntity> goals,
    required ExportPeriod period,
    required DateTime generatedAt,
    required DateTime activeCycleStart,
    required DateTime activeCycleEnd,
    double? budgetLimit,
  }) {
    assert(
      period.isAllTime || (period.start != null && period.end != null),
      'ExportPeriod non-all-time wajib memiliki start dan end.',
    );

    final sorted = List<TransactionEntity>.from(transactions)
      ..sort(_compareTransactions);
    final generatedDate = _dateOnly(generatedAt);
    final cycleStart = _dateOnly(activeCycleStart);
    final cycleEnd = _dateOnly(activeCycleEnd);

    final activeCycleBalance = _balanceForRange(
      sorted,
      cycleStart,
      cycleEnd,
    );
    final activeCycleExpense = _expenseForRange(
      sorted,
      cycleStart,
      cycleEnd,
    );

    late DateTime periodStart;
    late DateTime periodEnd;
    if (period.isAllTime) {
      if (sorted.isEmpty) {
        periodStart = generatedDate;
        periodEnd = generatedDate;
      } else {
        periodStart = _dateOnly(sorted.first.date);
        periodEnd = _dateOnly(sorted.last.date);
      }
    } else {
      periodStart = _dateOnly(period.start!);
      periodEnd = _dateOnly(period.end!);
      if (periodEnd.isBefore(periodStart)) {
        final temporary = periodStart;
        periodStart = periodEnd;
        periodEnd = temporary;
      }
    }

    final goalsById = <String, SavingsGoalEntity>{
      for (final goal in goals) goal.id: goal,
    };
    final goalsByTitle = <String, SavingsGoalEntity>{};
    for (final goal in goals) {
      goalsByTitle.putIfAbsent(_normalizeTitle(goal.title), () => goal);
    }

    _GoalMatch? matchGoal(TransactionEntity transaction) {
      final goalId = transaction.goalId;
      if (goalId != null) {
        final goal = goalsById[goalId];
        if (goal != null) return _GoalMatch(goal.id, goal.title);
      }

      final note = transaction.note.trim();
      if (note.isEmpty) return null;

      final normalizedNote = _normalizeTitle(note);
      final withoutPrefix = _stripAllocationPrefix(note);
      final normalizedWithoutPrefix = _normalizeTitle(withoutPrefix);
      final goal =
          goalsByTitle[normalizedWithoutPrefix] ??
          goalsByTitle[normalizedNote];
      if (goal == null) return null;
      return _GoalMatch(goal.id, goal.title);
    }

    final included = sorted.where((transaction) {
      final date = _dateOnly(transaction.date);
      return !date.isBefore(periodStart) && !date.isAfter(periodEnd);
    }).toList();

    var openingBalance = 0;
    if (!period.isAllTime) {
      for (final transaction in sorted) {
        if (_dateOnly(transaction.date).isBefore(periodStart)) {
          openingBalance += _signedAmount(transaction);
        }
      }
    }

    var runningBalance = openingBalance;
    var totalIncome = 0;
    var totalExpense = 0;
    var totalSavings = 0;
    var unmatchedAllocationCount = 0;
    var unmatchedAllocationAmount = 0;

    final rows = <ReportTransactionRow>[];
    final recordDays = <int>{};
    final expenseCategories = <String, _CategoryBucket>{};
    final incomeCategories = <String, _CategoryBucket>{};
    final monthlyBuckets = <int, _MonthBucket>{};
    final allocationsByGoal = <String, _AllocationBucket>{};
    ReportTransactionRow? largestExpenseTransaction;

    for (final transaction in included) {
      final amount = transaction.amount.round();
      final kind = _kindOf(transaction);
      final date = _dateOnly(transaction.date);
      final match = kind == ReportTransactionKind.savings
          ? matchGoal(transaction)
          : null;
      final targetName = kind == ReportTransactionKind.savings
          ? (match?.title ?? '(Tidak tercatat)')
          : null;

      runningBalance += _signedAmount(transaction);
      recordDays.add(date.year * 10000 + date.month * 100 + date.day);

      final row = ReportTransactionRow(
        id: transaction.id,
        date: transaction.date,
        kind: kind,
        category: transaction.category,
        amount: amount,
        note: transaction.note,
        targetName: targetName,
        targetGoalId: match?.id,
        runningBalance: runningBalance,
      );
      rows.add(row);

      switch (kind) {
        case ReportTransactionKind.income:
          totalIncome += amount;
          _addCategory(incomeCategories, transaction.category, amount);
          break;
        case ReportTransactionKind.expense:
          totalExpense += amount;
          _addCategory(expenseCategories, transaction.category, amount);
          if (largestExpenseTransaction == null ||
              amount > largestExpenseTransaction.amount) {
            largestExpenseTransaction = row;
          }
          break;
        case ReportTransactionKind.savings:
          totalSavings += amount;
          if (match == null) {
            unmatchedAllocationCount++;
            unmatchedAllocationAmount += amount;
          } else {
            final allocation = allocationsByGoal.putIfAbsent(
              match.id,
              _AllocationBucket.new,
            );
            allocation
              ..amount += amount
              ..count += 1;
          }
          break;
      }

      final monthKey = transaction.date.year * 100 + transaction.date.month;
      final month = monthlyBuckets.putIfAbsent(monthKey, _MonthBucket.new);
      month.count++;
      switch (kind) {
        case ReportTransactionKind.income:
          month.income += amount;
          break;
        case ReportTransactionKind.expense:
          month.expense += amount;
          break;
        case ReportTransactionKind.savings:
          month.savings += amount;
          break;
      }
    }

    final netChange = totalIncome - totalExpense - totalSavings;
    final endingBalance = openingBalance + netChange;
    final daysInPeriod = _daysInPeriod(periodStart, periodEnd);
    final averageExpensePerDay = totalExpense / daysInPeriod;
    final savingsRate = totalIncome <= 0 ? 0.0 : totalSavings / totalIncome;

    final expenseTotals = _buildCategoryTotals(
      expenseCategories,
      totalExpense,
    );
    final incomeTotals = _buildCategoryTotals(incomeCategories, totalIncome);

    final months = <MonthlyTotal>[];
    var cursor = DateTime(periodStart.year, periodStart.month);
    final lastMonth = DateTime(periodEnd.year, periodEnd.month);
    while (!cursor.isAfter(lastMonth)) {
      final key = cursor.year * 100 + cursor.month;
      final bucket = monthlyBuckets[key] ?? _MonthBucket();
      months.add(
        MonthlyTotal(
          year: cursor.year,
          month: cursor.month,
          income: bucket.income,
          expense: bucket.expense,
          savings: bucket.savings,
          transactionCount: bucket.count,
        ),
      );
      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    final goalProgress = goals.map((goal) {
      final allocation = allocationsByGoal[goal.id] ?? _AllocationBucket();
      final deadline = _dateOnly(goal.deadline);
      final daysRemaining = deadline.difference(generatedDate).inDays;
      return GoalProgress(
        id: goal.id,
        title: goal.title,
        currentAmount: goal.currentAmount.round(),
        targetAmount: goal.targetAmount.round(),
        deadline: goal.deadline,
        daysRemaining: daysRemaining < 0 ? 0 : daysRemaining,
        status: _statusOf(goal),
        allocatedInPeriod: allocation.amount,
        allocationCountInPeriod: allocation.count,
      );
    }).toList();

    final insights = <String>[];
    if (totalIncome > 0) {
      if (totalSavings > 0) {
        insights.add(
          'Kamu menabung ${_formatPercent(savingsRate)} dari pemasukan '
          'periode ini.',
        );
      } else {
        insights.add(
          'Belum ada dana yang kamu sisihkan untuk tabungan periode ini.',
        );
      }
    }
    if (totalExpense > 0 && expenseTotals.isNotEmpty) {
      final largest = expenseTotals.first;
      insights.add(
        'Pengeluaran terbesarmu ada di ${largest.category}: '
        '${_formatRupiah(largest.total)} '
        '(${_formatPercent(largest.share)} dari pengeluaran).',
      );
      insights.add(
        'Rata-rata kamu mengeluarkan ${_formatRupiah(averageExpensePerDay)} '
        'per hari.',
      );
    }

    final emptyMonth = months.where((month) => month.transactionCount == 0);
    if (rows.isNotEmpty && emptyMonth.isNotEmpty) {
      final month = emptyMonth.first;
      insights.add(
        'Tidak ada catatan di ${_monthLabel(month.year, month.month)}. '
        'Pencatatan yang rutin bikin angka ini lebih akurat.',
      );
    }
    if (unmatchedAllocationCount > 0) {
      insights.add(
        '$unmatchedAllocationCount alokasi tabungan belum punya nama target, '
        'jadi tidak bisa dihitung per target.',
      );
    }
    if (budgetLimit != null &&
        budgetLimit > 0 &&
        activeCycleExpense > 0 &&
        activeCycleExpense / budgetLimit >= 0.8) {
      insights.add(
        'Pengeluaran bulan ini sudah '
        '${_formatPercent(activeCycleExpense / budgetLimit)} dari batas '
        'anggaranmu.',
      );
    }

    return ReportSummary(
      appName: AppConfig.appName,
      generatedAt: generatedAt,
      periodStart: periodStart,
      periodEnd: periodEnd,
      periodLabel: period.label,
      isAllTime: period.isAllTime,
      dataStart: rows.isEmpty ? null : _dateOnly(rows.first.date),
      dataEnd: rows.isEmpty ? null : _dateOnly(rows.last.date),
      openingBalance: openingBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalSavings: totalSavings,
      netChange: netChange,
      endingBalance: endingBalance,
      transactionCount: rows.length,
      daysInPeriod: daysInPeriod,
      daysWithRecords: recordDays.length,
      averageExpensePerDay: averageExpensePerDay,
      savingsRate: savingsRate,
      activeCycleBalance: activeCycleBalance,
      activeCycleStart: cycleStart,
      activeCycleEnd: cycleEnd,
      transactions: List.unmodifiable(rows),
      expenseCategories: List.unmodifiable(expenseTotals),
      incomeCategories: List.unmodifiable(incomeTotals),
      months: List.unmodifiable(months),
      goals: List.unmodifiable(goalProgress),
      unmatchedAllocationCount: unmatchedAllocationCount,
      unmatchedAllocationAmount: unmatchedAllocationAmount,
      largestExpenseCategory: expenseTotals.isEmpty
          ? null
          : expenseTotals.first,
      largestExpenseTransaction: largestExpenseTransaction,
      insights: List.unmodifiable(insights.take(6)),
    );
  }

  int _compareTransactions(TransactionEntity a, TransactionEntity b) {
    final dateComparison = a.date.compareTo(b.date);
    return dateComparison != 0 ? dateComparison : a.id.compareTo(b.id);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  int _daysInPeriod(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return days < 1 ? 1 : days;
  }

  ReportTransactionKind _kindOf(TransactionEntity transaction) {
    if (transaction.isExpense &&
        transaction.category == FinanceCategories.savingsAllocation) {
      return ReportTransactionKind.savings;
    }
    return transaction.isExpense
        ? ReportTransactionKind.expense
        : ReportTransactionKind.income;
  }

  int _signedAmount(TransactionEntity transaction) {
    final amount = transaction.amount.round();
    return _kindOf(transaction) == ReportTransactionKind.income
        ? amount
        : -amount;
  }

  int _balanceForRange(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime end,
  ) {
    var balance = 0;
    for (final transaction in transactions) {
      final date = _dateOnly(transaction.date);
      if (date.isBefore(start) || date.isAfter(end)) continue;
      balance += _signedAmount(transaction);
    }
    return balance;
  }

  int _expenseForRange(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime end,
  ) {
    var total = 0;
    for (final transaction in transactions) {
      final date = _dateOnly(transaction.date);
      if (date.isBefore(start) || date.isAfter(end)) continue;
      if (_kindOf(transaction) == ReportTransactionKind.expense) {
        total += transaction.amount.round();
      }
    }
    return total;
  }

  void _addCategory(
    Map<String, _CategoryBucket> buckets,
    String category,
    int amount,
  ) {
    final bucket = buckets.putIfAbsent(category, _CategoryBucket.new);
    bucket
      ..total += amount
      ..count += 1;
  }

  List<CategoryTotal> _buildCategoryTotals(
    Map<String, _CategoryBucket> buckets,
    int base,
  ) {
    final totals = buckets.entries.map((entry) {
      final bucket = entry.value;
      return CategoryTotal(
        category: entry.key,
        transactionCount: bucket.count,
        total: bucket.total,
        share: base <= 0 ? 0 : bucket.total / base,
        averagePerTransaction: bucket.count == 0
            ? 0
            : bucket.total / bucket.count,
      );
    }).toList()..sort((a, b) {
      final totalComparison = b.total.compareTo(a.total);
      return totalComparison != 0
          ? totalComparison
          : a.category.compareTo(b.category);
    });
    return totals;
  }

  GoalStatus _statusOf(SavingsGoalEntity goal) {
    if (goal.isArchived) return GoalStatus.archived;
    if (goal.isCompleted) return GoalStatus.completed;
    return GoalStatus.active;
  }

  String _normalizeTitle(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _stripAllocationPrefix(String note) {
    final prefix = FinanceCategories.savingsAllocationNotePrefix;
    if (note.length >= prefix.length &&
        note.substring(0, prefix.length).toLowerCase() ==
            prefix.toLowerCase()) {
      return note.substring(prefix.length).trim();
    }
    return note;
  }

  String _formatRupiah(num value) {
    return formatRupiah(value.toDouble());
  }

  String _formatPercent(double fraction) {
    final percent = (fraction * 100).toStringAsFixed(1).replaceAll('.', ',');
    return '$percent%';
  }

  String _monthLabel(int year, int month) {
    return '${_monthNames[month - 1]} $year';
  }
}

class _GoalMatch {
  const _GoalMatch(this.id, this.title);

  final String id;
  final String title;
}

class _CategoryBucket {
  int total = 0;
  int count = 0;
}

class _MonthBucket {
  int income = 0;
  int expense = 0;
  int savings = 0;
  int count = 0;
}

class _AllocationBucket {
  int amount = 0;
  int count = 0;
}
