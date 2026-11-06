import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/budget_progress.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../settings/presentation/widgets/settings_financial_section.dart';
import '../../../transactions/presentation/providers/history_providers.dart';
import '../../domain/entities/budget_overview_entity.dart';
import '../providers/dashboard_providers.dart';
import 'dashboard_skeleton.dart';

/// Section anggaran bulan ini.
///
/// Tidak memakai kartu. Saat anggaran belum diatur, hanya ada satu kalimat dan
/// tombol outlined. Saat sudah diatur, `BudgetProgress` menjadi fokus dan
/// seluruh baris bisa diketuk untuk membuka overview.
class BudgetStatusSection extends ConsumerWidget {
  const BudgetStatusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetLimit = ref.watch(budgetLimitProvider);
    final hasBudget = budgetLimit != null && budgetLimit > 0;
    final theme = Theme.of(context);
    final colors = context.appColors;

    void openBudgetDialog() {
      showDialog<void>(
        context: context,
        builder: (_) => SetBudgetDialog(currentLimit: budgetLimit),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Anggaran bulan ini',
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Tentang anggaran bulanan',
              onPressed: () => _showBudgetInfo(context),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: openBudgetDialog,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Atur'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        if (!hasBudget)
          _NoBudgetContent(onSetBudget: openBudgetDialog)
        else
          BudgetAlertContent(
            onOpenOverview: (overview) =>
                _showBudgetOverview(context, overview, ref),
          ),
      ],
    );
  }

  void _showBudgetInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const BudgetInfoSheet(),
    );
  }

  void _showBudgetOverview(
    BuildContext context,
    BudgetOverviewEntity overview,
    WidgetRef ref,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BudgetOverviewSheet(
        overview: overview,
        onOpenHistory: (target) {
          final navigator = Navigator.of(context);
          if (target == null) {
            ref
                .read(historyNavigationIntentProvider.notifier)
                .openActiveCycle();
          } else {
            ref
                .read(historyNavigationIntentProvider.notifier)
                .openCategoryInActiveCycle(target);
          }
          navigator.pop();
        },
      ),
    );
  }
}

class _NoBudgetContent extends StatelessWidget {
  const _NoBudgetContent({required this.onSetBudget});

  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Belum ada batas anggaran. Tetapkan batas agar Dompetku bisa '
          'mengingatkanmu sebelum pengeluaran berlebih.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: onSetBudget,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: const Text('Atur anggaran'),
          ),
        ),
      ],
    );
  }
}

