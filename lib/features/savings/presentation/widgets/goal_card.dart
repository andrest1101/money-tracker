import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../providers/savings_providers.dart';
import 'edit_goal_sheet.dart';
import 'edit_allocation_sheet.dart';

enum _GoalAction { edit, archive, delete }

class GoalCard extends ConsumerStatefulWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.onAllocate,
    required this.onDelete,
    required this.onArchive,
  });

  final SavingsGoalEntity goal;
  final VoidCallback onAllocate;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  @override
  ConsumerState<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends ConsumerState<GoalCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _showEditAllocationSheet(BuildContext context, allocation) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          EditAllocationSheet(transaction: allocation, goal: widget.goal),
    );
  }

  void _showEditGoalSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => EditGoalSheet(goal: widget.goal),
    );
  }

  Color _progressColor(double progress, ColorScheme cs) {
    if (progress >= 1.0) return cs.tertiary; // completed
    if (progress >= 0.7) return cs.primary; // near completion
    if (progress >= 0.4) return cs.secondary; // midway
    return cs.primary.withValues(alpha: 0.8); // early stage
  }

  ({String label, Color color, IconData icon}) _deadlineStatus(
    SavingsGoalEntity goal,
    ColorScheme cs,
  ) {
    if (goal.isOverdue) {
      return (
        label: 'Tenggat terlewat',
        color: cs.error,
        icon: Icons.warning_amber_rounded,
      );
    }
    if (goal.isDeadlineNear) {
      return (
        label: '${goal.daysUntilDeadline} hari lagi',
        color: cs.tertiary,
        icon: Icons.schedule_rounded,
      );
    }
    return (
      label: 'Tenggat ${formatDateShort(goal.deadline)}',
      color: cs.onSurfaceVariant,
      icon: Icons.calendar_today_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final goal = widget.goal;
    final isCompleted = goal.isCompleted;
    final allocations = ref.watch(allocationTransactionsProvider(goal.id));
    final allocationSummary = ref.watch(allocationSummaryProvider(goal.id));
    final progress = goal.progress;
    final progressColor = _progressColor(progress, cs);
    final deadlineStatus = _deadlineStatus(goal, cs);

    return Card(
      elevation: isCompleted ? 0 : 1,
      shadowColor: cs.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isCompleted
            ? BorderSide(color: cs.tertiary.withValues(alpha: 0.4), width: 1.5)
            : BorderSide.none,
      ),
      color: isCompleted ? cs.tertiary.withValues(alpha: 0.05) : cs.surface,
      child: Column(
        children: [
          // ── Main Card Content ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + progress % + delete button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: icon + title
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: progressColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.emoji_events_rounded
                                  : Icons.savings_rounded,
                              color: progressColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? cs.tertiary
                                        : cs.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isCompleted)
                                  Text(
                                    'Target tercapai!',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.tertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                else
                                  Row(
                                    children: [
                                      Icon(
                                        deadlineStatus.icon,
                                        size: 13,
                                        color: deadlineStatus.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        deadlineStatus.label,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: deadlineStatus.color,
                                              fontWeight:
                                                  goal.isOverdue ||
                                                      goal.isDeadlineNear
                                                  ? FontWeight.w600
                                                  : null,
                                            ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right: percent + delete
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: progressColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        PopupMenuButton<_GoalAction>(
                          tooltip: 'Aksi target',
                          icon: const Icon(Icons.more_horiz_rounded),
                          onSelected: (action) {
                            switch (action) {
                              case _GoalAction.edit:
                                _showEditGoalSheet(context);
                              case _GoalAction.archive:
                                widget.onArchive();
                              case _GoalAction.delete:
                                widget.onDelete();
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: _GoalAction.edit,
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Edit target'),
                              ),
                            ),
                            PopupMenuItem(
                              value: _GoalAction.archive,
                              child: ListTile(
                                leading: Icon(
                                  widget.goal.isArchived
                                      ? Icons.unarchive_outlined
                                      : Icons.archive_outlined,
                                ),
                                title: Text(
                                  widget.goal.isArchived
                                      ? 'Kembalikan dari arsip'
                                      : 'Arsipkan target',
                                ),
                              ),
                            ),
                            const PopupMenuItem(
                              value: _GoalAction.delete,
                              child: ListTile(
                                leading: Icon(Icons.delete_outline_rounded),
                                title: Text('Hapus target'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: progressColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 10),

                // Amount row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatRupiah(goal.currentAmount),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                          ),
                        ),
                        Text(
                          'dari ${formatRupiah(goal.targetAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!isCompleted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatRupiah(goal.remainingAmount),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            'lagi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Allocate button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onAllocate,
                    style: FilledButton.styleFrom(
                      backgroundColor: progressColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      isCompleted
                          ? Icons.add_circle_outline_rounded
                          : Icons.account_balance_wallet_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isCompleted ? 'Tambah Lagi' : 'Alokasikan Dana',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Allocation History expandable ──────────────────────────
          if (allocationSummary.count > 0) ...[
            Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
            InkWell(
              onTap: _toggleExpand,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 16, color: progressColor),
                    const SizedBox(width: 8),
                    Text(
                      'Aktivitas Alokasi',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: progressColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${allocationSummary.count}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Total ${formatRupiah(allocationSummary.totalAmount)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (allocationSummary.latest != null)
                    Text(
                      'Terakhir ${formatDateShort(allocationSummary.latest!.date)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: allocations.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 12,
                    color: cs.outlineVariant.withValues(alpha: 0.25),
                  ),
                  itemBuilder: (context, index) {
                    final tx = allocations[index];
                    return InkWell(
                      onTap: () => _showEditAllocationSheet(context, tx),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: progressColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.savings_outlined,
                                size: 18,
                                color: progressColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatRupiah(tx.amount),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        formatDateShort(tx.date),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                      if (tx.note.isNotEmpty) ...[
                                        Text(
                                          '  •  ',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            tx.note,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
