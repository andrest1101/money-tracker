import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/theme/app_colors.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/core/theme/app_typography.dart';
import 'package:savu/core/theme/category_palette.dart';

void main() {
  group('AppTheme', () {
    test('mendaftarkan AppColors pada tema', () {
      final light = AppTheme.light();

      expect(light.extension<AppColors>(), AppColors.light);
      expect(light.brightness, Brightness.light);
    });

    test('memakai Plus Jakarta Sans yang di-bundle', () {
      expect(AppTypography.fontFamily, 'PlusJakartaSans');
      expect(
        AppTheme.light().textTheme.bodyMedium?.fontFamily,
        AppTypography.fontFamily,
      );
    });

    test('kartu tidak memakai elevation', () {
      expect(AppTheme.light().cardTheme.elevation, 0);
    });

    test('kontras teks inti memenuhi minimal 4.5:1', () {
      final cases = <({String label, Color foreground, Color background})>[
        (
          label: 'textPrimary / background',
          foreground: AppColors.light.textPrimary,
          background: AppColors.light.background,
        ),
        (
          label: 'textSecondary / surface',
          foreground: AppColors.light.textSecondary,
          background: AppColors.light.surface,
        ),
        (
          label: 'onPrimary / primary',
          foreground: AppTheme.light().colorScheme.onPrimary,
          background: AppTheme.light().colorScheme.primary,
        ),
        (
          label: 'income / surface',
          foreground: AppColors.light.income,
          background: AppColors.light.surface,
        ),
        (
          label: 'success / surface',
          foreground: AppColors.light.success,
          background: AppColors.light.surface,
        ),
        (
          label: 'danger / surface',
          foreground: AppColors.light.danger,
          background: AppColors.light.surface,
        ),
        (
          label: 'warningText / surface',
          foreground: AppColors.light.warningText,
          background: AppColors.light.surface,
        ),
        (
          label: 'hero text / primary container',
          foreground: AppTheme.light().colorScheme.onPrimaryContainer,
          background: AppTheme.light().colorScheme.primaryContainer,
        ),
      ];

      for (final item in cases) {
        expect(
          _contrastRatio(item.foreground, item.background),
          greaterThanOrEqualTo(4.5),
          reason: item.label,
        );
      }
    });
  });

  group('CategoryPalette', () {
    test('memetakan kategori utama secara stabil', () {
      expect(CategoryPalette.toneFor('Makanan'), CategoryTone.terracotta);
      expect(CategoryPalette.toneFor('Transportasi'), CategoryTone.blue);
      expect(CategoryPalette.toneFor('Bensin'), CategoryTone.amber);
      expect(CategoryPalette.toneFor('Lainnya'), CategoryTone.slate);
      expect(
        CategoryPalette.toneFor('Kesehatan & Perawatan'),
        CategoryTone.rose,
      );
    });

    test('kategori custom selalu mendapat tone yang sama', () {
      final first = CategoryPalette.toneFor('Servis Motor');
      final second = CategoryPalette.toneFor('Servis Motor');

      expect(first, second);
      expect(first, isNot(CategoryTone.slate));
    });

    test('latar ikon memakai opasitas 14 persen', () {
      final color = CategoryPalette.background('Makanan');
      expect(color.a, closeTo(CategoryPalette.backgroundOpacity, 0.001));
    });
  });
}

double _contrastRatio(Color a, Color b) {
  final light = a.computeLuminance() > b.computeLuminance()
      ? a.computeLuminance()
      : b.computeLuminance();
  final dark = a.computeLuminance() > b.computeLuminance()
      ? b.computeLuminance()
      : a.computeLuminance();
  return (light + 0.05) / (dark + 0.05);
}
