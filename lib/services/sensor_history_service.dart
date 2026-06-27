import 'dart:math';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/models/sensor_history.dart';

/// Historial en memoria de presión y de los seis NTC.
///
/// Usa timestamps reales, reduce el muestreo a una muestra por segundo y
/// elimina automáticamente datos antiguos o excedentes.
class SensorHistoryService {
  SensorHistoryService({
    this.retention = sensorHistoryRetention,
    this.minimumSampleInterval = sensorHistorySampleInterval,
    this.maxSamples = sensorHistoryMaxSamples,
  });

  final Duration retention;
  final Duration minimumSampleInterval;
  final int maxSamples;

  final List<PressureHistoryEntry> _pressureEntries = [];
  final List<TemperatureHistoryEntry> _temperatureEntries = [];
  DateTime? _lastRecordedAt;

  List<PressureHistoryEntry> get pressureEntries =>
      List<PressureHistoryEntry>.unmodifiable(_pressureEntries);
  List<TemperatureHistoryEntry> get temperatureEntries =>
      List<TemperatureHistoryEntry>.unmodifiable(_temperatureEntries);

  bool record(MatReading reading, PatientPostureMode postureMode) {
    final timestamp = reading.receivedAt;
    final previous = _lastRecordedAt;
    if (previous != null &&
        timestamp.difference(previous) < minimumSampleInterval) {
      return false;
    }

    _lastRecordedAt = timestamp;
    _pressureEntries.add(
      PressureHistoryEntry(
        timestamp: timestamp,
        pressure: reading.pressure,
        maxPressure: reading.maxPressure,
        averagePressure: reading.averagePressure,
        hotspotIndex: reading.hotspotIndex,
        postureMode: postureMode,
      ),
    );
    _temperatureEntries.add(
      TemperatureHistoryEntry(
        timestamp: timestamp,
        temperatures: reading.temperatures,
        validity: reading.temperatureValidity,
      ),
    );
    _prune(timestamp);
    return true;
  }

  SensorHistorySummary summarize(HistoryWindow window, {DateTime? now}) {
    final referenceTime = now ?? _latestTimestamp ?? DateTime.now();
    final cutoff = referenceTime.subtract(window.duration);
    final pressure = _pressureEntries
        .where((entry) => !entry.timestamp.isBefore(cutoff))
        .toList(growable: false);
    final temperature = _temperatureEntries
        .where((entry) => !entry.timestamp.isBefore(cutoff))
        .toList(growable: false);

    if (pressure.isEmpty && temperature.isEmpty) {
      return SensorHistorySummary.empty(window);
    }

    final pressureMetrics = _pressureMetrics(pressure);
    final oldestTimestamp = _oldestTimestamp(pressure, temperature);
    final requiredCoverage = Duration(
      milliseconds:
          (window.duration.inMilliseconds * minimumHistoryWindowCoverage)
              .round(),
    );
    final hasFullWindow =
        oldestTimestamp != null &&
        referenceTime.difference(oldestTimestamp) >= requiredCoverage;

    return SensorHistorySummary(
      window: window,
      pressureSampleCount: pressure.length,
      temperatureSampleCount: temperature.length,
      hasFullWindow: hasFullWindow,
      maximumPressure: pressureMetrics.maximum,
      averagePressure: pressureMetrics.average,
      sustainedRelativeLoad: pressureMetrics.sustainedLoad,
      sustainedHotspotIndex: pressureMetrics.sustainedHotspotIndex,
      ntcTrends: List<NtcTrend>.generate(
        temperatureSensorCount,
        (index) => _temperatureTrend(index, temperature),
      ),
    );
  }

  void clear() {
    _pressureEntries.clear();
    _temperatureEntries.clear();
    _lastRecordedAt = null;
  }

  DateTime? get _latestTimestamp {
    if (_pressureEntries.isNotEmpty) {
      return _pressureEntries.last.timestamp;
    }
    if (_temperatureEntries.isNotEmpty) {
      return _temperatureEntries.last.timestamp;
    }
    return null;
  }

  void _prune(DateTime now) {
    final cutoff = now.subtract(retention);
    _pressureEntries.removeWhere((entry) => entry.timestamp.isBefore(cutoff));
    _temperatureEntries.removeWhere(
      (entry) => entry.timestamp.isBefore(cutoff),
    );

    if (_pressureEntries.length > maxSamples) {
      _pressureEntries.removeRange(0, _pressureEntries.length - maxSamples);
    }
    if (_temperatureEntries.length > maxSamples) {
      _temperatureEntries.removeRange(
        0,
        _temperatureEntries.length - maxSamples,
      );
    }
  }

