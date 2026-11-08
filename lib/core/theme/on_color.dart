import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Foreground yang kontras di atas warna arbitrer.
///
/// Dipakai untuk elemen yang warnanya statis antara light dan dark (mis.
/// avatar preset atau aksen ilustrasi onboarding). Di sini foreground ikut
/// luminance latar, bukan skema tema, supaya hasilnya selalu terbaca.
Color onArbitraryColor(Color background) {
  return background.computeLuminance() > .5
      ? AppColors.light.textPrimary
      : AppColors.light.surface;
}
