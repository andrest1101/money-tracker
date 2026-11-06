import 'package:flutter/widgets.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

/// Animasi masuk yang tenang untuk konten satu layar.
///
/// Hanya berjalan sekali saat widget pertama kali dipasang: fade singkat dan
/// geser 8dp ke atas. Tidak ada blur, scale, atau gradient agar tetap ringan di
/// perangkat kelas menengah dan tidak mengulang setiap rebuild.
///
/// Saat reduced motion aktif, durasi menjadi nol dan konten langsung tampil di
/// posisi akhir.
class AppEntrance extends StatelessWidget {
  const AppEntrance({
    super.key,
    required this.child,
    this.offset = 8,
    this.duration = AppDuration.enter,
    this.curve = AppMotion.standard,
  });

  final Widget child;

  /// Jarak geser awal dalam logical pixel. 0 mematikan gerakan geser.
  final double offset;

  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = AppMotion.durationOf(context, duration);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: effectiveDuration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        // Hindari lapisan opacity saat animasi selesai.
        if (value >= 1) return child!;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
