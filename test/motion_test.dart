import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/shared/widgets/app_entrance.dart';

Widget _app({required bool disableAnimations, required Widget child}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('AppEntrance', () {
    testWidgets('menampilkan konten setelah animasi selesai', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: false,
          child: const AppEntrance(child: Text('Savu')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Savu'), findsOneWidget);
    });

    testWidgets('saat reduced motion aktif, konten langsung di posisi akhir', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          child: const AppEntrance(child: Text('Savu')),
        ),
      );
      await tester.pump();

      // Pada status selesai, Opacity dilepas agar tidak bikin layer.
      expect(find.byType(Opacity), findsNothing);
      expect(find.text('Savu'), findsOneWidget);
    });
  });
}
