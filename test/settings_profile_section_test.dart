import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/settings/presentation/widgets/settings_profile_section.dart';
import 'package:savu/features/transactions/domain/entities/transaction_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    double textScale = 1,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const Scaffold(
              body: ProfileHeader(syncState: _syncState),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('account header menampilkan identitas dan status akun', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Halo, Pengguna'), findsOneWidget);
    expect(find.text('Mahasiswa'), findsOneWidget);
    expect(find.textContaining('Tersinkronisasi'), findsOneWidget);
    expect(find.text('Akun guest • Amankan'), findsOneWidget);
    expect(find.byTooltip('Ganti avatar'), findsOneWidget);
    expect(find.byTooltip('Buka detail profil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account header tidak overflow pada text scale 1.3', (
    tester,
  ) async {
    await pumpProfile(tester, textScale: 1.3);

    expect(find.text('Halo, Pengguna'), findsOneWidget);
    expect(find.textContaining('Tersinkronisasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ketuk kartu membuka detail profil, bukan edit langsung', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.byTooltip('Buka detail profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil keuangan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ketuk avatar membuka avatar sheet', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byTooltip('Ganti avatar'));
    await tester.pumpAndSettle();

    expect(find.text('Avatar profil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _syncState = AsyncData<List<TransactionEntity>>(<TransactionEntity>[]);
