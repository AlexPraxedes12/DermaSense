import 'dart:math';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/core/utils/formatters.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/models/posture_labels.dart';

/// Recomendación clínica derivada de una [MatReading] (modelo de dominio).
///
/// Es el "cerebro" de la app: a partir de una lectura y la postura del paciente
/// decide qué mensaje, ilustración y nivel de riesgo mostrar. Toda la lógica de
/// decisión vive en [IntelligentRecommendation.fromReading], lo que la hace
/// fácil de leer, auditar y probar de forma aislada de la UI.
class IntelligentRecommendation {
  /// Crea una recomendación con todos sus campos ya resueltos.
  IntelligentRecommendation({
    required this.kind,
    required this.riskLevel,
    required this.assetPath,
    required this.title,
    required this.action,
    required this.message,
  });

  /// Evalúa una [reading] y produce la recomendación adecuada.
  ///
  /// Las reglas se evalúan por prioridad de riesgo (de mayor a menor):
  /// 1. Hiperemia clínica → revisar piel.
  /// 2. Presión prolongada ([hasProlongedPressure]) → alerta de presión.
  /// 3. Concentración de carga a un lado → sugerir descarga/giro.
  /// 4. Presión elevada puntual → ajustar apoyo.
  /// 5. Sin lecturas clínicas válidas → esperar datos.
  /// 6. Valores bajos y seguros → estado seguro.
  /// 7. En cualquier otro caso → monitoreo preventivo.
  ///
  /// [postureMode] adapta tanto la zona descrita como el texto de la acción
  /// (sedestación vs. decúbito supino).
  factory IntelligentRecommendation.fromReading(
    MatReading reading, {
    required bool hasProlongedPressure,
    required PatientPostureMode postureMode,
  }) {
    final totalPressure = max(reading.totalPressureSum, 1.0);
    final leftShare = reading.leftPressureSum / totalPressure;
    final rightShare = reading.rightPressureSum / totalPressure;
    final hasLeftConcentration =
        reading.maxPressure > 1800 && leftShare > rightShare + 0.16;
    final hasRightConcentration =
        reading.maxPressure > 1800 && rightShare > leftShare + 0.16;
    final hotspotZone = describeHotspotZone(reading, postureMode);
    final isSeated = postureMode == PatientPostureMode.seated;

    if (reading.clinicalHyperemiaCount > 0) {
      return IntelligentRecommendation(
        kind: RecommendationKind.skinCheck,
        riskLevel: RiskLevel.high,
        assetPath: skinCheckAsset,
        title: 'Revisar piel',
        action: 'Evaluar hiperemia',
        message:
            'Un sensor NTC supera ${formatTemperature(hyperemiaAlertCelsius)}. '
            'Revise coloracion, humedad y temperatura local en $hotspotZone '
            'antes de continuar.',
      );
    }

    if (hasProlongedPressure) {
      return IntelligentRecommendation(
        kind: RecommendationKind.pressureAlert,
        riskLevel: RiskLevel.high,
        assetPath: pressureAlertAsset,
        title: 'Alerta de presion',
        action: 'Descargar zona critica',
        message:
            'Hay puntos sobre $prolongedPressureThreshold durante varias '
            'lecturas. El foco principal esta en $hotspotZone. '
            '${isSeated ? 'Reacomode la sedestacion y haga alivio de presion con el cojin o la superficie de apoyo.' : 'Redistribuya el apoyo con cambio de posicion, cuña o almohada y confirme una nueva lectura.'}',
      );
    }

    if (hasRightConcentration) {
      return IntelligentRecommendation(
        kind: RecommendationKind.turnLeft,
        riskLevel: reading.maxPressure > 3000
            ? RiskLevel.high
            : RiskLevel.medium,
        assetPath: turnLeftAsset,
        title: isSeated
            ? 'Descargar lado derecho'
            : 'Redistribuir hacia la izquierda',
        action: isSeated
            ? 'Inclinar o apoyar mas hacia la izquierda'
            : 'Reducir apoyo en hemipelvis derecha',
        message:
            'La presion se concentra en el lado derecho de la matriz. '
            '${isSeated ? 'Pida una descarga breve del lado derecho o ajuste la postura y confirme nueva lectura.' : 'Haga un cambio postural suave hacia la izquierda y confirme nueva lectura.'}',
      );
    }

    if (hasLeftConcentration) {
      return IntelligentRecommendation(
        kind: RecommendationKind.turnRight,
        riskLevel: reading.maxPressure > 3000
            ? RiskLevel.high
            : RiskLevel.medium,
        assetPath: turnRightAsset,
        title: isSeated
            ? 'Descargar lado izquierdo'
            : 'Redistribuir hacia la derecha',
        action: isSeated
            ? 'Inclinar o apoyar mas hacia la derecha'
            : 'Reducir apoyo en hemipelvis izquierda',
        message:
            'La presion se concentra en el lado izquierdo de la matriz. '
            '${isSeated ? 'Pida una descarga breve del lado izquierdo o ajuste la postura y confirme nueva lectura.' : 'Haga un cambio postural suave hacia la derecha y confirme nueva lectura.'}',
      );
    }

    if (reading.maxPressure > 3100 || reading.highPressurePointCount >= 2) {
      return IntelligentRecommendation(
        kind: RecommendationKind.pressureAlert,
        riskLevel: RiskLevel.medium,
        assetPath: pressureAlertAsset,
        title: 'Presion elevada',
        action: isSeated
            ? 'Ajustar apoyo en sedestacion'
            : 'Ajustar apoyo en decubito',
        message:
            'Se detecta presion alta en $hotspotZone. '
            '${isSeated ? 'Si se mantiene, descargue peso, corrija postura y revise el cojin.' : 'Si se mantiene, cambie el apoyo, use una cuña o almohada y revise el acolchado.'}',
      );
    }

    if (!reading.hasAnyValidClinicalTemperature) {
      final message = reading.hasAnyPressureSignal
          ? 'El mapa de presion ya transmite, pero los NTC clinicos aun no '
                'entregan lecturas validas. Revise montaje, divisor de 6.8k '
                'y cableado.'
          : 'El ESP32 esta activo, pero todavia no hay lecturas validas de '
                'presion ni temperatura. Verifique tapete, NTC y ADS1115.';

      return IntelligentRecommendation(
        kind: RecommendationKind.awaitingData,
        riskLevel: RiskLevel.medium,
        assetPath: safeAsset,
        title: 'Esperando lecturas',
        action: 'Verificar sensores',
        message: message,
      );
    }

    if (reading.averagePressure < 900 &&
        reading.peakClinicalTemperature < safeTemperatureCelsius) {
      return IntelligentRecommendation(
        kind: RecommendationKind.safe,
        riskLevel: RiskLevel.low,
        assetPath: safeAsset,
        title: 'Estado seguro',
        action: 'Continuar monitoreo',
        message:
            'La presion promedio es baja y las temperaturas estan por debajo '
            'de ${formatTemperature(safeTemperatureCelsius)}. '
            '${isSeated ? 'Mantenga vigilancia de la postura y del tiempo en sedestacion.' : 'Mantenga vigilancia del apoyo sacro-pelvico y de los cambios de posicion.'}',
      );
    }

    return IntelligentRecommendation(
      kind: RecommendationKind.safe,
      riskLevel: RiskLevel.medium,
      assetPath: safeAsset,
      title: 'Monitoreo preventivo',
      action: 'Revisar tendencia',
      message:
          'Los valores se mantienen dentro de un rango aceptable, pero conviene '
          'observar la tendencia de presion y temperatura. '
          '${isSeated ? 'Si la carga se concentra, ajuste la sedestacion antes de que aparezca molestia.' : 'Si el apoyo se concentra, redistribuya la posicion antes de que la zona se caliente.'}',
    );
  }

  /// Tipo de recomendación (determina la intención y la ilustración).
  final RecommendationKind kind;

  /// Nivel de riesgo asociado.
  final RiskLevel riskLevel;

  /// Ruta del asset ilustrativo a mostrar.
  final String assetPath;

  /// Título corto de la recomendación.
  final String title;

  /// Acción sugerida (texto destacado).
  final String action;

  /// Mensaje explicativo extendido.
  final String message;
}
