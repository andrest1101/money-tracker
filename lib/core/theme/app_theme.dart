import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Tema Savu v2.
///
/// Prinsip:
/// - Satu sumber kebenaran warna peran di [ColorScheme].
/// - Warna semantik produk di [AppColors].
/// - Tanpa gradient. Kedalaman dari tone permukaan dan hairline.
/// - Tanpa elevation pada kartu.
abstract final class AppTheme {
  static ThemeData light() => _build(brightness: Brightness.light);

  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final scheme = isDark ? _darkScheme() : _lightScheme();
    final textTheme = AppTypography.textTheme(
      primaryText: colors.textPrimary,
      secondaryText: colors.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      visualDensity: VisualDensity.standard,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.none,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.none,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: colors.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
        prefixIconColor: colors.textSecondary,
        suffixIconColor: colors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colors.danger, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: colors.surfaceVariant,
          disabledForegroundColor: colors.textSecondary,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: colors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: colors.textPrimary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: scheme.primaryContainer,
        disabledColor: colors.surfaceVariant,
        side: BorderSide(color: colors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.none,
        shadowColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? scheme.onPrimaryContainer
                : colors.textSecondary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected
                ? scheme.onPrimaryContainer
                : colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black54,
        showDragHandle: true,
        dragHandleColor: colors.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.md),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: AppElevation.fab,
        highlightElevation: AppElevation.fab,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: colors.surfaceVariant,
        circularTrackColor: colors.surfaceVariant,
      ),
    );
  }

  static ColorScheme _lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0B6B61),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD5EFEA),
      onPrimaryContainer: Color(0xFF083F39),
      secondary: Color(0xFF3F7D75),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFDCEEE9),
      onSecondaryContainer: Color(0xFF0B2E2A),
      tertiary: Color(0xFF2F6F66),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFD5EFEA),
      onTertiaryContainer: Color(0xFF083F39),
      error: Color(0xFFC73A32),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFBE3E0),
      onErrorContainer: Color(0xFF5C1A1A),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF121A18),
      onSurfaceVariant: Color(0xFF5B6764),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFAFBFA),
      surfaceContainer: Color(0xFFF7F8F7),
      surfaceContainerHigh: Color(0xFFF2F5F3),
      surfaceContainerHighest: Color(0xFFEEF1EF),
      surfaceDim: Color(0xFFE9EDEB),
      surfaceBright: Color(0xFFFFFFFF),
      outline: Color(0xFFE1E5E3),
      outlineVariant: Color(0xFFEDF0EE),
      shadow: Color(0xFF000000),
      scrim: Color(0x8A000000),
      inverseSurface: Color(0xFF121A18),
      onInverseSurface: Color(0xFFF7F8F7),
      inversePrimary: Color(0xFF5CCFBF),
    );
  }

  static ColorScheme _darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF5CCFBF),
      onPrimary: Color(0xFF00201C),
      primaryContainer: Color(0xFF12403B),
      onPrimaryContainer: Color(0xFFC9F4EC),
      secondary: Color(0xFF8FD8CE),
      onSecondary: Color(0xFF00201C),
      secondaryContainer: Color(0xFF16332F),
      onSecondaryContainer: Color(0xFFC9F4EC),
      tertiary: Color(0xFF8FD8CE),
      onTertiary: Color(0xFF00201C),
      tertiaryContainer: Color(0xFF12403B),
      onTertiaryContainer: Color(0xFFC9F4EC),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF3B0907),
      errorContainer: Color(0xFF5C1A1A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF161C1A),
      onSurface: Color(0xFFE8EEEC),
      onSurfaceVariant: Color(0xFF9AA8A4),
      surfaceContainerLowest: Color(0xFF0B0F0E),
      surfaceContainerLow: Color(0xFF131917),
      surfaceContainer: Color(0xFF1A211E),
      surfaceContainerHigh: Color(0xFF1E2623),
      surfaceContainerHighest: Color(0xFF222B27),
      surfaceDim: Color(0xFF0E1311),
      surfaceBright: Color(0xFF242E2A),
      outline: Color(0xFF2A3431),
      outlineVariant: Color(0xFF202824),
      shadow: Color(0xFF000000),
      scrim: Color(0x8A000000),
      inverseSurface: Color(0xFFE8EEEC),
      onInverseSurface: Color(0xFF0E1311),
      inversePrimary: Color(0xFF0B6B61),
    );
  }
}
