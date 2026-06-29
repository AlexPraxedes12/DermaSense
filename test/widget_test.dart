import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:derma_sense/main.dart';

void main() {
  testWidgets('medical mat dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicalMatApp());

    expect(find.text('Derma Sense'), findsOneWidget);
    expect(find.text('Mapa de presión 8x8'), findsOneWidget);
    expect(find.text('Recomendaciones inteligentes'), findsOneWidget);
    expect(find.text('Historial y tendencias'), findsOneWidget);
    expect(find.text('Detalle de temperatura NTC'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('15 min'), findsOneWidget);
    expect(find.text('Carga sostenida relativa'), findsOneWidget);
    expect(find.text('Simular datos'), findsOneWidget);

    await tester.tap(find.text('Simular datos'));
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
    expect(find.text('Mapa de presión 8x8'), findsOneWidget);
    expect(find.text('Recomendaciones inteligentes'), findsOneWidget);
    expect(find.text('Historial y tendencias'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
  });

  testWidgets('language selector switches to English and French', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MedicalMatApp());

    expect(find.text('Idioma: Español'), findsOneWidget);
    await tester.tap(find.text('Idioma: Español'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inglés'));
    await tester.pumpAndSettle();

    expect(find.text('Interpretation mode'), findsOneWidget);
    expect(find.text('Smart recommendations'), findsOneWidget);

    expect(find.text('Language: English'), findsOneWidget);
    await tester.tap(find.text('Language: English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('French'));
    await tester.pumpAndSettle();

    expect(find.text("Mode d'interprétation"), findsOneWidget);
    expect(find.text('Recommandations intelligentes'), findsOneWidget);
    expect(find.text('Langue: Français'), findsOneWidget);
  });
}
