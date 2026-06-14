import 'dart:math';

import 'package:derma_sense/core/constants/app_config.dart';

/// Una lectura completa del tapete en un instante dado (modelo de dominio).
///
/// Agrupa la matriz de presión (8x8), las temperaturas de los 6 NTC y su
/// validez, junto con el momento de recepción. Además de los datos crudos
/// expone múltiples *getters derivados* (presión máxima, promedio, conteo de
/// alertas, zona del punto caliente, etc.) que la UI y el motor de
/// recomendaciones consumen sin recalcular nada.
///
/// Es inmutable: cada mensaje del ESP32 (o cada frame simulado) produce una
/// nueva instancia.
class MatReading {
  /// Crea una lectura a partir de sus componentes ya parseados.
  MatReading({
    required this.pressure,
    required this.temperatures,
    required this.temperatureValidity,
    required this.receivedAt,
    this.isSimulated = false,
  });

  /// Lectura vacía (todo en cero, sin sensores válidos). Útil como valor
  /// inicial del `StreamBuilder` antes de recibir datos.
  factory MatReading.empty() {
    return MatReading(
      pressure: List<int>.filled(pressureCellCount, 0),
      temperatures: List<double>.filled(temperatureSensorCount, 0),
      temperatureValidity: List<bool>.filled(temperatureSensorCount, false),
      receivedAt: DateTime.now(),
    );
  }

  /// Construye una lectura a partir del JSON recibido por el WebSocket.
  ///
  /// Espera las claves `p` (presión), `t` (temperaturas) y opcionalmente `ntc`
  /// (validez por sensor). El parseo es tolerante: rellena con ceros / inválido
  /// lo que falte o venga mal formado.
  factory MatReading.fromJson(Map<String, dynamic> json) {
    final temperatures = _readTemperatureValues(json['t']);
    return MatReading(
      pressure: _readPressureValues(json['p']),
      temperatures: temperatures,
      temperatureValidity: _readTemperatureValidity(json['ntc'], temperatures),
      receivedAt: DateTime.now(),
    );
  }

  /// Genera una lectura simulada con cargas y temperaturas plausibles.
  ///
  /// Modela uno o dos focos de presión con distribuciones gaussianas más ruido,
  /// y temperaturas alrededor de 35 °C con un posible punto caliente. Se usa en
  /// el modo "Simular Datos" para probar la app sin hardware.
  factory MatReading.simulated(Random random) {
    final centerX = 1.7 + random.nextDouble() * 4.6;
    final centerY = 1.4 + random.nextDouble() * 5.0;
    final secondaryX = random.nextBool() ? 1.4 : 6.2;
    final secondaryY = 2.0 + random.nextDouble() * 4.6;

    final pressure = List<int>.generate(pressureCellCount, (index) {
      final x = index % 8;
      final y = index ~/ 8;
      final mainLoad = _gaussian(x, y, centerX, centerY, 1.45);
      final sideLoad = _gaussian(x, y, secondaryX, secondaryY, 1.05);
      final baseline = 40 + random.nextInt(120);
      final noise = random.nextInt(180);
      final value = baseline + mainLoad * 3300 + sideLoad * 1350 + noise;
      return value.round().clamp(0, maxPressureValue).toInt();
    });

    final hotSensor = random.nextInt(temperatureSensorCount);
    final temperatures = List<double>.generate(temperatureSensorCount, (index) {
      final heatBoost = index == hotSensor && random.nextBool() ? 2.6 : 0.0;
      final value = 34.7 + random.nextDouble() * 2.1 + heatBoost;
      return double.parse(value.toStringAsFixed(1));
    });

    return MatReading(
      pressure: pressure,
      temperatures: temperatures,
      temperatureValidity: List<bool>.filled(temperatureSensorCount, true),
      receivedAt: DateTime.now(),
      isSimulated: true,
    );
  }

  /// Valores de presión por celda (longitud [pressureCellCount]).
  final List<int> pressure;

  /// Temperaturas por sensor NTC en °C (longitud [temperatureSensorCount]).
  final List<double> temperatures;

  /// Validez de cada sensor NTC (true = lectura confiable).
  final List<bool> temperatureValidity;

  /// Momento en que se recibió/generó la lectura.
  final DateTime receivedAt;

