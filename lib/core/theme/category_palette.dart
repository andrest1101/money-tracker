import 'package:flutter/material.dart';

/// Delapan hue redup untuk kategori.
///
/// Pemetaan kategori ke warna harus stabil agar ikon, legenda, dan segmen
/// bagan selalu memakai warna yang sama. "Lainnya" selalu slate.
enum CategoryTone {
  terracotta(Color(0xFFD9685A), Color(0xFFE8897D)),
  blue(Color(0xFF3E86C8), Color(0xFF6BA5DC)),
  amber(Color(0xFFE0A030), Color(0xFFEDBB62)),
  green(Color(0xFF6FAE5B), Color(0xFF8FC97E)),
  violet(Color(0xFF8B73C9), Color(0xFFA996DA)),
  teal(Color(0xFF2FA9A0), Color(0xFF55C4BC)),
  rose(Color(0xFFD9709A), Color(0xFFE894B4)),
  slate(Color(0xFF7C8A96), Color(0xFF9AA7B2));

  const CategoryTone(this.light, this.dark);

  final Color light;
  final Color dark;

  Color colorFor(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}

abstract final class CategoryPalette {
  /// Warna latar ikon = warna kategori dengan opasitas 14%.
  static const double backgroundOpacity = 0.14;

  static const Map<String, CategoryTone> _mapping = {
    'makanan': CategoryTone.terracotta,
    'transportasi': CategoryTone.blue,
    'bensin': CategoryTone.amber,
    'pulsa & kuota': CategoryTone.violet,
    'kesehatan & perawatan': CategoryTone.rose,
    'hiburan': CategoryTone.teal,
    'kos & tagihan': CategoryTone.green,
    'belanja': CategoryTone.blue,
    'lainnya': CategoryTone.slate,
    'uang kiriman': CategoryTone.green,
    'beasiswa': CategoryTone.blue,
    'gaji part-time': CategoryTone.amber,
    'alokasi tabungan': CategoryTone.teal,
  };

  /// Fallback untuk kategori custom: jangan pernah memakai slate agar
  /// kategori baru tetap terlihat berbeda dari "Lainnya".
  static const List<CategoryTone> _fallback = [
    CategoryTone.terracotta,
    CategoryTone.blue,
    CategoryTone.amber,
    CategoryTone.green,
    CategoryTone.violet,
    CategoryTone.teal,
    CategoryTone.rose,
  ];

  static CategoryTone toneFor(String category) {
    final key = _normalize(category);
    final mapped = _mapping[key];
    if (mapped != null) return mapped;
    final index = _stableHash(key) % _fallback.length;
    return _fallback[index];
  }

  static Color color(String category, Brightness brightness) {
    return toneFor(category).colorFor(brightness);
  }

  static Color background(String category, Brightness brightness) {
    return color(category, brightness).withValues(alpha: backgroundOpacity);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Hash deterministik lintas platform (hindari String.hashCode).
  static int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }
}
