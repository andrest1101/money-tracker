import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/balance_trend_point_entity.dart';
import '../providers/analytics_providers.dart';

class BalanceTrendChartCard extends ConsumerWidget {
  const BalanceTrendChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pointsAsync = ref.watch(balanceTrendPointsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tren saldo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Perubahan saldo kumulatif dalam periode terpilih',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            pointsAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(
                height: 200,
                child: Center(child: Text('Tren saldo belum tersedia.')),
              ),
              data: (points) => points.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: Text('Belum ada data saldo.')),
                    )
                  : _TrendContent(points: points),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendContent extends StatefulWidget {
  const _TrendContent({required this.points});
  final List<BalanceTrendPointEntity> points;

  @override
  State<_TrendContent> createState() => _TrendContentState();
}

class _TrendContentState extends State<_TrendContent> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final points = widget.points;
    final values = points.map((point) => point.balance).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final spread = maxValue - minValue;
    final padding = spread == 0 ? 100000.0 : spread * .18;
    final chart = LineChartData(
          minY: minValue - padding,
          maxY: maxValue + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colors.outlineVariant.withValues(alpha: .3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchCallback: (event, response) {
              if (event is! FlTapUpEvent) return;
              final spot = response?.lineBarSpots?.firstOrNull;
              if (spot == null) return;
              final index = spot.x.toInt();
              if (index >= 0 && index < points.length) {
                setState(() => _selectedIndex = index);
              }
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colors.inverseSurface,
              getTooltipItems: (spots) => spots
                  .map(
                    (spot) => LineTooltipItem(
                      formatRupiah(spot.y),
                      TextStyle(
                        color: colors.onInverseSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              barWidth: 3,
              color: colors.primary,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: colors.primary.withValues(alpha: .1),
              ),
            ),
          ],
        );
    return Column(
      children: [
        if (_selectedIndex case final index?) ...[
          _SelectedBalancePoint(
            point: points[index],
            onClear: () => setState(() => _selectedIndex = null),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(height: 210, child: LineChart(chart)),
      ],
    );
  }
}

class _SelectedBalancePoint extends StatelessWidget {
  const _SelectedBalancePoint({required this.point, required this.onClear});

  final BalanceTrendPointEntity point;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 11, 8, 11),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Icon(Icons.show_chart_rounded, size: 18, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${point.date.day}/${point.date.month}/${point.date.year}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Saldo ${formatRupiah(point.balance)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            tooltip: 'Sembunyikan detail',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
