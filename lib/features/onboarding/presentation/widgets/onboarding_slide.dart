import 'package:flutter/material.dart';

enum OnboardingIllustrationKind { transactions, budget, savings }

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.eyebrow,
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.kind,
    required this.featureHighlights,
  });

  final String eyebrow;
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final OnboardingIllustrationKind kind;
  final List<String> featureHighlights;
}

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.data,
    required this.onCardTap,
  });

  final OnboardingSlideData data;
  final VoidCallback onCardTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Interactive Feature Card ──────────────────────────────────────
          SizedBox(
            height: 290,
            width: double.infinity,
            child: OnboardingInteractiveCard(data: data, onTap: onCardTap),
          ),
          const SizedBox(height: 22),

          // ── Badge & Eyebrow ───────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: data.accent.withValues(alpha: .35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(data.icon, color: data.accent, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      data.badge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: data.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.eyebrow.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Headline ──────────────────────────────────────────────────────
          Text(
            data.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 10),

          // ── Description ───────────────────────────────────────────────────
          Text(
            data.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // ── Feature Highlight Chips ───────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.featureHighlights.map((highlight) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: data.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      highlight,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive Card Container
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingInteractiveCard extends StatefulWidget {
  const OnboardingInteractiveCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final OnboardingSlideData data;
  final VoidCallback onTap;

  @override
  State<OnboardingInteractiveCard> createState() =>
      _OnboardingInteractiveCardState();
}

class _OnboardingInteractiveCardState extends State<OnboardingInteractiveCard> {
  int _interactiveIndex = 0;
  bool _isHighlighted = false;

  void _handleTap() {
    setState(() {
      _interactiveIndex = (_interactiveIndex + 1) % 3;
      _isHighlighted = true;
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _isHighlighted = false);
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = widget.data.accent;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: accent.withValues(alpha: .12),
        highlightColor: accent.withValues(alpha: .06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isHighlighted ? accent : colors.outlineVariant,
              width: _isHighlighted ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHighlighted
                    ? accent.withValues(alpha: .22)
                    : colors.shadow.withValues(alpha: .12),
                blurRadius: _isHighlighted ? 28 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Ambient Glow
                Positioned(
                  top: -50,
                  right: -40,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withValues(alpha: .18),
                          accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with category & interactive prompt
                      LayoutBuilder(
                        builder: (context, constraints) => Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                widget.data.icon,
                                color: accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Savu FinTech',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            const Spacer(),
                            // The helper badge is optional on compact phones;
                            // hiding it prevents the header from competing
                            // with the feature title for horizontal space.
                            if (constraints.maxWidth >= 340)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.touch_app_rounded,
                                      size: 13,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ketuk Card',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: accent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Interactive Body
                      Expanded(
                        child: switch (widget.data.kind) {
                          OnboardingIllustrationKind.transactions =>
                            _InteractiveTransactionsPreview(
                              selectedIndex: _interactiveIndex,
                            ),
                          OnboardingIllustrationKind.budget =>
                            _InteractiveBudgetPreview(
                              stateIndex: _interactiveIndex,
                            ),
                          OnboardingIllustrationKind.savings =>
                            _InteractiveSavingsPreview(
                              allocationStep: _interactiveIndex,
                            ),
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Interactive Transactions Preview
// ─────────────────────────────────────────────────────────────────────────────

class _InteractiveTransactionsPreview extends StatelessWidget {
  const _InteractiveTransactionsPreview({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final items = [
      (
        icon: Icons.south_west_rounded,
        title: 'Uang Kiriman Bulanan',
        time: 'Hari ini • 09:30',
        amount: '+ Rp2.500.000',
        isIncome: true,
      ),
      (
        icon: Icons.restaurant_rounded,
        title: 'Makan Siang & Es Teh',
        time: 'Hari ini • 12:45',
        amount: '- Rp35.000',
        isIncome: false,
      ),
      (
        icon: Icons.local_gas_station_rounded,
        title: 'Bensin Motor Scoopy',
        time: 'Kemarin • 18:20',
        amount: '- Rp25.000',
        isIncome: false,
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(items.length, (idx) {
        final item = items[idx];
        final isSelected = selectedIndex == idx;
        final color = item.isIncome ? colors.primary : colors.error;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.surfaceContainerHigh
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colors.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withValues(alpha: .15),
                child: Icon(item.icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    item.amount,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Interactive Budget Preview
// ─────────────────────────────────────────────────────────────────────────────

class _InteractiveBudgetPreview extends StatelessWidget {
  const _InteractiveBudgetPreview({required this.stateIndex});

  final int stateIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Simulate 3 levels of spending: Safe (45%), Warning (82%), Exceeded (105%)
    final scenarios = [
      (
        ratio: 0.45,
        spent: 'Rp900.000',
        limit: 'Rp2.000.000',
        rem: 'Sisa Rp1.100.000',
        status: 'Aman Terkendali',
        color: const Color(0xFF2DD4BF),
        icon: Icons.check_circle_outline_rounded,
      ),
      (
        ratio: 0.82,
        spent: 'Rp1.640.000',
        limit: 'Rp2.000.000',
        rem: 'Sisa Rp360.000',
        status: 'Waspada 82%',
        color: const Color(0xFFFBBF24),
        icon: Icons.warning_amber_rounded,
      ),
      (
        ratio: 1.0,
        spent: 'Rp2.150.000',
        limit: 'Rp2.000.000',
        rem: 'Lebih Rp150.000',
        status: 'Overspending Alert',
        color: colors.error,
        icon: Icons.error_outline_rounded,
      ),
    ];

    final current = scenarios[stateIndex % scenarios.length];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batas Anggaran Bulanan',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Text(
              '${current.spent} / ${current.limit}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: current.color.withValues(alpha: .35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(current.icon, size: 14, color: current.color),
                  const SizedBox(width: 4),
                  Text(
                    current.status,
                    style: TextStyle(
                      color: current.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Animated progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: current.ratio),
            builder: (context, val, _) {
              return LinearProgressIndicator(
                value: val,
                minHeight: 12,
                backgroundColor: colors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(current.color),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                current.rem,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: current.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Siklus: Tgl 1 - 30',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Interactive Savings Preview
// ─────────────────────────────────────────────────────────────────────────────

class _InteractiveSavingsPreview extends StatelessWidget {
  const _InteractiveSavingsPreview({required this.allocationStep});

  final int allocationStep;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Simulation steps: 40%, 70%, 100%
    final goals = [
      (
        title: 'UKT Semester Depan',
        current: 'Rp2.000.000',
        target: 'Rp5.000.000',
        progress: 0.40,
        pct: '40%',
        color: const Color(0xFFA78BFA),
      ),
      (
        title: 'UKT Semester Depan',
        current: 'Rp3.500.000',
        target: 'Rp5.000.000',
        progress: 0.70,
        pct: '70%',
        color: const Color(0xFF38BDF8),
      ),
      (
        title: 'UKT Semester Depan',
        current: 'Rp5.000.000',
        target: 'Rp5.000.000',
        progress: 1.0,
        pct: '100% 🎉',
        color: const Color(0xFF2DD4BF),
      ),
    ];

    final current = goals[allocationStep % goals.length];

    return Row(
      children: [
        // Circular progress indicator with celebration spark
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                tween: Tween<double>(begin: 0.0, end: current.progress),
                builder: (context, val, _) {
                  return CircularProgressIndicator(
                    value: val,
                    strokeWidth: 9,
                    backgroundColor: colors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(current.color),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colors.surfaceContainerHigh
                      : colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: current.color, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: .08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  current.pct,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Target Details
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                current.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${current.current} terkumpul',
                style: TextStyle(
                  color: current.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                'dari target ${current.target}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 13, color: current.color),
                    const SizedBox(width: 4),
                    Text(
                      '+ Alokasikan Dana',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
