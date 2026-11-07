import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/auth/presentation/pages/reset_password_page.dart';

void main() {
  testWidgets('reset password page menampilkan panduan dan validasi email', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ResetPasswordPage(),
        ),
      ),
    );

    expect(find.text('Lupa password?'), findsOneWidget);
    expect(find.text('Kirim tautan reset'), findsOneWidget);
    expect(find.text('Buka Gmail'), findsNothing);

    await tester.tap(find.text('Kirim tautan reset'));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan alamat emailmu.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'bukan-email');
    await tester.tap(find.text('Kirim tautan reset'));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
  });

  testWidgets('reset password page memakai email dari argumen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ResetPasswordPage(initialEmail: 'nama@example.com'),
        ),
      ),
    );

    expect(find.text('nama@example.com'), findsOneWidget);
  });
}
