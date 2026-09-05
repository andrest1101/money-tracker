import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class GoalCelebrationDialog extends StatefulWidget {
  const GoalCelebrationDialog({super.key, required this.goalTitle});

  final String goalTitle;

  @override
  State<GoalCelebrationDialog> createState() => _GoalCelebrationDialogState();
}

class _GoalCelebrationDialogState extends State<GoalCelebrationDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;
    final greenColor = isDark
        ? const Color(0xFF34D399)
        : const Color(0xFF047857);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: greenColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 42,
              color: greenColor,
            ),
          ),
          title: const Text('Yeay! Target Tercapai!'),
          content: Text(
            'Target "${widget.goalTitle}" sudah terpenuhi. '
            'Kerja bagus, satu impian berhasil diwujudkan!',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Lanjutkan'),
            ),
          ],
        ),
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 28,
            gravity: .65,
            emissionFrequency: .04,
            colors: [
              colors.primary,
              colors.tertiary,
              colors.secondary,
              colors.error,
            ],
          ),
        ),
      ],
    );
  }
}
