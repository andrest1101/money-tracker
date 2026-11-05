import 'package:flutter/material.dart';

/// Warna semantik yang tidak disediakan langsung oleh [ColorScheme].
///
/// Sumber kebenaran warna peran (primary, surface, outline, dll.) tetap
/// [ColorScheme]. Kelas ini hanya menyimpan warna yang punya arti khusus
/// di produk: pemasukan, bahaya, dan peringatan.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.income,
    required this.danger,
    required this.warning,
    required this.warningText,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;

  /// Pemasukan, progres target yang tercapai, status aman.
  final Color income;

  /// Overspending, hapus data, error.
  final Color danger;

  /// Deadline dekat atau anggaran siaga.
  final Color warning;

  /// Versi [warning] yang aman dibaca sebagai teks di atas surface.
  final Color warningText;

  static const AppColors light = AppColors(
    background: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEDF0F4),
    outline: Color(0xFFDDE2E8),
    textPrimary: Color(0xFF151B23),
    textSecondary: Color(0xFF596575),
    income: Color(0xFF12804A),
    danger: Color(0xFFC73A32),
    warning: Color(0xFFE8A317),
    warningText: Color(0xFF8A5A12),
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF0E1218),
    surface: Color(0xFF171C23),
    surfaceVariant: Color(0xFF202833),
    outline: Color(0xFF303B48),
    textPrimary: Color(0xFFE9EDF2),
    textSecondary: Color(0xFFA0AAB6),
    income: Color(0xFF65C58A),
    danger: Color(0xFFFF8A80),
    warning: Color(0xFFF5C451),
    warningText: Color(0xFFF5C451),
  );

  static AppColors of(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    assert(colors != null, 'AppColors belum terdaftar di ThemeData.');
    return colors ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.dark
            : AppColors.light);
  }

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? outline,
    Color? textPrimary,
    Color? textSecondary,
    Color? income,
    Color? danger,
    Color? warning,
    Color? warningText,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      income: income ?? this.income,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      warningText: warningText ?? this.warningText,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      income: Color.lerp(income, other.income, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors => AppColors.of(this);
}
