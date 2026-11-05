import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/constants/app_strings.dart';
import 'package:savu/core/theme/app_colors.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/core/theme/category_palette.dart';
import 'package:savu/core/utils/rupiah_formatter.dart';
import 'package:savu/shared/widgets/amount_text.dart';
import 'package:savu/shared/widgets/budget_progress.dart';
import 'package:savu/shared/widgets/category_icon.dart';
import 'package:savu/shared/widgets/empty_state.dart';
import 'package:savu/shared/widgets/filter_sheet.dart';
import 'package:savu/shared/widgets/goal_card.dart';
import 'package:savu/shared/widgets/section_header.dart';
import 'package:savu/shared/widgets/stat_inline.dart';
import 'package:savu/shared/widgets/transaction_tile.dart';

const _brightnesses = [Brightness.light, Brightness.dark];

Widget _app(Brightness brightness, Widget child) {
  return MaterialApp(
    theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
    home: Scaffold(body: child),
  );
}

Color _expectedColor(Brightness brightness, Color light, Color dark) {
  return brightness == Brightness.dark ? dark : light;
}

void main() {
  group('formatRupiahSpoken', () {
    test('mengubah nominal menjadi kata', () {
      expect(formatRupiahSpoken(0), 'nol rupiah');
      expect(formatRupiahSpoken(12000), 'dua belas ribu rupiah');
      expect(formatRupiahSpoken(250000), 'dua ratus lima puluh ribu rupiah');
      expect(formatRupiahSpoken(101000), 'seratus satu ribu rupiah');
      expect(formatRupiahSpoken(1000000), 'satu juta rupiah');
      expect(
        formatRupiahSpoken(-1250000),
        'minus satu juta dua ratus lima puluh ribu rupiah',
      );
    });
  });

  group('AmountText', () {
    for (final brightness in _brightnesses) {
      testWidgets('menampilkan tanda dan warna sesuai tone ($brightness)', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            brightness,
            const Column(
              children: [
                AmountText(
                  amount: 12000,
                  tone: AmountTone.income,
                  showSign: true,
                ),
                AmountText(
                  amount: 12000,
                  tone: AmountTone.expense,
                  showSign: true,
                ),
              ],
            ),
          ),
        );

        final income = tester.widget<Text>(find.text('+Rp 12.000'));
        final expense = tester.widget<Text>(find.text('−Rp 12.000'));

        expect(
          income.style?.color,
          _expectedColor(
            brightness,
            AppColors.light.income,
            AppColors.dark.income,
          ),
        );
        expect(
          expense.style?.color,
          _expectedColor(
            brightness,
            AppColors.light.textPrimary,
            AppColors.dark.textPrimary,
          ),
        );
        expect(income.style?.fontFeatures, isNotEmpty);
      });
    }

    testWidgets('memberi label pembaca layar yang terbaca', (tester) async {
      await tester.pumpWidget(
        _app(
          Brightness.light,
          const AmountText(
            amount: 12000,
            tone: AmountTone.expense,
            showSign: true,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(AmountText)),
        matchesSemantics(label: 'minus dua belas ribu rupiah'),
      );
    });
  });

  group('SectionHeader', () {
    for (final brightness in _brightnesses) {
      testWidgets('menampilkan judul dan aksi ($brightness)', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _app(
            brightness,
            SectionHeader(
              title: 'Transaksi terbaru',
              actionLabel: 'Lihat semua',
              onAction: () => tapped = true,
            ),
          ),
        );

        expect(find.text('Transaksi terbaru'), findsOneWidget);
        await tester.tap(find.text('Lihat semua'));
        expect(tapped, isTrue);
      });
    }
  });

  group('StatInline', () {
    for (final brightness in _brightnesses) {
      testWidgets('menampilkan label dan nominal ($brightness)', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            brightness,
            const StatInline(
              label: 'Pemasukan',
              amount: 100000,
              tone: AmountTone.income,
            ),
          ),
        );

        expect(find.text('Pemasukan'), findsOneWidget);
        expect(find.text('Rp 100.000'), findsOneWidget);
      });
    }
  });

  group('BudgetProgress', () {
    testWidgets('memakai warna primary di bawah 80 persen', (tester) async {
      await tester.pumpWidget(
        _app(
          Brightness.light,
          const BudgetProgress(spent: 500000, limit: 1000000),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sisa Rp 500.000'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      final context = tester.element(find.byType(BudgetProgress));
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(0.5, 0.001));
      expect(bar.valueColor?.value, Theme.of(context).colorScheme.primary);
    });

    testWidgets('memakai danger saat pemakaian 80 persen atau lebih', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Brightness.light,
          const BudgetProgress(spent: 850000, limit: 1000000),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sisa Rp 150.000'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.valueColor?.value, AppColors.light.danger);
    });

    testWidgets('menampilkan kelebihan saat anggaran terlampaui', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Brightness.dark,
          const BudgetProgress(spent: 1200000, limit: 1000000),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lebih Rp 200.000'), findsOneWidget);
      expect(find.text('120%'), findsOneWidget);
    });

    testWidgets('memberi keterangan saat anggaran belum diatur', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(Brightness.light, const BudgetProgress(spent: 0, limit: 0)),
      );

      expect(find.text('Anggaran belum diatur'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });
  });

  group('CategoryIcon', () {
    for (final brightness in _brightnesses) {
      testWidgets('memakai palet kategori ($brightness)', (tester) async {
        await tester.pumpWidget(
          _app(
            brightness,
            const Row(
              children: [
                CategoryIcon(category: 'Makanan'),
                CategoryIcon(category: 'Lainnya'),
              ],
            ),
          ),
        );

        final food = tester.widget<Icon>(find.byIcon(Icons.restaurant_rounded));
        final other = tester.widget<Icon>(
          find.byIcon(Icons.more_horiz_rounded),
        );

        expect(food.color, CategoryPalette.color('Makanan', brightness));
        expect(other.color, CategoryTone.slate.colorFor(brightness));
      });
    }

    testWidgets('kategori custom memakai tone yang stabil', (tester) async {
      await tester.pumpWidget(
        _app(
          Brightness.light,
          const Column(
            children: [
              CategoryIcon(category: 'Servis Motor'),
              CategoryIcon(category: 'Servis Motor'),
            ],
          ),
        ),
      );

      final icons = tester
          .widgetList<Icon>(find.byType(Icon))
          .toList(growable: false);
      expect(icons, hasLength(2));
      expect(icons.first.color, icons.last.color);
      expect(icons.first.color, isNot(CategoryTone.slate.light));
    });
  });

  group('TransactionTile', () {
    for (final brightness in _brightnesses) {
      testWidgets('pemasukan memakai income dan tanda plus ($brightness)', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(
            brightness,
            TransactionTile(
              category: 'Uang Kiriman',
              amount: 50000,
              isExpense: false,
              timeLabel: '09:30',
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('+Rp 50.000'));
        expect(
          text.style?.color,
          _expectedColor(
            brightness,
            AppColors.light.income,
            AppColors.dark.income,
          ),
        );
      });
    }

    testWidgets('pengeluaran memakai textPrimary dan tanda minus', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _app(
          Brightness.light,
          TransactionTile(
            category: 'Makanan',
            amount: 12000,
            isExpense: true,
            timeLabel: '09:30',
            note: 'Kopi',
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('09:30  •  Kopi'), findsOneWidget);
      final text = tester.widget<Text>(find.text('−Rp 12.000'));
      expect(text.style?.color, AppColors.light.textPrimary);

      await tester.tap(find.text('Makanan'));
      expect(tapped, isTrue);
    });

    testWidgets('swipe memicu onDismissed tanpa menghapus baris', (
      tester,
    ) async {
      var dismissed = false;
      await tester.pumpWidget(
        _app(
          Brightness.light,
          TransactionTile(
            category: 'Makanan',
            amount: 12000,
            isExpense: true,
            dismissKey: 'tx-1',
            onDismissed: () => dismissed = true,
          ),
        ),
      );

      await tester.drag(find.text('Makanan'), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('Makanan'), findsOneWidget);
    });
  });

  group('GoalCard', () {
    for (final brightness in _brightnesses) {
      testWidgets('menampilkan progres dan aksi alokasi ($brightness)', (
        tester,
      ) async {
        var allocated = false;
        await tester.pumpWidget(
          _app(
            brightness,
            GoalCard(
              title: 'Laptop',
              currentAmount: 250000,
              targetAmount: 1000000,
              deadline: DateTime(2026, 11, 19),
              daysUntilDeadline: 47,
              onAllocate: () => allocated = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Laptop'), findsOneWidget);
        expect(find.text('25%'), findsOneWidget);
        expect(find.text('Rp 250.000 terkumpul'), findsOneWidget);
        expect(find.text('Rp 750.000 lagi'), findsOneWidget);
        expect(find.text('19 Nov 2026 · 47 hari lagi'), findsOneWidget);

        await tester.tap(find.text(AppStrings.allocateFund));
        expect(allocated, isTrue);
      });
    }

    testWidgets('deadline dekat memakai warna warning', (tester) async {
      await tester.pumpWidget(
        _app(
          Brightness.light,
          GoalCard(
            title: 'Laptop',
            currentAmount: 250000,
            targetAmount: 1000000,
            deadline: DateTime(2026, 11, 19),
            daysUntilDeadline: 10,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('19 Nov 2026 · 10 hari lagi'));
      expect(text.style?.color, AppColors.light.warningText);
    });

    testWidgets('target selesai menampilkan badge dan tanpa tombol', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Brightness.dark,
          GoalCard(
            title: 'Laptop',
            currentAmount: 1000000,
            targetAmount: 1000000,
            deadline: DateTime(2026, 11, 19),
            daysUntilDeadline: 47,
            isCompleted: true,
            onAllocate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.goalCompleted), findsOneWidget);
      expect(find.text(AppStrings.allocateFund), findsNothing);
    });
  });

  group('EmptyState', () {
    for (final brightness in _brightnesses) {
      testWidgets('menampilkan pesan dan tombol ($brightness)', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _app(
            brightness,
            EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Belum ada transaksi',
              message: 'Catat pengeluaran pertamamu untuk mulai melihat pola.',
              actionLabel: 'Catat sekarang',
              onAction: () => tapped = true,
            ),
          ),
        );

        expect(find.text('Belum ada transaksi'), findsOneWidget);
        expect(
          find.text('Catat pengeluaran pertamamu untuk mulai melihat pola.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Catat sekarang'));
        expect(tapped, isTrue);
      });
    }
  });

  group('FilterSheet', () {
    for (final brightness in _brightnesses) {
      testWidgets('mengembalikan kategori yang dipilih ($brightness)', (
        tester,
      ) async {
        FilterSelection? selection;
        await tester.pumpWidget(
          _app(
            brightness,
            Builder(
              builder: (context) {
                return Center(
                  child: FilledButton(
                    onPressed: () async {
                      selection = await showFilterSheet(
                        context,
                        categories: const ['Makanan', 'Transportasi'],
                      );
                    },
                    child: const Text('Buka filter'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Buka filter'));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.filterTitle), findsOneWidget);
        expect(find.text(AppStrings.allCategories), findsOneWidget);

        await tester.tap(find.text('Makanan'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(AppStrings.apply));
        await tester.tap(find.text(AppStrings.apply));
        await tester.pumpAndSettle();

        expect(selection?.category, 'Makanan');
        expect(selection?.period, FilterPeriod.all);
        expect(selection?.activeCycleOnly, isFalse);
      });
    }

    testWidgets('reset mengosongkan semua pilihan', (tester) async {
      FilterSelection? selection;
      await tester.pumpWidget(
        _app(
          Brightness.light,
          Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed: () async {
                    selection = await showFilterSheet(
                      context,
                      categories: const ['Makanan', 'Transportasi'],
                    );
                  },
                  child: const Text('Buka filter'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Buka filter'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Makanan'));
      await tester.tap(find.text(AppStrings.activeCycle));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(AppStrings.reset));
      await tester.tap(find.text(AppStrings.reset));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(AppStrings.apply));
      await tester.tap(find.text(AppStrings.apply));
      await tester.pumpAndSettle();

      expect(selection?.category, isNull);
      expect(selection?.period, FilterPeriod.all);
      expect(selection?.activeCycleOnly, isFalse);
    });
  });

  group('Layout sempit', () {
    testWidgets('komponen tidak overflow di 360dp dan text scale 1.3', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    GoalCard(
                      title: 'Laptop Kerja Baru',
                      currentAmount: 250000,
                      targetAmount: 1000000,
                      deadline: DateTime(2026, 11, 19),
                      daysUntilDeadline: 10,
                      onAllocate: () {},
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: BudgetProgress(
                        spent: 850000,
                        limit: 1000000,
                        caption: 'Rp 850.000 dari Rp 1.000.000 · 12 hari lagi',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const TransactionTile(
                      category: 'Kesehatan & Perawatan',
                      amount: 125000,
                      isExpense: true,
                      timeLabel: '21:05',
                      note: 'Vitamin dan obat bulanan',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
