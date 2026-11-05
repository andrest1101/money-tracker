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
    this.labelColor,
    this.valueColor,
    this.isMasked = false,
    this.maskedText = 'Rp •••',
  });

  final String label;
  final double amount;
  final AmountTone tone;
  final bool showSign;
  final CrossAxisAlignment alignment;
  final TextStyle? valueStyle;

  /// Warna label. Null berarti mengikuti [AppColors.textSecondary].
  final Color? labelColor;

  /// Warna nominal. Null berarti mengikuti [tone].
  final Color? valueColor;

  /// Menyembunyikan nominal (privacy mode).
  final bool isMasked;
  final String maskedText;

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
            color: labelColor ?? context.appColors.textSecondary,
          ),
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        if (isMasked)
          Semantics(
            label: '$label disembunyikan',
            child: ExcludeSemantics(
              child: Text(
                maskedText,
                style: (valueStyle ?? theme.textTheme.titleSmall)?.copyWith(
                  color: valueColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textAlign: textAlign,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        else
          AmountText(
            amount: amount,
            tone: tone,
            showSign: showSign,
            style: valueStyle ?? theme.textTheme.titleSmall,
            color: valueColor,
            textAlign: textAlign,
          ),
      ],
    );
  }
}
