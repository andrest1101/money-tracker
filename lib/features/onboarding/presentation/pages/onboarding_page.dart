import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_storage/settings_providers.dart';
import '../../../../core/widgets/app_page_background.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    OnboardingSlideData(
      eyebrow: 'Quick Input & Ledger',
      badge: 'Pencatatan Kilat',
      title: 'Catat Transaksi\nDalam Hitungan Detik.',
      description:
          'Cegah "bocor halus" dengan input super cepat. Format Rupiah otomatis, kategori dinamis, dan riwayat yang terkelompok rapi.',
      icon: Icons.receipt_long_rounded,
      accent: Color(0xFF2DD4BF),
      kind: OnboardingIllustrationKind.transactions,
      featureHighlights: [
        'Input Nominal Cepat',
        'Deteksi Bocor Halus',
        'Kategori Otomatis',
      ],
    ),
    OnboardingSlideData(
      eyebrow: 'Smart Overspending Guard',
      badge: 'Kontrol Anggaran',
      title: 'Pantau Anggaran,\nCegah Boncos.',
      description:
          'Sistem alert 3 tingkat (Aman, Waspada, Terlampaui) dengan siklus gajian custom 1-28 agar kamu selalu siap sebelum akhir bulan.',
      icon: Icons.insights_rounded,
      accent: Color(0xFF60A5FA),
      kind: OnboardingIllustrationKind.budget,
      featureHighlights: [
        'Siklus Gajian Custom',
        'Alert Merah ≥ 80%',
        'Visual Bar Realtime',
      ],
    ),
    OnboardingSlideData(
      eyebrow: 'Atomic Goal Allocation',
      badge: 'Target Tabungan',
      title: 'Wujudkan Impian\nSedikit Demi Sedikit.',
      description:
          'Alokasikan saldo utama ke target UKT, gadget, atau dana darurat secara atomik. Pantau progres dan rayakan setiap pencapaian!',
      icon: Icons.savings_rounded,
      accent: Color(0xFFA78BFA),
      kind: OnboardingIllustrationKind.savings,
      featureHighlights: [
        'Alokasi Dana Atomik',
        'Tracking Deadline',
        'Mode Selesai & Arsip',
      ],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final saved = await ref
        .read(onboardingCompletedProvider.notifier)
        .complete();
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onboarding belum tersimpan. Coba lagi.')),
      );
    }
  }

  void _next() {
    if (_index == _slides.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _previous() {
    if (_index > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLast = _index == _slides.length - 1;
    final hasPrev = _index > 0;
    final currentAccent = _slides[_index].accent;

    return AppPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            child: Column(
              children: [
                // ── Top Navigation Bar ─────────────────────────────────────────
                Row(
                  children: [
                    // App Brand Logo
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: colors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SAVU',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Skip Button
                    TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Lewati'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Page Slides Area ───────────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (_, index) => KeyedSubtree(
                      key: ValueKey(index),
                      child: OnboardingSlide(
                        data: _slides[index],
                        onCardTap: () {
                          // Card tap triggers interactive preview within the card
                        },
                      ),
                    ),
                  ),
                ),

                // ── Bottom Action & Indicators ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      // Step Indicator Dots
                      Row(
                        children: List.generate(
                          _slides.length,
                          (index) => _StepDot(
                            active: index == _index,
                            color: currentAccent,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Back icon button (if previous page available)
                      if (hasPrev) ...[
                        IconButton.filledTonal(
                          onPressed: _previous,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Next / Start Button
                      FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: isLast
                              ? currentAccent
                              : colors.primary,
                          foregroundColor: isLast
                              ? Colors.white
                              : colors.onPrimary,
                          minimumSize: Size(isLast ? 160 : 138, 50),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? 'Mulai Sekarang' : 'Lanjutkan',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isLast
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
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
// Step Dot Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(right: 6),
      width: active ? 26 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? color : colors.outlineVariant,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
