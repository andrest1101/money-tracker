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

class _TrendContent extends StatelessWidget {
  const _TrendContent({required this.points});
  final List<BalanceTrendPointEntity> points;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final values = points.map((point) => point.balance).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final spread = maxValue - minValue;
    final padding = spread == 0 ? 100000.0 : spread * .18;
    return SizedBox(
      height: 210,
      child: LineChart(
        LineChartData(
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
        ),
      ),
    );
  }
}
