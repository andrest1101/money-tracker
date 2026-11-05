import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/rupiah_formatter.dart';

/// Arti warna sebuah nominal.
enum AmountTone {
  /// Teks utama. Dipakai untuk nominal netral.
  neutral,

  /// Pemasukan: hijau `income`.
  income,

  /// Pengeluaran: tetap `textPrimary`, bukan merah (aturan Riwayat).
  expense,

  /// Nominal bahaya: overspending atau selisih negatif.
  danger,

  /// Nominal peringatan: mendekati batas.
  warning,

  /// Nominal utama yang mengikuti warna brand.
  primary,
}

/// Nominal Rupiah dengan angka tabular dan label pembaca layar.
///
/// Format selalu `Rp 1.250.000`. Saat [showSign] aktif, pemasukan memakai
/// `+` dan pengeluaran memakai tanda minus sebenarnya (U+2212).
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.tone = AmountTone.neutral,
    this.showSign = false,
    this.style,
    this.color,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
  });

  final double amount;
  final AmountTone tone;

  /// Menampilkan `+` untuk [AmountTone.income] dan `−` untuk pengeluaran.
  final bool showSign;

  /// Gaya dasar. Warna dari [tone] tetap dipakai kecuali [color] diisi.
  final TextStyle? style;

  /// Warna kustom. Jika null, warna mengikuti [tone].
  final Color? color;
  final int maxLines;
  final TextAlign textAlign;

  bool get _isNegativeAmount => amount < 0;

  String get _displaySign {
    if (showSign) {
      return switch (tone) {
        AmountTone.income => '+',
        AmountTone.expense || AmountTone.danger => '−',
        AmountTone.neutral ||
        AmountTone.warning ||
        AmountTone.primary => _isNegativeAmount ? '−' : '',
      };
    }
    return _isNegativeAmount ? '−' : '';
  }

  String get _semanticsLabel {
    if (!showSign) return formatRupiahSpoken(amount);
    final prefix = switch (tone) {
      AmountTone.income => 'plus ',
      AmountTone.expense || AmountTone.danger => 'minus ',
      AmountTone.neutral ||
      AmountTone.warning ||
      AmountTone.primary => _isNegativeAmount ? 'minus ' : '',
    };
    return '$prefix${formatRupiahSpoken(amount.abs())}';
  }

  Color _toneColor(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return switch (tone) {
      AmountTone.neutral || AmountTone.expense => colors.textPrimary,
      AmountTone.income => colors.income,
      AmountTone.danger => colors.danger,
      AmountTone.warning => colors.warningText,
      AmountTone.primary => scheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = style ?? theme.textTheme.titleSmall ?? const TextStyle();
    final resolvedStyle = baseStyle
        .copyWith(
          color: color ?? _toneColor(context),
          fontFeatures: const [FontFeature.tabularFigures()],
        )
        .tabular;

    return Semantics(
      label: _semanticsLabel,
      child: ExcludeSemantics(
        child: Text(
          '$_displaySign${formatRupiah(amount.abs())}',
          style: resolvedStyle,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          softWrap: false,
        ),
      ),
    );
  }
}
