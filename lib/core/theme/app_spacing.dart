import 'package:flutter/widgets.dart';

/// Grid 4pt. Gunakan token ini, jangan angka lepas.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double section = 28;
  static const double xxl = 32;

  /// Padding horizontal standar layar.
  static const double screen = 20;

  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: screen,
  );
}

/// Hanya empat radius yang dipakai di seluruh aplikasi.
abstract final class AppRadius {
  static const double control = 12;
  static const double card = 16;
  static const double hero = 20;
  static const double pill = 999;
}

/// Elevation: kartu tidak punya shadow. Hanya FAB dan bottom sheet.
abstract final class AppElevation {
  static const double none = 0;
  static const double sheet = 8;
  static const double fab = 6;
}

/// Durasi motion standar (PRD 5.8).
abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration progress = Duration(milliseconds: 400);
  static const Duration counter = Duration(milliseconds: 600);
}

/// Batas lebar konten agar tidak melar di Windows/Web.
abstract final class AppLayout {
  static const double maxContentWidth = 680;
}
