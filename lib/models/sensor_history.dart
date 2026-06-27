import 'dart:collection';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/models/enums.dart';

/// Ventanas de observación disponibles en el dashboard.
enum HistoryWindow {
  fiveMinutes(Duration(minutes: 5), '5 min'),
  tenMinutes(Duration(minutes: 10), '10 min'),
  fifteenMinutes(Duration(minutes: 15), '15 min');

  const HistoryWindow(this.duration, this.label);

  final Duration duration;
  final String label;
}

/// Interpretación preventiva de la evolución térmica de un NTC.
enum TemperatureTrendStatus {
  insufficientData,
  stable,
  elevated,
  low,
  rising,
  dropping,
  rapidRise,
  rapidDrop,
}

extension TemperatureTrendStatusX on TemperatureTrendStatus {
  String get label {
    switch (this) {
      case TemperatureTrendStatus.insufficientData:
        return 'Datos insuficientes';
      case TemperatureTrendStatus.stable:
        return 'Temperatura estable';
      case TemperatureTrendStatus.elevated:
        return 'Temperatura elevada';
      case TemperatureTrendStatus.low:
        return 'Temperatura baja';
      case TemperatureTrendStatus.rising:
        return 'Subiendo';
      case TemperatureTrendStatus.dropping:
        return 'Bajando';
      case TemperatureTrendStatus.rapidRise:
        return 'Aumento rápido';
      case TemperatureTrendStatus.rapidDrop:
        return 'Descenso rápido';
    }
  }
}

/// Captura histórica de la matriz de presión y la postura activa.
class PressureHistoryEntry {
  PressureHistoryEntry({
    required this.timestamp,
    required List<int> pressure,
    required this.maxPressure,
    required this.averagePressure,
    required this.hotspotIndex,
    required this.postureMode,
  }) : pressure = UnmodifiableListView<int>(List<int>.from(pressure));

  final DateTime timestamp;
  final UnmodifiableListView<int> pressure;
  final int maxPressure;
  final double averagePressure;
  final int hotspotIndex;
  final PatientPostureMode postureMode;
}

/// Captura histórica independiente de los seis sensores NTC.
class TemperatureHistoryEntry {
  TemperatureHistoryEntry({
    required this.timestamp,
    required List<double> temperatures,
    required List<bool> validity,
  }) : temperatures = UnmodifiableListView<double>(
         List<double>.from(temperatures),
       ),
       validity = UnmodifiableListView<bool>(List<bool>.from(validity));

  final DateTime timestamp;
  final UnmodifiableListView<double> temperatures;
  final UnmodifiableListView<bool> validity;
}

/// Tendencia calculada para un sensor NTC durante una ventana real de tiempo.
class NtcTrend {
  const NtcTrend({
    required this.sensorIndex,
    required this.status,
    required this.sampleCount,
    this.currentTemperature,
    this.averageTemperature,
    this.changeCelsius,
  });

  final int sensorIndex;
  final TemperatureTrendStatus status;
  final int sampleCount;
  final double? currentTemperature;
  final double? averageTemperature;
  final double? changeCelsius;

  bool get hasData => currentTemperature != null;

  String get preventiveMessage {
    switch (status) {
      case TemperatureTrendStatus.elevated:
        return 'Zona con temperatura elevada: revisar junto con presión sostenida.';
      case TemperatureTrendStatus.low:
        return 'Zona anormalmente fría: revisar presión, comodidad y condición de la piel.';
      case TemperatureTrendStatus.rapidDrop:
        return 'Descenso rápido: observar el cambio local y revisar la posición.';
      case TemperatureTrendStatus.rapidRise:
        return 'Aumento rápido: observar junto con presión y condición de la piel.';
      case TemperatureTrendStatus.insufficientData:
        return 'Mantén la lectura unos minutos para calcular la tendencia.';
      case TemperatureTrendStatus.rising:
      case TemperatureTrendStatus.dropping:
      case TemperatureTrendStatus.stable:
        return 'Tendencia complementaria; no representa un diagnóstico.';
    }
  }
}

/// Resumen derivado de una ventana del historial.
class SensorHistorySummary {
  const SensorHistorySummary({
    required this.window,
    required this.pressureSampleCount,
    required this.temperatureSampleCount,
    required this.hasFullWindow,
    required this.maximumPressure,
    required this.averagePressure,
    required this.sustainedRelativeLoad,
    required this.sustainedHotspotIndex,
    required this.ntcTrends,
  });

  factory SensorHistorySummary.empty(HistoryWindow window) {
    return SensorHistorySummary(
      window: window,
      pressureSampleCount: 0,
      temperatureSampleCount: 0,
      hasFullWindow: false,
      maximumPressure: 0,
      averagePressure: 0,
      sustainedRelativeLoad: 0,
      sustainedHotspotIndex: null,
      ntcTrends: List<NtcTrend>.generate(
        temperatureSensorCount,
        (index) => NtcTrend(
          sensorIndex: index,
          status: TemperatureTrendStatus.insufficientData,
          sampleCount: 0,
        ),
      ),
    );
  }

  final HistoryWindow window;
  final int pressureSampleCount;
  final int temperatureSampleCount;
  final bool hasFullWindow;
  final int maximumPressure;
  final double averagePressure;

  /// Porcentaje de muestras en las que la celda más persistente superó el
  /// umbral relativo configurado. No equivale a una unidad clínica.
  final double sustainedRelativeLoad;
  final int? sustainedHotspotIndex;
  final List<NtcTrend> ntcTrends;

  bool get hasAnyData => pressureSampleCount > 0 || temperatureSampleCount > 0;
}

/// Base de configuración para una calibración futura de presión.
class PressureCalibrationConfig {
  const PressureCalibrationConfig({
    this.isCalibrated = false,
    this.knownLoadKg,
    this.contactAreaCm2,
    this.externalReference,
    this.mmHgScale,
    this.mmHgOffset,
  });

  final bool isCalibrated;
  final double? knownLoadKg;
  final double? contactAreaCm2;
  final String? externalReference;
  final double? mmHgScale;
  final double? mmHgOffset;

  double? convertRelativeToMmHg(double relativeValue) {
    if (!isCalibrated || mmHgScale == null || mmHgOffset == null) {
      return null;
    }
    return relativeValue * mmHgScale! + mmHgOffset!;
  }
}
