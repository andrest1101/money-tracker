import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'amount_text.dart';
import 'category_icon.dart';

/// Baris transaksi tanpa kartu.
///
/// Parent cukup menaruh widget ini langsung di dalam list; padding horizontal
/// dan hairline sudah diurus di sini. Pemasukan berwarna `income` dengan `+`,
/// pengeluaran memakai `textPrimary` dengan `−` sesuai aturan Riwayat.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.category,
    required this.amount,
    required this.isExpense,
    this.note = '',
    this.timeLabel,
    this.onTap,
    this.onDismissed,
    this.dismissKey,
    this.showDivider = true,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
  });

  final String category;
  final double amount;
  final bool isExpense;
  final String note;
  final String? timeLabel;
  final VoidCallback? onTap;

  /// Dipanggil saat baris di-swipe. Pemanggil bertanggung jawab menampilkan
  /// dialog konfirmasi; baris tidak langsung hilang.
  final VoidCallback? onDismissed;
  final String? dismissKey;
  final bool showDivider;

  /// Padding luar. Default mengikuti layar penuh. Set [EdgeInsets.zero] saat
  /// baris dipakai di section yang sudah punya padding horizontal sendiri.
  final EdgeInsetsGeometry padding;

  String? get _subtitle {
    final parts = <String>[
      if (timeLabel != null && timeLabel!.isNotEmpty) timeLabel!,
      if (note.isNotEmpty) note,
    ];
    return parts.isEmpty ? null : parts.join('  •  ');
  }

  Widget _buildDismissBackground(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screen,
        vertical: AppSpacing.xxs,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: colors.danger,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: scheme.onError, size: 22),
          const SizedBox(width: AppSpacing.xs),
          Text(
            AppStrings.delete,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: scheme.onError),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final subtitle = _subtitle;

    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.control),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.xxs,
              ),
              child: Row(
                children: [
                  CategoryIcon(category: category, size: 40),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: AmountText(
                          amount: amount,
                          tone: isExpense
                              ? AmountTone.expense
                              : AmountTone.income,
                          showSign: true,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showDivider)
            Divider(height: 1, thickness: 1, indent: 56, color: colors.outline),
        ],
      ),
    );

    if (onDismissed == null) return content;

    return Dismissible(
      key: ValueKey(dismissKey ?? category),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(context),
      secondaryBackground: _buildDismissBackground(context),
      confirmDismiss: (_) async {
        onDismissed!.call();
        return false;
      },
      child: content,
    );
  }
}