  /// `true` si la lectura proviene del simulador en lugar del ESP32 real.
  final bool isSimulated;

  /// Presión máxima registrada entre todas las celdas.
  int get maxPressure => pressure.fold<int>(0, max);

  /// `true` si hay alguna señal de presión (máximo > 0).
  bool get hasAnyPressureSignal => maxPressure > 0;

  /// Presión promedio de todas las celdas.
  double get averagePressure {
    if (pressure.isEmpty) {
      return 0;
    }
    return pressure.reduce((a, b) => a + b) / pressure.length;
  }

  /// Temperatura máxima entre todos los sensores válidos (incluido ambiental).
  double get peakTemperature {
    if (!hasAnyValidTemperature) {
      return 0;
    }

    var peak = 0.0;
    for (var index = 0; index < temperatures.length; index++) {
      if (isTemperatureSensorValid(index)) {
        peak = max(peak, temperatures[index]);
      }
    }
    return peak;
  }

  /// Temperatura máxima entre los sensores clínicos válidos (sin el ambiental).
  double get peakClinicalTemperature {
    if (!hasAnyValidClinicalTemperature) {
      return 0;
    }

    var peak = 0.0;
    for (final index in clinicalTemperatureSensorIndexes) {
      if (isTemperatureSensorValid(index) && index < temperatures.length) {
        peak = max(peak, temperatures[index]);
      }
    }
    return peak;
  }

  /// Cantidad de sensores válidos cuya temperatura alcanza la precaución.
  int get temperatureAlertCount {
    var count = 0;
    for (var index = 0; index < temperatures.length; index++) {
      if (isTemperatureSensorValid(index) &&
          temperatures[index] >= cautionTemperatureCelsius) {
        count++;
      }
    }
    return count;
  }

  /// Cantidad de sensores válidos que superan el umbral de hiperemia.
  int get hyperemiaCount {
    var count = 0;
    for (var index = 0; index < temperatures.length; index++) {
      if (isTemperatureSensorValid(index) &&
          temperatures[index] > hyperemiaAlertCelsius) {
        count++;
      }
    }
    return count;
  }

  /// Número de sensores NTC válidos (incluido el ambiental).
  int get validTemperatureSensorCount {
    return temperatureValidity.where((isValid) => isValid).length;
  }

  /// `true` si hay al menos un sensor NTC válido.
  bool get hasAnyValidTemperature => validTemperatureSensorCount > 0;

  /// Número de sensores NTC clínicos válidos (excluye el ambiental).
  int get validClinicalTemperatureSensorCount {
    var count = 0;
    for (final index in clinicalTemperatureSensorIndexes) {
      if (isTemperatureSensorValid(index)) {
        count++;
      }
    }
    return count;
  }

  /// `true` si hay al menos un sensor NTC clínico válido.
  bool get hasAnyValidClinicalTemperature =>
      validClinicalTemperatureSensorCount > 0;

  /// Alertas de precaución contadas solo entre sensores clínicos.
  int get clinicalTemperatureAlertCount {
    var count = 0;
    for (final index in clinicalTemperatureSensorIndexes) {
      if (isTemperatureSensorValid(index) &&
          index < temperatures.length &&
          temperatures[index] >= cautionTemperatureCelsius) {
        count++;
      }
    }
    return count;
  }

  /// Casos de hiperemia contados solo entre sensores clínicos.
  int get clinicalHyperemiaCount {
    var count = 0;
    for (final index in clinicalTemperatureSensorIndexes) {
      if (isTemperatureSensorValid(index) &&
          index < temperatures.length &&
          temperatures[index] > hyperemiaAlertCelsius) {
        count++;
      }
    }
    return count;
  }

  /// Número de celdas cuya presión supera [prolongedPressureThreshold].
  int get highPressurePointCount {
    return pressure.where((value) => value > prolongedPressureThreshold).length;
  }

  /// Suma de presión de las columnas izquierdas (0..2) de la matriz.
  double get leftPressureSum => _columnSum(0, 2);

  /// Suma de presión de las columnas derechas (5..7) de la matriz.
  double get rightPressureSum => _columnSum(5, 7);

  /// Suma total de presión de toda la matriz.
  double get totalPressureSum {
    return pressure.fold<double>(0, (sum, value) => sum + value);
  }

