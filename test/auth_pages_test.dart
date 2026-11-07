import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/auth/presentation/pages/auth_landing_page.dart';
import 'package:savu/features/auth/presentation/pages/email_auth_page.dart';
import 'package:savu/features/auth/presentation/pages/reset_password_page.dart';

Widget _app(Widget home, {double textScale = 1}) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: home,
    ),
  );
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(360, 640),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_app(home, textScale: textScale));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('landing auth muat di 360dp tanpa overflow', (tester) async {
    await _pumpPage(tester, const AuthLandingPage());

    expect(find.textContaining('Keuangan lebih'), findsOneWidget);
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
    expect(find.text('Lanjutkan dengan email'), findsOneWidget);
    expect(find.text('Jelajahi tanpa akun'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('email auth berpindah mode tanpa label terpotong', (tester) async {
    await _pumpPage(tester, const EmailAuthPage());

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Buat akun Dompetku'), findsOneWidget);
    expect(find.text('Ulangi password'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang kembali'), findsOneWidget);

    await tester.ensureVisible(find.text('Masuk tanpa password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk tanpa password'));
    await tester.pumpAndSettle();
    expect(find.text('Kirim tautan masuk'), findsOneWidget);
    expect(find.text('Password'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset password menampilkan langkah dan aksi utama', (
    tester,
  ) async {
    await _pumpPage(tester, const ResetPasswordPage());

    expect(find.text('Lupa password?'), findsOneWidget);
    expect(find.text('Kirim tautan reset'), findsOneWidget);
    expect(find.text('Email'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('semua halaman auth aman pada text scale 2.0', (tester) async {
    for (final page in <Widget>[
      const AuthLandingPage(),
      const EmailAuthPage(),
      const ResetPasswordPage(),
    ]) {
      await _pumpPage(
        tester,
        page,
        size: const Size(320, 568),
        textScale: 2,
      );
      expect(
        tester.takeException(),
        isNull,
        reason: page.runtimeType.toString(),
      );
    }
  });

  testWidgets('tata letak lebar menampilkan panel brand', (tester) async {
    await _pumpPage(
      tester,
      const AuthLandingPage(),
      size: const Size(1280, 800),
    );
    expect(find.text('Catat.\nAtur.\nCapai.'), findsOneWidget);
    expect(find.text('Masuk atau daftar'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pumpPage(
      tester,
      const EmailAuthPage(),
      size: const Size(1280, 800),
    );
    expect(find.text('Catat.\nAtur.\nCapai.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
