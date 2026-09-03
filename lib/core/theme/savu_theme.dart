import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class SavuTheme {
  // ── Seed ──────────────────────────────────────────────────────────────
  static const _seedColor = Color(0xFF0F766E);

  // ── Light palette ─────────────────────────────────────────────────────
  static const _lightBg = Color(0xFFF5F8F7);

  // ── Dark palette (clean charcoal + teal accents, fully manual) ─────────
  static const _darkBg = Color(0xFF121417); // deep charcoal scaffold
  static const _darkSurface = Color(0xFF1C2026); // solid slate cards / sheets
  static const _darkSurfaceHigh = Color(0xFF1C2026); // elevated inputs / chips
  static const _darkSurfaceLow = Color(0xFF1C2026); // inset containers

  static const _darkPrimary = Color(0xFF2DD4BF); // bright teal accent
  static const _darkOnPrimary = Color(0xFF121417);
  static const _darkPrimaryContainer = Color(0xFF2DD4BF); // solid active state
  static const _darkOnPrimaryContainer = Color(0xFF121417);

  static const _darkSecondary = Color(0xFF2DD4BF); // consistent teal accent
  static const _darkOnSecondary = Color(0xFF121417);
  static const _darkSecondaryContainer = Color(0xFF1C2026);
  static const _darkOnSecondaryContainer = Color(0xFFFFFFFF);

  static const _darkTertiary = Color(0xFF2DD4BF);
  static const _darkError = Color(0xFFEF5350);
  static const _darkOnError = Color(0xFFFFFFFF);

  static const _darkOnSurface = Color(0xFFFFFFFF); // pure white
  static const _darkOnSurfaceVar = Color(0xFF9CA3AF); // muted grey
  static const _darkOutline = Color(0xFF3A414A); // neutral visible border
  static const _darkOutlineVar = Color(0xFF2B3138); // neutral subtle border
  static const _darkInverseSurface = Color(0xFFF3F4F6);
  static const _darkOnInverseSurface = Color(0xFF121417);
  static const _darkInversePrimary = Color(0xFF0F766E);

  // ── Public API ────────────────────────────────────────────────────────
  static ThemeData light() => _buildLight();
  static ThemeData dark() => _buildDark();

  // ══════════════════════════════════════════════════════════════════════
  //  LIGHT THEME  — generated from seed (works well already)
  // ══════════════════════════════════════════════════════════════════════
  static ThemeData _buildLight() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      surface: _lightBg,
    );
    final outline = scheme.outline.withValues(alpha: .22);

    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: scheme.primary,
        elevation: 1,
        shadowColor: scheme.shadow.withValues(alpha: .12),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: outline),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: scheme.surface.withValues(alpha: .94),
        surfaceTintColor: scheme.primary,
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: .18),
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.primary,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.all(16),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  DARK THEME  — fintech-grade manual palette
  // ══════════════════════════════════════════════════════════════════════
  static ThemeData _buildDark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      // ── Core ──
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,
      // ── Secondary ──
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      secondaryContainer: _darkSecondaryContainer,
      onSecondaryContainer: _darkOnSecondaryContainer,
      // ── Tertiary ──
      tertiary: _darkTertiary,
      onTertiary: _darkOnPrimary,
      tertiaryContainer: _darkPrimaryContainer,
      onTertiaryContainer: _darkOnPrimaryContainer,
      // ── Error ──
      error: _darkError,
      onError: _darkOnError,
      errorContainer: Color(0xFF5C1A1A),
      onErrorContainer: Color(0xFFFFCDD2),
      // ── Surfaces ──
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceVar,
      surfaceContainerHighest: _darkSurfaceHigh,
      surfaceContainerHigh: _darkSurfaceHigh,
      surfaceContainerLow: _darkSurfaceLow,
      surfaceContainer: _darkSurface,
      surfaceDim: _darkBg,
      surfaceBright: Color(0xFF24282E),
      outline: _darkOutline,
      outlineVariant: _darkOutlineVar,
      // ── Misc ──
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: _darkInverseSurface,
      onInverseSurface: _darkOnInverseSurface,
      inversePrimary: _darkInversePrimary,
    );

    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(bodyColor: _darkOnSurface, displayColor: _darkOnSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      textTheme: textTheme,
      scaffoldBackgroundColor: _darkBg,
      visualDensity: VisualDensity.standard,
      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
        ),
      ),
      // ── Cards: flat + solid surface + subtle border ──
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      // ── Inputs ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      // ── Buttons ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 4,
        highlightElevation: 8,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      // ── Chips ──
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: scheme.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      // ── Navigation bar ──
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
      // ── Bottom sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        modalBarrierColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.all(16),
      ),
      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      // ── ListTile ──
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
