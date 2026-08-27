import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/presentation/widgets/quick_add_transaction_sheet.dart';
import '../../domain/entities/monthly_summary_entity.dart';
import '../../domain/usecases/check_budget_status_usecase.dart';
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});

  final MonthlySummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final balanceColor =
        summary.balance >= 0 ? Colors.green.shade700 : Colors.red.shade600;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Bulan Ini',
              style: theme.textTheme.titleMedium?.copyWith(color: onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatRupiah(summary.balance),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: balanceColor,
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
                    amount: formatRupiah(summary.totalIncome),
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AmountTile(
                    icon: Icons.north_east,
                    label: 'Pengeluaran',
                    amount: formatRupiah(summary.totalExpense),
                    color: Colors.red.shade600,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Anggaran', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (budgetLimit == null)
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
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
              _BudgetAlertContent(summary: summary, budgetLimit: budgetLimit),
          ],
        ),
      ),
    );
  }
}

class _BudgetAlertContent extends StatelessWidget {
  const _BudgetAlertContent({
    required this.summary,
    required this.budgetLimit,
  });

  final MonthlySummaryEntity summary;
  final double budgetLimit;

  static const _checkBudgetStatus = CheckBudgetStatusUseCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _checkBudgetStatus.execute(
      totalExpense: summary.totalExpense,
      budgetLimit: budgetLimit,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: status.spentRatio.clamp(0.0, 1.0),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
          color: status.isSafe ? null : theme.colorScheme.error,
        ),
        const SizedBox(height: 8),
        Text(
          '${formatRupiah(summary.totalExpense)} terpakai '
          'dari batas ${formatRupiah(budgetLimit)} '
          '(${(status.spentRatio * 100).round()}%)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (!status.isSafe) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status.isExceeded
                      ? 'Batas anggaran bulanan terlampaui! Saatnya evaluasi pengeluaran.'
                      : 'Hampir melebihi batas anggaran bulanan!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
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
            Icon(Icons.cloud_off_outlined, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Gagal memuat data keuangan', style: theme.textTheme.titleMedium),
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