  /// Índice (0..63) de la celda con mayor presión (punto caliente).
  int get hotspotIndex {
    if (pressure.isEmpty) {
      return 0;
    }

    var indexWithMax = 0;
    var maxValue = pressure.first;
    for (var index = 1; index < pressure.length; index++) {
      if (pressure[index] > maxValue) {
        maxValue = pressure[index];
        indexWithMax = index;
      }
    }
    return indexWithMax;
  }

  /// Descripción genérica (independiente de postura) de la zona del punto
  /// caliente. Para la descripción dependiente de postura ver
  /// `describeHotspotZone` en `posture_labels.dart`.
  String get hotspotZone {
    if (!hasAnyPressureSignal) {
      return 'sin lectura';
    }

    final x = hotspotIndex % 8;
    final y = hotspotIndex ~/ 8;

    if (y <= 1) {
      return 'espalda alta';
    }
    if (y >= 6 && (x <= 2 || x >= 5)) {
      return 'talones';
    }
    if (y >= 6) {
      return 'piernas';
    }
    if (x <= 2) {
      return 'lado izquierdo';
    }
    if (x >= 5) {
      return 'lado derecho';
    }
    return 'sacro';
  }

  /// Indica si el sensor NTC en [index] tiene una lectura válida.
  bool isTemperatureSensorValid(int index) {
    if (index < 0 || index >= temperatureValidity.length) {
      return false;
    }
    return temperatureValidity[index];
  }

  /// Suma la presión de un rango de columnas `[startColumn, endColumn]` sobre
  /// las 8 filas de la matriz.
  double _columnSum(int startColumn, int endColumn) {
    var sum = 0.0;
    for (var row = 0; row < 8; row++) {
      for (var column = startColumn; column <= endColumn; column++) {
        final index = row * 8 + column;
        if (index < pressure.length) {
          sum += pressure[index];
        }
      }
    }
    return sum;
  }

  /// Normaliza la lista de presión del JSON a [pressureCellCount] enteros
  /// acotados a `[0, maxPressureValue]`.
  static List<int> _readPressureValues(dynamic raw) {
    final values = raw is List ? raw : const [];
    return List<int>.generate(pressureCellCount, (index) {
      if (index >= values.length) {
        return 0;
      }
      final value = values[index];
      if (value is num) {
        return value.round().clamp(0, maxPressureValue).toInt();
      }
      return int.tryParse(
            value.toString(),
          )?.clamp(0, maxPressureValue).toInt() ??
          0;
    });
  }

  /// Normaliza la lista de temperaturas del JSON a [temperatureSensorCount]
  /// valores `double`.
  static List<double> _readTemperatureValues(dynamic raw) {
    final values = raw is List ? raw : const [];
    return List<double>.generate(temperatureSensorCount, (index) {
      if (index >= values.length) {
        return 0;
      }
      final value = values[index];
      if (value is num) {
        return value.toDouble();
      }
      return double.tryParse(value.toString()) ?? 0;
    });
  }

  /// Determina la validez de cada NTC.
  ///
  /// Usa el campo `valid` del arreglo `ntc` si viene en el JSON; en su defecto,
  /// considera válido cualquier sensor con temperatura mayor que cero.
  static List<bool> _readTemperatureValidity(
    dynamic rawNtc,
    List<double> temperatures,
  ) {
    final ntcValues = rawNtc is List ? rawNtc : const [];
    return List<bool>.generate(temperatureSensorCount, (index) {
      if (index < ntcValues.length) {
        final rawEntry = ntcValues[index];
        if (rawEntry is Map<String, dynamic>) {
          final valid = rawEntry['valid'];
          if (valid is bool) {
            return valid;
          }
          if (valid is num) {
            return valid != 0;
          }
        }
      }
      return index < temperatures.length && temperatures[index] > 0;
    });
  }

  /// Núcleo gaussiano 2D usado por [MatReading.simulated] para modelar focos
  /// de presión suaves.
  static double _gaussian(
    int x,
    int y,
    double centerX,
    double centerY,
    double sigma,
  ) {
    final dx = x - centerX;
    final dy = y - centerY;
    return exp(-(dx * dx + dy * dy) / (2 * sigma * sigma));
  }
}
