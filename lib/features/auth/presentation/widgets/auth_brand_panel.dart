import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'auth_brand_lockup.dart';
import 'auth_value_props.dart';

/// Panel identitas untuk tata letak lebar (desktop, tablet landscape).
///
/// Isinya sengaja informatif, bukan ilustrasi dekoratif, agar halaman tidak
/// terasa kosong tanpa menjadi ramai.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 420),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBrandLockup(size: AuthBrandSize.hero),
          const SizedBox(height: AppSpacing.section),
          Text(
            'Catat.\nAtur.\nCapai.',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.04,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AuthValueProps(axis: Axis.vertical),
        ],
      ),
    );
  }
}
