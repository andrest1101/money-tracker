import 'package:flutter/material.dart';

import '../../domain/entities/transaction_entity.dart';

const Map<String, _CategoryStyle> _categoryStyles = {
  'Makanan': _CategoryStyle(Icons.restaurant, Color(0xFFFF6B6B)),
  'Transportasi': _CategoryStyle(Icons.directions_car, Color(0xFF4ECDC4)),
  'Bensin': _CategoryStyle(Icons.local_gas_station, Color(0xFFFF8C42)),
  'Pulsa & Kuota': _CategoryStyle(Icons.phone_android, Color(0xFF6C5CE7)),
  'Kesehatan & Perawatan': _CategoryStyle(
    Icons.health_and_safety,
    Color(0xFFE84393),
  ),
  'Hiburan': _CategoryStyle(Icons.sports_esports, Color(0xFFFF6B9D)),
  'Kos & Tagihan': _CategoryStyle(Icons.home, Color(0xFF00B894)),
  'Belanja': _CategoryStyle(Icons.shopping_bag, Color(0xFFE17055)),
  'Lainnya': _CategoryStyle(Icons.more_horiz, Color(0xFF636E72)),
  'Uang Kiriman': _CategoryStyle(Icons.account_balance, Color(0xFF00B894)),
  'Beasiswa': _CategoryStyle(Icons.school, Color(0xFF0984E3)),
  'Gaji Part-time': _CategoryStyle(Icons.work, Color(0xFF6C5CE7)),
  'Alokasi Tabungan': _CategoryStyle(Icons.savings, Color(0xFF00CEC9)),
};

class _CategoryStyle {
  const _CategoryStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    required this.type,
    this.size = 40,
  });

  final String category;
  final TransactionType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = _categoryStyles[category];
    final color =
        style?.color ??
        (type == TransactionType.expense
            ? Colors.red.shade400
            : Colors.green.shade400);
    final icon =
        style?.icon ??
        (type == TransactionType.expense ? Icons.north_east : Icons.south_west);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}
