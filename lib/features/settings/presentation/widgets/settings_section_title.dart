import 'package:flutter/material.dart';

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
