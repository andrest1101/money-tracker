import 'package:flutter/widgets.dart';

/// Satu pintu untuk menghormati pengaturan reduced motion perangkat.
///
/// Android melaporkan `animator_duration_scale == 0` sebagai
/// [MediaQueryData.disableAnimations]. Framework memang sudah memperpendek
/// durasi animasi pada kondisi itu, tetapi animasi buatan sendiri tetap perlu
/// dipangkas eksplisit agar tidak ada gerakan yang tersisa.
abstract final class AppMotion {
  /// `true` bila pengguna meminta animasi dikurangi/dimatikan.
  static bool isReduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [base] bila animasi boleh berjalan, atau [Duration.zero] bila tidak.
  static Duration durationOf(BuildContext context, Duration base) =>
      isReduced(context) ? Duration.zero : base;

  /// Kurva standar Savu: masuk cepat lalu melambat, tanpa overshoot.
  static const Curve standard = Curves.easeOutCubic;
}
