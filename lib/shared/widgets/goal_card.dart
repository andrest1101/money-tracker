import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/rupiah_formatter.dart';

enum _GoalAction { edit, archive, delete }

/// Kartu target tabungan — satu-satunya kartu "interaktif" di aplikasi.
///
/// Seluruh data masuk lewat parameter agar komponen tetap presentational dan
/// mudah diuji. Penghubung Riverpod dilakukan di layar Target.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.deadline,
    required this.daysUntilDeadline,
    this.isCompleted = false,
    this.isArchived = false,
    this.onAllocate,
    this.onEdit,
    this.onArchive,
    this.onDelete,
  });

  final String title;
  final double currentAmount;
  final double targetAmount;
  final DateTime deadline;
  final int daysUntilDeadline;
  final bool isCompleted;
  final bool isArchived;
  final VoidCallback? onAllocate;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  double get _progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0).toDouble();
  }

  double get _remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining < 0 ? 0 : remaining;
  }

  Color _progressColor(BuildContext context) {
    final colors = context.appColors;
    if (isCompleted) return colors.income;
    if (daysUntilDeadline < 0) return colors.danger;
    return Theme.of(context).colorScheme.primary;
  }

  ({String text, Color color}) _deadlineInfo(BuildContext context) {
    final colors = context.appColors;
    if (isCompleted) {
      return (text: 'Semua dana sudah terkumpul', color: colors.income);
    }
    if (daysUntilDeadline < 0) {
      return (
        text: '${AppStrings.goalOverdue} · ${-daysUntilDeadline} hari lalu',
        color: colors.danger,
      );
    }
    final suffix = '$daysUntilDeadline hari lagi';
    return (
      text: '${formatDateShort(deadline)} · $suffix',
      color: daysUntilDeadline <= 14
          ? colors.warningText
          : colors.textSecondary,
    );
  }

  bool get _hasMenu => onEdit != null || onArchive != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final progressColor = _progressColor(context);
    final deadlineInfo = _deadlineInfo(context);
    final percentage = '${(_progress * 100).round()}%';

    return Semantics(
      container: true,
      label:
          'Target $title, ${(_progress * 100).round()} persen terkumpul, '
          '${deadlineInfo.text}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.emoji_events_rounded
                          : Icons.savings_rounded,
                      color: progressColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          deadlineInfo.text,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: deadlineInfo.color,
                            fontWeight: daysUntilDeadline <= 14 || isCompleted
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      percentage,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (_hasMenu)
                    PopupMenuButton<_GoalAction>(
                      tooltip: AppStrings.goalActions,
                      icon: const Icon(Icons.more_horiz_rounded),
                      onSelected: (action) {
                        switch (action) {
                          case _GoalAction.edit:
                            onEdit?.call();
                          case _GoalAction.archive:
                            onArchive?.call();
                          case _GoalAction.delete:
                            onDelete?.call();
                        }
                      },
                      itemBuilder: (_) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: _GoalAction.edit,
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text(AppStrings.editGoal),
                            ),
                          ),
                        if (onArchive != null)
                          PopupMenuItem(
                            value: _GoalAction.archive,
                            child: ListTile(
                              leading: Icon(
                                isArchived
                                    ? Icons.unarchive_outlined
                                    : Icons.archive_outlined,
                              ),
                              title: Text(
                                isArchived
                                    ? AppStrings.unarchiveGoal
                                    : AppStrings.archiveGoal,
                              ),
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: _GoalAction.delete,
                            child: ListTile(
                              leading: Icon(Icons.delete_outline_rounded),
                              title: Text(AppStrings.deleteGoal),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _progress),
                duration: AppMotion.durationOf(context, AppDuration.progress),
                curve: AppMotion.standard,
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: colors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatRupiah(currentAmount)} terkumpul',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (!isCompleted)
                    Flexible(
                      child: Text(
                        '${formatRupiah(_remainingAmount)} lagi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              if (!isCompleted && onAllocate != null) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onAllocate,
                    child: const Text(AppStrings.allocateFund),
                  ),
                ),
              ],
              if (isCompleted) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.income.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 20,
                        color: colors.income,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        AppStrings.goalCompleted,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.income,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
