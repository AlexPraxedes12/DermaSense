import 'package:flutter/material.dart';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/models/enums.dart';

/// Mapeadores que traducen valores de dominio (presión, temperatura, riesgo) a
/// elementos visuales (colores, íconos, etiquetas).
///
/// Son funciones puras: aíslan la "regla de color" de los widgets para que la
/// representación visual sea consistente en todo el dashboard y fácil de
/// ajustar en un solo lugar.

/// Devuelve el color del mapa de calor para un valor de presión crudo.
///
/// Interpola sobre una escala azul → cian → verde → amarillo → rojo según la
/// fracción del valor respecto a [maxPressureValue].
Color pressureColor(int rawValue) {
  final value = rawValue.clamp(0, maxPressureValue) / maxPressureValue;
  const stops = [
    AppColors.blue,
    AppColors.cyan,
    AppColors.green,
    AppColors.yellow,
    AppColors.red,
  ];

  if (value <= 0.25) {
    return Color.lerp(stops[0], stops[1], value / 0.25)!;
  }
  if (value <= 0.5) {
    return Color.lerp(stops[1], stops[2], (value - 0.25) / 0.25)!;
  }
  if (value <= 0.75) {
    return Color.lerp(stops[2], stops[3], (value - 0.5) / 0.25)!;
  }
  return Color.lerp(stops[3], stops[4], (value - 0.75) / 0.25)!;
}

/// Devuelve el color asociado a una temperatura: verde (seguro), naranja
/// (precaución) o rojo (hiperemia).
Color temperatureColor(double value) {
  if (value > hyperemiaAlertCelsius) {
    return AppColors.red;
  }
  if (value >= safeTemperatureCelsius) {
    return AppColors.orange;
  }
  return AppColors.green;
}

/// Devuelve el ícono asociado a una temperatura según su nivel de alerta.
IconData temperatureIcon(double value) {
  if (value > hyperemiaAlertCelsius) {
    return Icons.priority_high_rounded;
  }
  if (value >= safeTemperatureCelsius) {
    return Icons.thermostat_rounded;
  }
  return Icons.check_rounded;
}

/// Devuelve el color asociado a un [RiskLevel].
Color riskColor(RiskLevel level) {
  return switch (level) {
    RiskLevel.low => AppColors.green,
    RiskLevel.medium => AppColors.orange,
    RiskLevel.high => AppColors.red,
  };
}

/// Devuelve la etiqueta de color (semáforo) asociada a un [RiskLevel].
String riskLabel(RiskLevel level) {
  return switch (level) {
    RiskLevel.low => 'Verde',
    RiskLevel.medium => 'Amarillo',
    RiskLevel.high => 'Rojo',
  };
}
