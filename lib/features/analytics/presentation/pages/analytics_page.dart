import 'package:flutter/material.dart';

import '../widgets/balance_trend_chart_card.dart';
import '../widgets/cash_flow_chart_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Analitik Keuangan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Pahami pola uangmu',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gunakan data ini untuk membuat keputusan finansial yang lebih baik.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          const CashFlowChartCard(),
          const SizedBox(height: 14),
          const BalanceTrendChartCard(),
        ],
      ),
    );
  }
}
