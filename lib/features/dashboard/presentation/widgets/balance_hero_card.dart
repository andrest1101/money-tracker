import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../../shared/widgets/amount_text.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../shared/widgets/stat_inline.dart';
import '../../domain/entities/monthly_summary_entity.dart';

/// Hero saldo: satu-satunya permukaan solid di Beranda.
///
/// Memakai `primaryContainer` tanpa gradient. Klik membuka ringkasan saldo,
/// tombol mata mengaktifkan privacy mode.
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
    final scheme = theme.colorScheme;
    final isPrivacy = ref.watch(privacyModeProvider);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final heroText = scheme.onPrimaryContainer;
    final heroMuted = heroText.withValues(alpha: .72);
    final balanceColor = summary.balance < 0 ? scheme.error : heroText;

    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(AppRadius.hero),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showBalanceOverview(context, isPrivacy),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Saldo saat ini',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: heroMuted,
                      ),
                    ),
                  ),
                  _PrivacyToggle(
                    isPrivacy: isPrivacy,
                    foregroundColor: heroText,
                    onTap: () =>
                        ref.read(privacyModeProvider.notifier).toggle(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (isPrivacy)
                Semantics(
                  label: 'Saldo disembunyikan',
                  child: ExcludeSemantics(
                    child: Text(
                      'Rp •••••••',
                      style: AppTextStyles.amountHero.copyWith(
                        color: heroMuted,
                      ),
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: summary.balance),
                      duration: disableAnimations
                          ? Duration.zero
                          : AppDuration.counter,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return AmountText(
                          amount: value,
                          color: balanceColor,
                          style: AppTextStyles.amountHero,
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatInline(
                        label: 'Pemasukan',
                        amount: summary.totalIncome,
                        tone: AmountTone.income,
                        labelColor: heroMuted,
                        isMasked: isPrivacy,
                      ),
                    ),
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      color: heroText.withValues(alpha: .18),
                    ),
                    Expanded(
                      child: StatInline(
                        label: 'Pengeluaran',
                        amount: summary.totalExpense,
                        tone: AmountTone.neutral,
                        valueColor: heroText,
                        labelColor: heroMuted,
                        isMasked: isPrivacy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 15, color: heroMuted),
                  const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: Text(
                      'Ketuk untuk melihat ringkasan',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: heroMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
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

class _PrivacyToggle extends StatelessWidget {
  const _PrivacyToggle({
    required this.isPrivacy,
    required this.foregroundColor,
    required this.onTap,
  });

  final bool isPrivacy;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPrivacy ? 'Tampilkan nominal' : 'Sembunyikan nominal',
      child: IconButton(
        onPressed: onTap,
        tooltip: isPrivacy ? 'Tampilkan nominal' : 'Sembunyikan nominal',
        visualDensity: VisualDensity.compact,
        icon: Icon(
          isPrivacy ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: foregroundColor,
        ),
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
    final appColors = context.appColors;
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: FractionallySizedBox(
            heightFactor: .86,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xxs,
                AppSpacing.screen,
                AppSpacing.section,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan saldo', style: theme.textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Siklus anggaran berjalan',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo bersih',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onPrimaryContainer.withValues(
                              alpha: .72,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          amount(summary.balance),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: summary.balance >= 0
                                ? colors.onPrimaryContainer
                                : colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: BalanceOverviewMetric(
                          label: 'Pemasukan',
                          value: amount(summary.totalIncome),
                          icon: Icons.south_west_rounded,
                          color: appColors.income,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
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
                  const SizedBox(height: AppSpacing.xs),
                  BalanceOverviewMetric(
                    label: 'Transaksi tercatat',
                    value: '${summary.transactionCount} transaksi',
                    icon: Icons.receipt_long_outlined,
                    color: colors.primary,
                    wide: true,
                  ),
                  if (largestExpense != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Pengeluaran terbesar',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        CategoryIcon(category: largestExpense.category),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                largestExpense.category,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                largestExpense.note.isEmpty
                                    ? 'Transaksi terbesar pada siklus ini'
                                    : largestExpense.note,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          amount(largestExpense.amount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup ringkasan'),
                    ),
                  ),
                ],
              ),
            ),
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

    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.appColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: theme.textTheme.labelLarge),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
