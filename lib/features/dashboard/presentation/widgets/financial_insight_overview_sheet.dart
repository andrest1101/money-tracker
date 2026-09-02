import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../analytics/domain/entities/expense_flow_insight_entity.dart';
import '../../domain/entities/financial_insight_entity.dart';
import '../../../analytics/domain/usecases/calculate_expense_flow_insight_usecase.dart';
import '../../domain/usecases/calculate_budget_cycle_period_usecase.dart';

class FinancialInsightOverviewSheet extends StatelessWidget {
  const FinancialInsightOverviewSheet({
    super.key,
    required this.insight,
    required this.transactions,
    required this.cycleDay,
  });

  final FinancialInsightEntity insight;
  final List<TransactionEntity> transactions;
  final int cycleDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cycle = const CalculateBudgetCyclePeriodUseCase().execute(
      date: DateTime.now(),
      cycleDay: cycleDay,
    );
    final current = transactions.where((transaction) {
      return !transaction.date.isBefore(cycle.start) &&
          !transaction.date.isAfter(DateTime.now());
    }).toList();
    final categories = <String, double>{};
    for (final transaction in current) {
      if (transaction.isExpense) {
        categories[transaction.category] =
            (categories[transaction.category] ?? 0) + transaction.amount;
      }
    }
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCategory = sortedCategories.isEmpty
        ? null
        : sortedCategories.first;
    final improving = insight.expenseChangeRatio <= 0;
    final trendColor = improving ? colors.tertiary : colors.error;
    final difference = insight.expense - insight.previousExpense;
    final expenseFlow = const CalculateExpenseFlowInsightUseCase().execute(
      transactions: current,
      start: DateTime.now().subtract(const Duration(days: 6)),
      end: DateTime.now(),
    );

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .92,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insight keuangan',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatDateShort(cycle.start)} - ${formatDateShort(cycle.end)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Ringkasan',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _InsightOverviewMetric(
                      label: 'Pemasukan',
                      value: formatRupiah(insight.income),
                      color: colors.tertiary,
                      icon: Icons.south_west_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InsightOverviewMetric(
                      label: 'Pengeluaran',
                      value: formatRupiah(insight.expense),
                      color: colors.error,
                      icon: Icons.north_east_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _InsightOverviewMetric(
                label: 'Saldo bersih',
                value: formatRupiah(insight.net),
                color: insight.net >= 0 ? colors.primary : colors.error,
                icon: Icons.account_balance_wallet_outlined,
                wide: true,
              ),
              const SizedBox(height: 20),
              Text(
                'Perbandingan pengeluaran',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: trendColor.withValues(alpha: .28)),
                ),
                child: Row(
                  children: [
                    Icon(
                      improving
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: trendColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.previousExpense == 0
                            ? 'Belum ada data pembanding dari siklus sebelumnya.'
                            : '${difference.abs() == 0 ? 'Tidak ada perubahan' : formatRupiah(difference.abs())} ${difference <= 0 ? 'lebih rendah' : 'lebih tinggi'} dari siklus sebelumnya.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Arus pengeluaran 7 hari terakhir',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .55),
                  ),
                ),
                child: _CashFlowChart(transactions: current, colors: colors),
              ),
              const SizedBox(height: 14),
              _ExpenseFlowSummary(insight: expenseFlow, colors: colors),
              const SizedBox(height: 20),
              Text(
                'Kategori terbesar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (maxCategory == null)
                Text('Belum ada pengeluaran pada siklus ini.')
              else
                ...sortedCategories
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: colors.primaryContainer,
                          child: Text('${entry.key + 1}'),
                        ),
                        title: Text(entry.value.key),
                        trailing: Text(
                          formatRupiah(entry.value.value),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              _InsightOverviewMetric(
                label: 'Rata-rata pengeluaran per hari',
                value: formatRupiah(insight.averageDailyExpense),
                color: colors.primary,
                icon: Icons.show_chart_rounded,
                wide: true,
              ),
              const SizedBox(height: 10),
              _InsightOverviewMetric(
                label: 'Transaksi pada periode ini',
                value: '${insight.transactionCount} transaksi',
                color: colors.primary,
                icon: Icons.receipt_long_outlined,
                wide: true,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup detail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseFlowSummary extends StatelessWidget {
  const _ExpenseFlowSummary({required this.insight, required this.colors});

  final ExpenseFlowInsightEntity insight;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final peakLabel = insight.peakDay == null
        ? 'Belum ada puncak pengeluaran'
        : '${formatDateShort(insight.peakDay!)} • ${formatRupiah(insight.peakAmount)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _InsightStat(
                label: 'Hari aktif',
                value: '${insight.activeDays} / ${insight.totalDays}',
                icon: Icons.event_available_outlined,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InsightStat(
                label: 'Puncak harian',
                value: formatRupiah(insight.peakAmount),
                icon: Icons.trending_up_rounded,
                color: colors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saran berdasarkan pola pengeluaran',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.recommendation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      peakLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onPrimaryContainer.withValues(alpha: .75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Rincian 7 hari terakhir',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        ...insight.points.reversed.map(
          (point) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              point.expense > 0
                  ? Icons.arrow_upward_rounded
                  : Icons.remove_rounded,
              size: 17,
              color: point.expense > 0 ? colors.error : colors.onSurfaceVariant,
            ),
            title: Text(formatDateShort(point.date)),
            trailing: Text(
              formatRupiah(point.expense),
              style: theme.textTheme.labelLarge?.copyWith(
                color: point.expense > 0
                    ? colors.error
                    : colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightStat extends StatelessWidget {
  const _InsightStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CashFlowChart extends StatefulWidget {
  const _CashFlowChart({required this.transactions, required this.colors});

  final List<TransactionEntity> transactions;
  final ColorScheme colors;

  @override
  State<_CashFlowChart> createState() => _CashFlowChartState();
}

class _CashFlowChartState extends State<_CashFlowChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day - (6 - index));
      return date;
    });
    final values = days.map((day) {
      var total = 0.0;
      for (final transaction in widget.transactions) {
        if (transaction.isExpense &&
            transaction.date.year == day.year &&
            transaction.date.month == day.month &&
            transaction.date.day == day.day) {
          total += transaction.amount;
        }
      }
      return total;
    }).toList();
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    return Column(
      children: [
        if (_selectedIndex case final index?) ...[
          _SelectedExpenseDay(
            date: days[index],
            amount: values[index],
            onClear: () => setState(() => _selectedIndex = null),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
        maxY: maxValue == 0 ? 1 : maxValue * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (event is! FlTapUpEvent) return;
            final index = response?.spot?.touchedBarGroupIndex;
            if (index == null || index < 0 || index >= values.length) return;
            setState(() => _selectedIndex = index);
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colors.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  formatRupiah(rod.toY),
                  TextStyle(
                    color: colors.onInverseSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                '${days[value.toInt().clamp(0, 6)].day}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < values.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  width: 18,
                  borderRadius: BorderRadius.circular(5),
                  color: colors.error,
                ),
              ],
            ),
        ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedExpenseDay extends StatelessWidget {
  const _SelectedExpenseDay({
    required this.date,
    required this.amount,
    required this.onClear,
  });

  final DateTime date;
  final double amount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 6, 9),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.error.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, size: 17, color: colors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${date.day}/${date.month}/${date.year}  •  Pengeluaran ${formatRupiah(amount)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onErrorContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onClear,
            tooltip: 'Sembunyikan detail',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 17),
          ),
        ],
      ),
    );
  }
}

class _InsightOverviewMetric extends StatelessWidget {
  const _InsightOverviewMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.wide = false,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
