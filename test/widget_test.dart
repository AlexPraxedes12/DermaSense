import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:derma_sense/main.dart';

void main() {
  testWidgets('medical mat dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicalMatApp());

    expect(find.text('Derma Sense'), findsOneWidget);
    expect(find.text('Mapa de presion 8x8'), findsOneWidget);
    expect(find.text('Recomendaciones inteligentes'), findsOneWidget);
    expect(find.text('Historial y tendencias'), findsOneWidget);
    expect(find.text('Detalle temperatura NTC'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('15 min'), findsOneWidget);
    expect(find.text('Carga sostenida relativa'), findsOneWidget);
    expect(find.text('Simular Datos'), findsOneWidget);

    await tester.tap(find.text('Simular Datos'));
    await tester.pump();

    expect(find.text('Detener'), findsOneWidget);
  });

  testWidgets('medical mat dashboard fits phone viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.15;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const MedicalMatApp());

    expect(find.text('Derma Sense'), findsOneWidget);
    expect(find.text('Mapa de presion 8x8'), findsOneWidget);
    expect(find.text('Recomendaciones inteligentes'), findsOneWidget);
    expect(find.text('Historial y tendencias'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
  });
}
