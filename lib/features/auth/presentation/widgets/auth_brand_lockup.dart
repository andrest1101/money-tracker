import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Ukuran lockup brand yang dipakai di alur autentikasi.
///
/// [header] untuk AppBar dan halaman status, [hero] untuk pembuka landing.
enum AuthBrandSize { header, hero }

/// Satu-satunya representasi logo + wordmark Dompetku di alur autentikasi.
///
/// Semua halaman memakai komponen ini agar rasio ikon, radius, dan gaya
/// wordmark tidak lagi berbeda-beda antar layar.
class AuthBrandLockup extends StatelessWidget {
  const AuthBrandLockup({
    super.key,
    this.size = AuthBrandSize.header,
    this.centered = false,
  });

  final AuthBrandSize size;

  /// Hanya berpengaruh pada varian [AuthBrandSize.hero].
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isHero = size == AuthBrandSize.hero;

    final tile = isHero ? 64.0 : 36.0;
    final inset = isHero ? 5.0 : 3.0;
    final tileRadius = isHero ? AppRadius.card : AppRadius.control;

    final wordmarkStyle =
        (isHero ? theme.textTheme.titleMedium : theme.textTheme.labelLarge)
            ?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: isHero ? 1.6 : 1.2,
              height: 1.1,
            );

    final logo = Container(
      width: tile,
      height: tile,
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(tileRadius),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tileRadius - inset),
        child: Image.asset(
          'assets/images/app_icon.png',
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
      ),
    );

    final wordmark = Text(
      'DOMPETKU',
      textAlign: isHero && centered ? TextAlign.center : TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: wordmarkStyle,
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: 'Dompetku',
      child: isHero
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: centered
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                logo,
                const SizedBox(height: AppSpacing.sm),
                wordmark,
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                logo,
                const SizedBox(width: AppSpacing.sm),
                Flexible(child: wordmark),
              ],
            ),
    );
  }
}
