import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/local_storage/settings_providers.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('header tamu menampilkan nama profil tanpa badge Tamu duplikat', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: DashboardHeader(userName: 'Andre')),
        ),
      ),
    );

    expect(find.text('Andre'), findsOneWidget);
    expect(find.text('Tamu'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
