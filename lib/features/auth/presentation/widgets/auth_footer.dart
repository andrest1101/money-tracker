import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Penutup kecil di bawah kartu autentikasi.
///
/// Mengisi ruang kosong dengan informasi yang berguna, bukan dekorasi.
class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    this.text = 'Data akun dan transaksi tersimpan aman.',
    this.icon = Icons.shield_outlined,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
