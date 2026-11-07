import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Wadah standar untuk bottom sheet Dompetku.
///
/// Widget ini membatasi tinggi maksimum ke 87% viewport, menjaga konten
/// tetap terpusat secara horizontal, dan membatasi lebar pada jendela lebar.
/// Konten pendek tidak dipaksa setinggi layar; sheet akan tumbuh sesuai
/// isinya, sedangkan konten panjang tetap dapat di-scroll di dalam batas ini.
class AppBottomSheetLayout extends StatelessWidget {
  const AppBottomSheetLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.maxContentWidth,
              maxHeight:
                  constraints.maxHeight * AppLayout.bottomSheetHeightFactor,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