  _PressureMetrics _pressureMetrics(List<PressureHistoryEntry> entries) {
    if (entries.isEmpty) {
      return const _PressureMetrics();
    }

    var maximum = 0;
    var averageAccumulator = 0.0;
    final sustainedCounts = List<int>.filled(pressureCellCount, 0);
    final sustainedSums = List<int>.filled(pressureCellCount, 0);

    for (final entry in entries) {
      maximum = max(maximum, entry.maxPressure);
      averageAccumulator += entry.averagePressure;
      for (
        var index = 0;
        index < min(entry.pressure.length, pressureCellCount);
        index++
      ) {
        final value = entry.pressure[index];
        sustainedSums[index] += value;
        if (value >= sustainedPressureRelativeThreshold) {
          sustainedCounts[index]++;
        }
      }
    }

    var hotspotIndex = 0;
    for (var index = 1; index < pressureCellCount; index++) {
      final hasMoreHits =
          sustainedCounts[index] > sustainedCounts[hotspotIndex];
      final sameHitsMoreLoad =
          sustainedCounts[index] == sustainedCounts[hotspotIndex] &&
          sustainedSums[index] > sustainedSums[hotspotIndex];
      if (hasMoreHits || sameHitsMoreLoad) {
        hotspotIndex = index;
      }
    }

    final sustainedLoad =
        sustainedCounts[hotspotIndex] / entries.length * 100.0;
    final hasSustainedSignal = sustainedCounts[hotspotIndex] > 0;
    return _PressureMetrics(
      maximum: maximum,
      average: averageAccumulator / entries.length,
      sustainedLoad: sustainedLoad,
      sustainedHotspotIndex: hasSustainedSignal ? hotspotIndex : null,
    );
  }

  NtcTrend _temperatureTrend(
    int sensorIndex,
    List<TemperatureHistoryEntry> entries,
  ) {
    final valid = entries
        .where((entry) {
          return sensorIndex < entry.temperatures.length &&
              sensorIndex < entry.validity.length &&
              entry.validity[sensorIndex];
        })
        .toList(growable: false);

    if (valid.isEmpty) {
      return NtcTrend(
        sensorIndex: sensorIndex,
        status: TemperatureTrendStatus.insufficientData,
        sampleCount: 0,
      );
    }

    final current = valid.last.temperatures[sensorIndex];
    final average =
        valid
            .map((entry) => entry.temperatures[sensorIndex])
            .reduce((a, b) => a + b) /
        valid.length;
    if (valid.length < 2) {
      return NtcTrend(
        sensorIndex: sensorIndex,
        status: TemperatureTrendStatus.insufficientData,
        sampleCount: valid.length,
        currentTemperature: current,
        averageTemperature: average,
      );
    }

    final first = valid.first.temperatures[sensorIndex];
    final change = current - first;
    final status = _classifyTemperature(average, change);
    return NtcTrend(
      sensorIndex: sensorIndex,
      status: status,
      sampleCount: valid.length,
      currentTemperature: current,
      averageTemperature: average,
      changeCelsius: change,
    );
  }

  TemperatureTrendStatus _classifyTemperature(double average, double change) {
    if (change <= -rapidTemperatureChangeThresholdC) {
      return TemperatureTrendStatus.rapidDrop;
    }
    if (change >= rapidTemperatureChangeThresholdC) {
      return TemperatureTrendStatus.rapidRise;
    }
    // El promedio de la ventana distingue una zona sostenidamente caliente o
    // fría de un único pico instantáneo. Son umbrales de prototipo.
    if (average >= highTemperatureThresholdC) {
      return TemperatureTrendStatus.elevated;
    }
    if (average <= lowTemperatureThresholdC) {
      return TemperatureTrendStatus.low;
    }
    if (change >= temperatureTrendChangeThresholdC) {
      return TemperatureTrendStatus.rising;
    }
    if (change <= -temperatureTrendChangeThresholdC) {
      return TemperatureTrendStatus.dropping;
    }
    return TemperatureTrendStatus.stable;
  }

  DateTime? _oldestTimestamp(
    List<PressureHistoryEntry> pressure,
    List<TemperatureHistoryEntry> temperature,
  ) {
    DateTime? oldest;
    if (pressure.isNotEmpty) {
      oldest = pressure.first.timestamp;
    }
    if (temperature.isNotEmpty &&
        (oldest == null || temperature.first.timestamp.isBefore(oldest))) {
      oldest = temperature.first.timestamp;
    }
    return oldest;
  }
}

class _PressureMetrics {
  const _PressureMetrics({
    this.maximum = 0,
    this.average = 0,
    this.sustainedLoad = 0,
    this.sustainedHotspotIndex,
  });

  final int maximum;
  final double average;
  final double sustainedLoad;
  final int? sustainedHotspotIndex;
}
