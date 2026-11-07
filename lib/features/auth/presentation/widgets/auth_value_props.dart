import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Tiga nilai produk yang menjelaskan isi Dompetku tanpa menambah kartu baru.
class AuthValueProps extends StatelessWidget {
  const AuthValueProps({super.key, this.axis = Axis.horizontal});

  final Axis axis;

  static const List<({IconData icon, String label})> _items = [
    (icon: Icons.receipt_long_outlined, label: 'Catat transaksi'),
    (icon: Icons.donut_large_outlined, label: 'Pantau anggaran'),
    (icon: Icons.savings_outlined, label: 'Capai target'),
  ];

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.vertical) return const _VerticalValueProps();

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(12);
        final stack = constraints.maxWidth < 340 || textScale > 16;
        if (stack) return const _VerticalValueProps();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < _items.length; index++) ...[
              if (index > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: _ValuePropColumn(item: _items[index])),
            ],
          ],
        );
      },
    );
  }
}

class _VerticalValueProps extends StatelessWidget {
  const _VerticalValueProps();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < AuthValueProps._items.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.sm),
          _ValuePropRow(item: AuthValueProps._items[index]),
        ],
      ],
    );
  }
}

class _ValuePropColumn extends StatelessWidget {
  const _ValuePropColumn({required this.item});

  final ({IconData icon, String label}) item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ValueIcon(icon: item.icon),
        const SizedBox(height: AppSpacing.xs),
        Text(
          item.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _ValuePropRow extends StatelessWidget {
  const _ValuePropRow({required this.item});

  final ({IconData icon, String label}) item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _ValueIcon(icon: item.icon),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            item.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueIcon extends StatelessWidget {
  const _ValueIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Icon(icon, size: 19, color: scheme.onPrimaryContainer),
    );
  }
}
