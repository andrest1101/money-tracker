import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../transactions/presentation/providers/history_providers.dart';
import '../../domain/entities/budget_overview_entity.dart';
import '../../domain/entities/monthly_summary_entity.dart';
import '../providers/dashboard_providers.dart';
import 'dashboard_skeleton.dart';

class BudgetStatusSection extends ConsumerWidget {
  const BudgetStatusSection({super.key, required this.summary});

  final MonthlySummaryEntity summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetLimit = ref.watch(budgetLimitProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pengeluaran Bulanan',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showBudgetInfo(context),
                    tooltip: 'Apa itu pengeluaran bulanan?',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (budgetLimit == null || budgetLimit <= 0)
              NoBudgetMessage(colors: colors, theme: theme)
            else
              BudgetAlertContent(
                onOpenOverview: (overview) =>
                    _showBudgetOverview(context, overview, ref),
              ),
          ],
        ),
      ),
    );
  }

  void _showBudgetInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warningColor = isDark
        ? const Color(0xFFD6A72C)
        : const Color(0xFFD97706);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => BudgetInfoSheet(warningColor: warningColor),
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

class BudgetInfoSheet extends StatelessWidget {
  const BudgetInfoSheet({super.key, required this.warningColor});

  final Color warningColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tentang Pengeluaran Bulanan',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau pengeluaranmu dalam satu siklus',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bagian ini membandingkan total pengeluaran dalam siklus aktif dengan batas yang kamu atur. Gunakan sebagai pengingat agar pengeluaran tetap terkendali.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            BudgetInfoLevel(
              icon: Icons.check_circle_outline_rounded,
              title: 'Aman',
              description: 'Pengeluaran masih di bawah 80% anggaran.',
              color: colors.primary,
            ),
            const SizedBox(height: 10),
            BudgetInfoLevel(
              icon: Icons.warning_amber_rounded,
              title: 'Perlu diperhatikan',
              description: 'Pengeluaran sudah mencapai 80% atau lebih.',
              color: warningColor,
            ),
            const SizedBox(height: 10),
            BudgetInfoLevel(
              icon: Icons.error_outline_rounded,
              title: 'Terlampaui',
              description: 'Total pengeluaran sudah melewati batas anggaran.',
              color: colors.error,
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? colors.surface
                    : colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: theme.brightness == Brightness.dark
                    ? Border.all(color: colors.outlineVariant)
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tips: catat semua pengeluaran kecil. Pengeluaran kecil yang sering dilakukan bisa menjadi penyebab "bocor halus".',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Mengerti'),
            ),
          ],
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
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
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

class NoBudgetMessage extends StatelessWidget {
  const NoBudgetMessage({super.key, required this.colors, required this.theme});
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Atur batas anggaran di Pengaturan untuk mulai memantau pengeluaran.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
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
      loading: () => const SectionSkeleton(height: 80),
      error: (_, __) => Text(
        'Detail anggaran tidak tersedia.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      data: (overview) =>
          BudgetAlertBody(overview: overview, onOpenOverview: onOpenOverview),
    );
  }
}

class BudgetAlertBody extends StatelessWidget {
  const BudgetAlertBody({
    super.key,
    required this.overview,
    required this.onOpenOverview,
  });

  final BudgetOverviewEntity overview;
  final ValueChanged<BudgetOverviewEntity> onOpenOverview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warningColor = isDark
        ? const Color(0xFFD6A72C)
        : const Color(0xFFD97706);

    final statusColor = overview.isExceeded
        ? colors.error
        : overview.isWarning
        ? warningColor
        : colors.primary;

    final statusLabel = overview.isExceeded
        ? 'Anggaran terlampaui'
        : overview.isWarning
        ? 'Perlu diperhatikan'
        : 'Pengeluaran terkendali';

    final statusIcon = overview.isExceeded
        ? Icons.error_outline_rounded
        : overview.isWarning
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline_rounded;

    return InkWell(
      onTap: () => onOpenOverview(overview),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(overview.spentRatio * 100).round()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: overview.spentRatio.clamp(0.0, 1.0),
              minHeight: 10,
              color: statusColor,
              backgroundColor: statusColor.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatRupiah(overview.totalExpense)} dari ${formatRupiah(overview.budgetLimit)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  overview.isExceeded
                      ? 'Lebih ${formatRupiah(overview.remaining.abs())}'
                      : 'Sisa ${formatRupiah(overview.remaining)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${formatDateShort(overview.periodStart)} – ${formatDateShort(overview.periodEnd)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.touch_app_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Detail',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warningColor = isDark
        ? const Color(0xFFD6A72C)
        : const Color(0xFFD97706);
    final statusColor = overview.isExceeded
        ? colors.error
        : overview.isWarning
        ? warningColor
        : colors.primary;

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
                '${formatDateShort(overview.periodStart)} – ${formatDateShort(overview.periodEnd)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.68)],
                  ),
                  borderRadius: BorderRadius.circular(22),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overview.spentRatio.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
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
                    child: BudgetMetric(
                      label: 'Transaksi',
                      value: '${overview.transactionCount}',
                      icon: Icons.receipt_long_outlined,
                      onTap: onOpenHistory == null
                          ? null
                          : () => onOpenHistory!(null),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BudgetMetric(
                      label: 'Rata-rata / hari',
                      value: formatRupiah(overview.averageDailyExpense),
                      icon: Icons.show_chart_rounded,
                      onTap: () => _showMetricDetail(
                        context,
                        title: 'Rata-rata pengeluaran harian',
                        message:
                            'Angka ini dihitung dari total pengeluaran yang sudah terjadi dibagi jumlah hari yang telah berjalan pada siklus ini.',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BudgetMetric(
                label: 'Estimasi akhir periode',
                value: formatRupiah(overview.projectedExpense),
                icon: Icons.insights_rounded,
                wide: true,
                onTap: () => _showMetricDetail(
                  context,
                  title: 'Estimasi akhir periode',
                  message:
                      'Proyeksi ini menggunakan rata-rata pengeluaran harian saat ini untuk memperkirakan total pengeluaran sampai akhir siklus.',
                ),
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
                  'Belum ada pengeluaran pada periode ini.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ...overview.topCategories.asMap().entries.map((entry) {
                  final item = entry.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: onOpenHistory == null
                        ? null
                        : () => onOpenHistory!(item.category),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    title: Text(
                      item.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Text(
                      formatRupiah(item.amount),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.error,
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Tutup'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMetricDetail(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onAction != null)
            FilledButton.tonal(
              onPressed: () {
                Navigator.pop(dialogContext);
                onAction();
              },
              child: Text(actionLabel ?? 'Lihat detail'),
            ),
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
    final colors = theme.colorScheme;

    final content = Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 10),
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

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}
