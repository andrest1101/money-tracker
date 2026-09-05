import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/monthly_summary_entity.dart';

class BalanceHeroCard extends ConsumerWidget {
  const BalanceHeroCard({
    super.key,
    required this.summary,
    required this.transactions,
  });

  final MonthlySummaryEntity summary;
  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPrivacy = ref.watch(privacyModeProvider);
    final isDark = theme.brightness == Brightness.dark;
    final isPositive = summary.balance >= 0;

    final incomeColor = isDark
        ? const Color(0xFF9FE870)
        : const Color(0xFF167A45);
    final expenseColor = isDark
        ? const Color(0xFFFFA3A3)
        : const Color(0xFFB42318);
    final balanceColor = isPositive
        ? (isDark ? const Color(0xFFF4FFF0) : const Color(0xFF102A19))
        : expenseColor;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: () => _showBalanceOverview(context, isPrivacy),
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceContainerHigh
                : colors.primaryContainer,
            gradient: isDark
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primaryContainer,
                      colors.secondaryContainer.withValues(alpha: 0.7),
                    ],
                  ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? colors.outlineVariant
                  : colors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Saldo saat ini',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PrivacyToggle(
                      isPrivacy: isPrivacy,
                      colors: colors,
                      ref: ref,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      key: ValueKey(isPrivacy),
                      isPrivacy ? 'Rp •••••••' : formatRupiah(summary.balance),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                        letterSpacing: -1.3,
                        color: isPrivacy
                            ? colors.onSurfaceVariant
                            : balanceColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FlowTile(
                        icon: Icons.south_west_rounded,
                        label: 'Pemasukan',
                        amount: isPrivacy
                            ? 'Rp •••'
                            : formatRupiah(summary.totalIncome),
                        color: incomeColor,
                        isPrivacy: isPrivacy,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FlowTile(
                        icon: Icons.north_east_rounded,
                        label: 'Pengeluaran',
                        amount: isPrivacy
                            ? 'Rp •••'
                            : formatRupiah(summary.totalExpense),
                        color: expenseColor,
                        isPrivacy: isPrivacy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBalanceOverview(BuildContext context, bool isPrivacy) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BalanceOverviewSheet(
        summary: summary,
        transactions: transactions,
        isPrivacy: isPrivacy,
      ),
    );
  }
}

class BalanceOverviewSheet extends StatelessWidget {
  const BalanceOverviewSheet({
    super.key,
    required this.summary,
    required this.transactions,
    required this.isPrivacy,
  });

  final MonthlySummaryEntity summary;
  final List<TransactionEntity> transactions;
  final bool isPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visibleTransactions = transactions
        .where((transaction) => !transaction.isAllocation)
        .toList();
    final largestExpense = visibleTransactions
        .where((transaction) => transaction.isExpense)
        .fold<TransactionEntity?>(
          null,
          (largest, transaction) =>
              largest == null || transaction.amount > largest.amount
              ? transaction
              : largest,
        );
    String amount(double value) =>
        isPrivacy ? 'Rp •••••••' : formatRupiah(value);

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .86,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ringkasan saldo', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Siklus anggaran berjalan',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? colors.surface
                      : colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: theme.brightness == Brightness.dark
                      ? Border.all(color: colors.outlineVariant)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo bersih',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount(summary.balance),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: summary.balance >= 0
                            ? colors.primary
                            : colors.error,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BalanceOverviewMetric(
                      label: 'Pemasukan',
                      value: amount(summary.totalIncome),
                      icon: Icons.south_west_rounded,
                      color: colors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BalanceOverviewMetric(
                      label: 'Pengeluaran',
                      value: amount(summary.totalExpense),
                      icon: Icons.north_east_rounded,
                      color: colors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BalanceOverviewMetric(
                label: 'Transaksi tercatat',
                value: '${summary.transactionCount} transaksi',
                icon: Icons.receipt_long_outlined,
                color: colors.primary,
                wide: true,
              ),
              if (largestExpense != null) ...[
                const SizedBox(height: 18),
                Text(
                  'Pengeluaran terbesar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colors.errorContainer,
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: colors.onErrorContainer,
                    ),
                  ),
                  title: Text(largestExpense.category),
                  subtitle: Text(
                    largestExpense.note.isEmpty
                        ? 'Transaksi terbesar pada siklus ini'
                        : largestExpense.note,
                  ),
                  trailing: Text(
                    amount(largestExpense.amount),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup ringkasan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BalanceOverviewMetric extends StatelessWidget {
  const BalanceOverviewMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
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

class PrivacyToggle extends StatelessWidget {
  const PrivacyToggle({
    super.key,
    required this.isPrivacy,
    required this.colors,
    required this.ref,
  });
  final bool isPrivacy;
  final ColorScheme colors;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(privacyModeProvider.notifier).toggle(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              key: ValueKey(isPrivacy),
              isPrivacy
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: colors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class FlowTile extends StatelessWidget {
  const FlowTile({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.isPrivacy,
  });

  final IconData icon;
  final String label;
  final String amount;
  final Color color;
  final bool isPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isPrivacy ? colors.onSurfaceVariant : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
