import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Penanda tiga langkah pemulihan akun.
///
/// Menggantikan deretan lingkaran 40px yang berat; kini berupa nomor kecil
/// dengan garis penghubung dan status aktif yang jelas.
class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator({super.key, required this.currentStep});

  /// Indeks langkah aktif, dimulai dari nol.
  final int currentStep;

  static const List<({String label, String semantics})> _steps = [
    (label: 'Email', semantics: 'Masukkan email'),
    (label: 'Cek Gmail', semantics: 'Buka tautan di Gmail'),
    (label: 'Password', semantics: 'Buat password baru'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < _steps.length; index++) ...[
          Expanded(
            child: _Step(
              index: index,
              label: _steps[index].label,
              semanticsLabel: _steps[index].semantics,
              currentStep: currentStep,
            ),
          ),
          if (index < _steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(
                top: 13,
                left: AppSpacing.xxs,
                right: AppSpacing.xxs,
              ),
              child: Container(
                width: 12,
                height: 2,
                color: index < currentStep
                    ? scheme.primary
                    : scheme.outlineVariant,
              ),
            ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.label,
    required this.semanticsLabel,
    required this.currentStep,
  });

  final int index;
  final String label;
  final String semanticsLabel;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDone = index < currentStep;
    final isCurrent = index == currentStep;

    final background = isDone || isCurrent
        ? scheme.primary
        : scheme.surfaceContainerLow;
    final foreground = isDone || isCurrent
        ? scheme.onPrimary
        : scheme.onSurfaceVariant;

    return Semantics(
      label: 'Langkah ${index + 1} dari 3: $semanticsLabel',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                border: isDone || isCurrent
                    ? null
                    : Border.all(color: scheme.outlineVariant),
              ),
              child: isDone
                  ? Icon(Icons.check_rounded, size: 16, color: foreground)
                  : Text(
                      '${index + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDone || isCurrent
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
