import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Tiga nilai produk yang dijelaskan sebagai perjalanan, bukan daftar polos.
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
    if (axis == Axis.vertical) return const _VerticalJourney();

    return LayoutBuilder(
      builder: (context, constraints) {
        final scaledBody = MediaQuery.textScalerOf(context).scale(12);
        if (constraints.maxWidth < 288 || scaledBody > 18) {
          return const _VerticalJourney();
        }
        return const _HorizontalJourney();
      },
    );
  }
}

class _HorizontalJourney extends StatelessWidget {
  const _HorizontalJourney();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Perjalanan menggunakan Dompetku',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var index = 0; index < AuthValueProps._items.length; index++) ...[
            if (index > 0) const _HorizontalConnector(),
            Expanded(
              child: _JourneyStep(
                index: index,
                item: AuthValueProps._items[index],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HorizontalConnector extends StatelessWidget {
  const _HorizontalConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Container(
        width: 12,
        height: 2,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({required this.index, required this.item});

  final int index;
  final ({IconData icon, String label}) item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      label: 'Langkah ${index + 1} dari 3: ${item.label}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _JourneyIcon(number: index + 1, icon: item.icon, size: 44),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalJourney extends StatelessWidget {
  const _VerticalJourney();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Perjalanan menggunakan Dompetku',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < AuthValueProps._items.length; index++) ...[
            _VerticalJourneyStep(
              index: index,
              item: AuthValueProps._items[index],
            ),
            if (index < AuthValueProps._items.length - 1)
              const _VerticalConnector(),
          ],
        ],
      ),
    );
  }
}

class _VerticalConnector extends StatelessWidget {
  const _VerticalConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Container(
        width: 2,
        height: 16,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _VerticalJourneyStep extends StatelessWidget {
  const _VerticalJourneyStep({required this.index, required this.item});

  final int index;
  final ({IconData icon, String label}) item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      label: 'Langkah ${index + 1} dari 3: ${item.label}',
      child: Row(
        children: [
          _JourneyIcon(number: index + 1, icon: item.icon, size: 36),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyIcon extends StatelessWidget {
  const _JourneyIcon({
    required this.number,
    required this.icon,
    required this.size,
  });

  final int number;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: size * 0.46,
              color: scheme.onPrimaryContainer,
            ),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