class BudgetInfoSheet extends StatelessWidget {
  const BudgetInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = context.appColors;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
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
                Text(
                  'Tentang Pengeluaran Bulanan',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Pantau pengeluaranmu dalam satu siklus',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Bagian ini membandingkan total pengeluaran dalam siklus '
                  'aktif dengan batas yang kamu atur. Gunakan sebagai '
                  'pengingat agar pengeluaran tetap terkendali.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BudgetInfoLevel(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Aman',
                  description: 'Pengeluaran masih di bawah 80% anggaran.',
                  color: colors.primary,
                ),
                const SizedBox(height: AppSpacing.xs),
                BudgetInfoLevel(
                  icon: Icons.warning_amber_rounded,
                  title: 'Perlu diperhatikan',
                  description: 'Pengeluaran sudah mencapai 80% atau lebih.',
                  color: appColors.warningText,
                ),
                const SizedBox(height: AppSpacing.xs),
                BudgetInfoLevel(
                  icon: Icons.error_outline_rounded,
                  title: 'Terlampaui',
                  description:
                      'Total pengeluaran sudah melewati batas anggaran.',
                  color: appColors.danger,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: colors.onPrimaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Tips: catat semua pengeluaran kecil. Pengeluaran '
                          'kecil yang sering dilakukan bisa menjadi penyebab '
                          '"bocor halus".',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onPrimaryContainer,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mengerti'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BudgetInfoLevel extends StatelessWidget {
  const BudgetInfoLevel({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
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

class BudgetAlertContent extends ConsumerWidget {
  const BudgetAlertContent({super.key, required this.onOpenOverview});

  final ValueChanged<BudgetOverviewEntity> onOpenOverview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(budgetOverviewProvider);

    return overviewAsync.when(
      loading: () => const SectionSkeleton(height: 86),
      error: (_, __) => Row(
        children: [
          Expanded(
            child: Text(
              'Detail anggaran tidak tersedia.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(budgetOverviewProvider),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
      data: (overview) =>
          _BudgetOverviewBody(overview: overview, onOpen: onOpenOverview),
    );
  }
}

class _BudgetOverviewBody extends StatelessWidget {
  const _BudgetOverviewBody({required this.overview, required this.onOpen});

  final BudgetOverviewEntity overview;
  final ValueChanged<BudgetOverviewEntity> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final daysLeft = overview.totalDays - overview.elapsedDays;
    final daysLabel = daysLeft <= 0 ? 'hari terakhir' : '$daysLeft hari lagi';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onOpen(overview),
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BudgetProgress(
                spent: overview.totalExpense,
                limit: overview.budgetLimit,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatRupiah(overview.totalExpense)} dari '
                      '${formatRupiah(overview.budgetLimit)} · $daysLabel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Detail',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
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
}

class BudgetOverviewSheet extends StatelessWidget {
  const BudgetOverviewSheet({
    super.key,
    required this.overview,
    required this.onOpenHistory,
  });

  final BudgetOverviewEntity overview;
  final ValueChanged<String?>? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = context.appColors;
    final statusColor = overview.isExceeded
        ? appColors.danger
        : overview.isWarning
        ? appColors.warningText
        : colors.primary;
    final heroBackground = overview.isExceeded
        ? colors.errorContainer
        : colors.primaryContainer;
    final heroForeground = overview.isExceeded
        ? colors.onErrorContainer
        : colors.onPrimaryContainer;

    return AppBottomSheetLayout(
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
            Text('Overview Anggaran', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${formatDateShort(overview.periodStart)} – '
              '${formatDateShort(overview.periodEnd)}',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: heroBackground,
                borderRadius: BorderRadius.circular(AppRadius.hero),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overview.isExceeded ? 'Melebihi batas' : 'Sisa anggaran',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: heroForeground.withValues(alpha: .72),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatRupiah(overview.remaining.abs()),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: heroForeground,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: overview.spentRatio.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: heroForeground.withValues(alpha: .16),
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${(overview.spentRatio * 100).round()}% digunakan '
                    'dari ${formatRupiah(overview.budgetLimit)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: heroForeground.withValues(alpha: .78),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: BudgetMetric(
                    label: 'Transaksi',
                    value: '${overview.transactionCount}',
                    icon: Icons.receipt_long_outlined,
                    onTap: onOpenHistory == null
                        ? null
                        : () => onOpenHistory!(null),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: BudgetMetric(
                    label: 'Rata-rata / hari',
                    value: formatRupiah(overview.averageDailyExpense),
                    icon: Icons.show_chart_rounded,
                    onTap: () => _showMetricDetail(
                      context,
                      title: 'Rata-rata pengeluaran harian',
                      message:
                          'Angka ini dihitung dari total pengeluaran '
                          'yang sudah terjadi dibagi jumlah hari yang '
                          'telah berjalan pada siklus ini.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            BudgetMetric(
              label: 'Estimasi akhir periode',
              value: formatRupiah(overview.projectedExpense),
              icon: Icons.insights_rounded,
              wide: true,
              onTap: () => _showMetricDetail(
                context,
                title: 'Estimasi akhir periode',
                message:
                    'Proyeksi ini menggunakan rata-rata pengeluaran '
                    'harian saat ini untuk memperkirakan total '
                    'pengeluaran sampai akhir siklus.',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Kategori terbesar', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            if (overview.topCategories.isEmpty)
              Text(
                'Belum ada pengeluaran pada periode ini.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appColors.textSecondary,
                ),
              )
            else
              ...overview.topCategories.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      CategoryIcon(category: item.category, size: 32),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item.category,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        formatRupiah(item.amount),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: appColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMetricDetail(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

class BudgetMetric extends StatelessWidget {
  const BudgetMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.wide = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final content = Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
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

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: content,
      ),
    );
  }
}
