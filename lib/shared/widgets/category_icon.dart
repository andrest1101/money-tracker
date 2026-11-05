import 'package:flutter/material.dart';

import '../../core/theme/category_palette.dart';

const Map<String, IconData> _categoryIcons = {
  'Makanan': Icons.restaurant_rounded,
  'Transportasi': Icons.directions_car_rounded,
  'Bensin': Icons.local_gas_station_rounded,
  'Pulsa & Kuota': Icons.phone_android_rounded,
  'Kesehatan & Perawatan': Icons.health_and_safety_rounded,
  'Hiburan': Icons.sports_esports_rounded,
  'Kos & Tagihan': Icons.home_rounded,
  'Belanja': Icons.shopping_bag_rounded,
  'Lainnya': Icons.more_horiz_rounded,
  'Uang Kiriman': Icons.account_balance_rounded,
  'Beasiswa': Icons.school_rounded,
  'Gaji Part-time': Icons.work_rounded,
  'Alokasi Tabungan': Icons.savings_rounded,
};

/// Lingkaran tonal 40dp berisi ikon kategori.
///
/// Warna diambil dari [CategoryPalette] agar ikon, legenda, dan segmen bagan
/// selalu konsisten. Kategori custom mendapat tone deterministik.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 40,
    this.icon,
    this.semanticLabel,
  });

  final String category;
  final double size;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = CategoryPalette.color(category, brightness);
    final background = CategoryPalette.background(category, brightness);
    final resolvedIcon = icon ?? _categoryIcons[category] ?? Icons.receipt_long;

    return Semantics(
      label: semanticLabel ?? 'Kategori $category',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(resolvedIcon, size: size * 0.5, color: color),
        ),
      ),
    );
  }
}
