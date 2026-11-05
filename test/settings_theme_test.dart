import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/settings/presentation/widgets/settings_display_section.dart';

void main() {
  testWidgets('menjelaskan tema terang sementara tanpa opsi tema gelap', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: ThemeSelectionCard()),
      ),
    );

    expect(find.text('Tema terang aktif'), findsOneWidget);
    expect(
      find.textContaining('Pilihan tema gelap tersedia kembali'),
      findsOneWidget,
    );
    expect(find.text('Sistem'), findsNothing);
    expect(find.text('Gelap'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
