import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Latar bersama seluruh halaman.
///
/// Tanpa gradient dan tanpa dekorasi. Kedalaman visual datang dari tone
/// permukaan kartu di atas background ini.
class AppPageBackground extends StatelessWidget {
  const AppPageBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: context.appColors.background, child: child);
  }
}
