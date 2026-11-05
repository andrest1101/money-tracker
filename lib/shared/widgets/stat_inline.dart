import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'amount_text.dart';

/// Label kecil + nominal yang dipakai berdampingan tanpa kotak.
///
/// Cocok untuk isi hero saldo atau ringkasan insight.
class StatInline extends StatelessWidget {
  const StatInline({
    super.key,
    required this.label,
    required this.amount,
    this.tone = AmountTone.neutral,
    this.showSign = false,
    this.alignment = CrossAxisAlignment.start,
    this.valueStyle,
  });

  final String label;
  final double amount;
  final AmountTone tone;
  final bool showSign;
  final CrossAxisAlignment alignment;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textAlign = switch (alignment) {
      CrossAxisAlignment.end => TextAlign.end,
      CrossAxisAlignment.center => TextAlign.center,
      _ => TextAlign.start,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: context.appColors.textSecondary,
          ),
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        AmountText(
          amount: amount,
          tone: tone,
          showSign: showSign,
          style: valueStyle ?? theme.textTheme.titleSmall,
          textAlign: textAlign,
        ),
      ],
    );
  }
}
