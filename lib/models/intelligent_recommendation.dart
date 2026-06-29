import 'dart:math';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/core/localization/app_localizations.dart';
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
    required AppLocalizations l10n,
  }) {
    final totalPressure = max(reading.totalPressureSum, 1.0);
    final leftShare = reading.leftPressureSum / totalPressure;
    final rightShare = reading.rightPressureSum / totalPressure;
    final hasLeftConcentration =
        reading.maxPressure > 1800 && leftShare > rightShare + 0.16;
    final hasRightConcentration =
        reading.maxPressure > 1800 && rightShare > leftShare + 0.16;
    final hotspotZone = describeHotspotZone(reading, postureMode, l10n);
    final isSeated = postureMode == PatientPostureMode.seated;

    if (reading.clinicalHyperemiaCount > 0) {
      return IntelligentRecommendation(
        kind: RecommendationKind.skinCheck,
        riskLevel: RiskLevel.high,
        assetPath: skinCheckAsset,
        title: l10n.text('rec_skin_title'),
        action: l10n.text('rec_skin_action'),
        message: l10n.text('rec_skin_message', {
          'temperature': formatTemperature(hyperemiaAlertCelsius),
          'zone': hotspotZone,
        }),
      );
    }

    if (hasProlongedPressure) {
      return IntelligentRecommendation(
        kind: RecommendationKind.pressureAlert,
        riskLevel: RiskLevel.high,
        assetPath: pressureAlertAsset,
        title: l10n.text('rec_prolonged_title'),
        action: l10n.text('rec_prolonged_action'),
        message: l10n.text(
          isSeated
              ? 'rec_prolonged_message_seated'
              : 'rec_prolonged_message_supine',
          {'threshold': prolongedPressureThreshold, 'zone': hotspotZone},
        ),
      );
    }

    if (hasRightConcentration) {
      return IntelligentRecommendation(
        kind: RecommendationKind.turnLeft,
        riskLevel: reading.maxPressure > 3000
            ? RiskLevel.high
            : RiskLevel.medium,
        assetPath: turnLeftAsset,
        title: l10n.text(
          isSeated ? 'rec_right_title_seated' : 'rec_right_title_supine',
        ),
        action: l10n.text(
          isSeated ? 'rec_right_action_seated' : 'rec_right_action_supine',
        ),
        message: l10n.text(
          isSeated ? 'rec_right_message_seated' : 'rec_right_message_supine',
        ),
      );
    }

    if (hasLeftConcentration) {
      return IntelligentRecommendation(
        kind: RecommendationKind.turnRight,
        riskLevel: reading.maxPressure > 3000
            ? RiskLevel.high
            : RiskLevel.medium,
        assetPath: turnRightAsset,
        title: l10n.text(
          isSeated ? 'rec_left_title_seated' : 'rec_left_title_supine',
        ),
        action: l10n.text(
          isSeated ? 'rec_left_action_seated' : 'rec_left_action_supine',
        ),
        message: l10n.text(
          isSeated ? 'rec_left_message_seated' : 'rec_left_message_supine',
        ),
      );
    }

    if (reading.maxPressure > 3100 || reading.highPressurePointCount >= 2) {
      return IntelligentRecommendation(
        kind: RecommendationKind.pressureAlert,
        riskLevel: RiskLevel.medium,
        assetPath: pressureAlertAsset,
        title: l10n.text('rec_elevated_title'),
        action: l10n.text(
          isSeated
              ? 'rec_elevated_action_seated'
              : 'rec_elevated_action_supine',
        ),
        message: l10n.text(
          isSeated
              ? 'rec_elevated_message_seated'
              : 'rec_elevated_message_supine',
          {'zone': hotspotZone},
        ),
      );
    }

    if (!reading.hasAnyValidClinicalTemperature) {
      final message = l10n.text(
        reading.hasAnyPressureSignal ? 'rec_wait_pressure' : 'rec_wait_empty',
      );

      return IntelligentRecommendation(
        kind: RecommendationKind.awaitingData,
        riskLevel: RiskLevel.medium,
        assetPath: safeAsset,
        title: l10n.text('rec_wait_title'),
        action: l10n.text('rec_wait_action'),
        message: message,
      );
    }

    if (reading.averagePressure < 900 &&
        reading.peakClinicalTemperature < safeTemperatureCelsius) {
      return IntelligentRecommendation(
        kind: RecommendationKind.safe,
        riskLevel: RiskLevel.low,
        assetPath: safeAsset,
        title: l10n.text('rec_safe_title'),
        action: l10n.text('rec_safe_action'),
        message: l10n.text(
          isSeated ? 'rec_safe_message_seated' : 'rec_safe_message_supine',
          {'temperature': formatTemperature(safeTemperatureCelsius)},
        ),
      );
    }

    return IntelligentRecommendation(
      kind: RecommendationKind.safe,
      riskLevel: RiskLevel.medium,
      assetPath: safeAsset,
      title: l10n.text('rec_monitor_title'),
      action: l10n.text('rec_monitor_action'),
      message: l10n.text(
        isSeated ? 'rec_monitor_message_seated' : 'rec_monitor_message_supine',
      ),
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
