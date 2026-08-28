import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/presentation/widgets/quick_add_transaction_sheet.dart';
import '../../domain/entities/monthly_summary_entity.dart';
import '../../domain/entities/budget_overview_entity.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/category_expense_pie_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MoneyTracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const QuickAddTransactionSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Catat'),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DashboardErrorView(
          onRetry: () {
            ref.invalidate(transactionsStreamProvider);
          },
        ),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BalanceCard(summary: summary),
            const SizedBox(height: 16),
            _BudgetStatusSection(summary: summary),
            const SizedBox(height: 16),
            const CategoryExpensePieCard(),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.summary});

  final MonthlySummaryEntity summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final balanceColor = summary.balance >= 0
        ? Colors.green.shade700
        : Colors.red.shade600;
    final isPrivacyMode = ref.watch(privacyModeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo Bulan Ini',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(privacyModeProvider.notifier).toggle(),
                  child: Icon(
                    isPrivacyMode
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isPrivacyMode ? 'Rp •••••••' : formatRupiah(summary.balance),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPrivacyMode ? onSurfaceVariant : balanceColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AmountTile(
                    icon: Icons.south_west,
                    label: 'Pemasukan',
                    amount: isPrivacyMode
                        ? 'Rp •••'
                        : formatRupiah(summary.totalIncome),
                    color: isPrivacyMode
                        ? onSurfaceVariant
                        : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AmountTile(
                    icon: Icons.north_east,
                    label: 'Pengeluaran',
                    amount: isPrivacyMode
                        ? 'Rp •••'
                        : formatRupiah(summary.totalExpense),
                    color: isPrivacyMode
                        ? onSurfaceVariant
                        : Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStatusSection extends ConsumerWidget {
  const _BudgetStatusSection({required this.summary});

  final MonthlySummaryEntity summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetLimit = ref.watch(budgetLimitProvider);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Status Anggaran',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (budgetLimit == null)
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Batas anggaran belum diatur. Atur di menu Pengaturan '
                      'untuk mulai memantau pengeluaran bulanmu.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              )
            else
              const _BudgetAlertContent(),
          ],
        ),
      ),
    );
  }
}

class _BudgetAlertContent extends ConsumerWidget {
  const _BudgetAlertContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final overviewAsync = ref.watch(budgetOverviewProvider);

    return overviewAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Text(
        'Detail anggaran tidak tersedia',
        style: theme.textTheme.bodySmall,
      ),
      data: (overview) => _BudgetAlertBody(overview: overview),
    );
  }
}

class _BudgetAlertBody extends StatelessWidget {
  const _BudgetAlertBody({required this.overview});

  final BudgetOverviewEntity overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = overview.isExceeded
        ? Colors.red.shade600
        : overview.isWarning
        ? Colors.orange.shade700
        : Colors.green.shade700;
    final statusLabel = overview.isExceeded
        ? 'Anggaran terlampaui'
        : overview.isWarning
        ? 'Perlu diperhatikan'
        : 'Pengeluaran terkendali';

    return InkWell(
      onTap: () => _showBudgetOverview(context, overview),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                overview.isExceeded
                    ? Icons.error_outline_rounded
                    : overview.isWarning
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(overview.spentRatio * 100).round()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: overview.spentRatio.clamp(0.0, 1.0),
              minHeight: 12,
              color: statusColor,
              backgroundColor: statusColor.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatRupiah(overview.totalExpense)} dari ${formatRupiah(overview.budgetLimit)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                overview.isExceeded
                    ? 'Lebih ${formatRupiah(overview.remaining.abs())}'
                    : 'Sisa ${formatRupiah(overview.remaining)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${formatDateShort(overview.periodStart)} - ${formatDateShort(overview.periodEnd)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Icon(Icons.touch_app_rounded, size: 16),
              const SizedBox(width: 4),
              Text('Lihat detail', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  void _showBudgetOverview(
    BuildContext context,
    BudgetOverviewEntity overview,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BudgetOverviewSheet(overview: overview),
    );
  }
}

class _BudgetOverviewSheet extends StatelessWidget {
  const _BudgetOverviewSheet({required this.overview});

  final BudgetOverviewEntity overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = overview.isExceeded
        ? Colors.red.shade600
        : overview.isWarning
        ? Colors.orange.shade700
        : Colors.green.shade700;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview Anggaran', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                '${formatDateShort(overview.periodStart)} - ${formatDateShort(overview.periodEnd)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.65)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overview.isExceeded ? 'Melebihi batas' : 'Sisa anggaran',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatRupiah(overview.remaining.abs()),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: overview.spentRatio.clamp(0.0, 1.0),
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(5),
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(overview.spentRatio * 100).round()}% digunakan dari ${formatRupiah(overview.budgetLimit)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _BudgetMetric(
                      label: 'Transaksi',
                      value: '${overview.transactionCount}',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BudgetMetric(
                      label: 'Rata-rata / hari',
                      value: formatRupiah(overview.averageDailyExpense),
                      icon: Icons.show_chart_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _BudgetMetric(
                label: 'Estimasi akhir periode',
                value: formatRupiah(overview.projectedExpense),
                icon: Icons.insights_rounded,
                wide: true,
              ),
              const SizedBox(height: 20),
              Text(
                'Kategori terbesar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (overview.topCategories.isEmpty)
                Text(
                  'Belum ada pengeluaran pada periode ini',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ...overview.topCategories.asMap().entries.map((entry) {
                  final item = entry.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text('${entry.key + 1}'),
                    ),
                    title: Text(item.category),
                    trailing: Text(
                      formatRupiah(item.amount),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Tutup overview'),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.wide = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: theme.colorScheme.primary),
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
                      fontWeight: FontWeight.bold,
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

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data keuangan',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Periksa koneksi internetmu lalu coba lagi.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
