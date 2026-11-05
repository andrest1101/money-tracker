import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/dashboard/domain/entities/category_expense_entity.dart';
import 'package:savu/features/dashboard/domain/entities/financial_insight_entity.dart';
import 'package:savu/features/dashboard/domain/entities/monthly_summary_entity.dart';
import 'package:savu/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:savu/features/dashboard/presentation/widgets/balance_hero_card.dart';
import 'package:savu/features/dashboard/presentation/widgets/budget_status_section.dart';
import 'package:savu/features/dashboard/presentation/widgets/category_expense_section.dart';
import 'package:savu/features/dashboard/presentation/widgets/financial_insight_section.dart';
import 'package:savu/features/dashboard/presentation/widgets/recent_transactions_section.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('section beranda tidak overflow di 360dp dan text scale 1.3', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final transactions = [
      TransactionEntity(
        id: '1',
        amount: 125000,
        type: TransactionType.expense,
        category: 'Kesehatan & Perawatan',
        date: DateTime(2026, 11, 5, 21, 5),
        note: 'Vitamin dan obat bulanan',
      ),
      TransactionEntity(
        id: '2',
        amount: 1500000,
        type: TransactionType.income,
        category: 'Uang Kiriman',
        date: DateTime(2026, 11, 4, 9, 30),
        note: 'Kiriman bulan November',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          categoryExpensesProvider.overrideWithValue(
            const AsyncValue.data([
              CategoryExpenseEntity(
                category: 'Kesehatan & Perawatan',
                amount: 125000,
              ),
              CategoryExpenseEntity(category: 'Makanan', amount: 75000),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Scaffold(
              body: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  BalanceHeroCard(
                    summary: const MonthlySummaryEntity(
                      totalIncome: 1500000,
                      totalExpense: 200000,
                      transactionCount: 2,
                    ),
                    transactions: transactions,
                  ),
                  const SizedBox(height: 28),
                  const BudgetStatusSection(),
                  const SizedBox(height: 28),
                  CategoryExpenseSection(onAddExpense: () {}),
                  const SizedBox(height: 28),
                  FinancialInsightSection(
                    insight: const FinancialInsightEntity(
                      income: 1500000,
                      expense: 200000,
                      previousExpense: 250000,
                      transactionCount: 2,
                      topCategory: 'Kesehatan & Perawatan',
                      averageDailyExpense: 25000,
                      periodLabel: 'November 2026',
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  RecentTransactionsSection(
                    transactions: transactions,
                    onSeeAll: () {},
                    onTransactionTap: (_) {},
                    onAddTransaction: () {},
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
}
