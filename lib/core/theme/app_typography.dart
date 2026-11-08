import 'package:flutter/material.dart';

/// Token tipografi Savu.
///
/// Semua nominal wajib memakai [FontFeature.tabularFigures] agar lebar digit
/// stabil saat angka berubah (animasi hitung naik atau privacy mode).
abstract final class AppTypography {
  static const String fontFamily = 'PlusJakartaSans';

  static TextTheme textTheme({
    required Color primaryText,
    required Color secondaryText,
  }) {
    TextStyle style(
      double size,
      double lineHeight,
      FontWeight weight, {
      required Color color,
      double letterSpacing = 0,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color,
      );
    }

    return TextTheme(
      displayLarge: style(
        40,
        46,
        FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.8,
      ).tabular,
      displayMedium: style(
        36,
        42,
        FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.7,
      ).tabular,
      displaySmall: style(
        34,
        40,
        FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.6,
      ).tabular,
      headlineLarge: style(
        28,
        34,
        FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      headlineMedium: style(
        24,
        30,
        FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.4,
      ),
      headlineSmall: style(
        22,
        28,
        FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.3,
      ),
      titleLarge: style(
        22,
        28,
        FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.3,
      ),
      titleMedium: style(
        16,
        24,
        FontWeight.w600,
        color: primaryText,
        letterSpacing: -0.1,
      ),
      titleSmall: style(
        14,
        20,
        FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: style(16, 24, FontWeight.w400, color: primaryText),
      bodyMedium: style(14, 20, FontWeight.w400, color: primaryText),
      bodySmall: style(12, 16, FontWeight.w400, color: secondaryText),
      labelLarge: style(14, 20, FontWeight.w600, color: primaryText),
      labelMedium: style(12, 16, FontWeight.w500, color: secondaryText),
      labelSmall: style(12, 16, FontWeight.w500, color: secondaryText),
    );
  }
}

/// Style siap pakai untuk komponen nominal dan label kecil.
abstract final class AppTextStyles {
  static const TextStyle amountHero = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountRow = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Nominal pada field input transaksi dengan digit sejajar.
  static const TextStyle amountInput = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );
}

extension TabularTextStyle on TextStyle {
  TextStyle get tabular => copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
