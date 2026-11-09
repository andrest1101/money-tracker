import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savu/core/theme/app_theme.dart';
import 'package:savu/features/auth/presentation/widgets/auth_value_props.dart';

void main() {
  Future<void> pumpProps(
    WidgetTester tester, {
    double maxWidth = 312,
    double textScale = 1,
    Axis axis = Axis.horizontal,
  }) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: AuthValueProps(axis: axis),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('journey compact menampilkan tiga langkah tanpa overflow', (
    tester,
  ) async {
    await pumpProps(tester);

    expect(find.text('Catat transaksi'), findsOneWidget);
    expect(find.text('Pantau anggaran'), findsOneWidget);
    expect(find.text('Capai target'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('journey tetap aman pada text scale 2.0', (tester) async {
    await pumpProps(tester, textScale: 2);

    expect(find.text('Catat transaksi'), findsOneWidget);
    expect(find.text('Pantau anggaran'), findsOneWidget);
    expect(find.text('Capai target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('journey vertikal untuk panel lebar tampil sebagai perjalanan', (
    tester,
  ) async {
    await pumpProps(tester, axis: Axis.vertical);

    expect(find.text('Catat transaksi'), findsOneWidget);
    expect(find.text('Pantau anggaran'), findsOneWidget);
    expect(find.text('Capai target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
