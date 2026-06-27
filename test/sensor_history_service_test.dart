import 'package:flutter_test/flutter_test.dart';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/models/sensor_history.dart';
import 'package:derma_sense/services/sensor_history_service.dart';

void main() {
  group('SensorHistoryService', () {
    test('filters samples using their real timestamps', () {
      final service = _service();
      final now = DateTime(2026, 6, 26, 12);

      service.record(
        _reading(at: now.subtract(const Duration(minutes: 8))),
        PatientPostureMode.supine,
      );
      service.record(_reading(at: now), PatientPostureMode.supine);

      final fiveMinutes = service.summarize(
        HistoryWindow.fiveMinutes,
        now: now,
      );
      final tenMinutes = service.summarize(HistoryWindow.tenMinutes, now: now);

      expect(fiveMinutes.pressureSampleCount, 1);
      expect(fiveMinutes.temperatureSampleCount, 1);
      expect(tenMinutes.pressureSampleCount, 2);
      expect(tenMinutes.temperatureSampleCount, 2);
    });

    test('calculates pressure maximum average and sustained load', () {
      final service = _service();
      final now = DateTime(2026, 6, 26, 12);

      service.record(
        _reading(
          at: now.subtract(const Duration(seconds: 2)),
          pressure: _pressure(cell: 10, value: 2400),
        ),
        PatientPostureMode.seated,
      );
      service.record(
        _reading(
          at: now.subtract(const Duration(seconds: 1)),
          pressure: _pressure(cell: 10, value: 3000),
        ),
        PatientPostureMode.seated,
      );

      final summary = service.summarize(HistoryWindow.fiveMinutes, now: now);

      expect(summary.maximumPressure, 3000);
      expect(summary.averagePressure, closeTo(42.1875, 0.001));
      expect(summary.sustainedHotspotIndex, 10);
      expect(summary.sustainedRelativeLoad, 100);
    });

    test('classifies elevated and low values across six NTC series', () {
      final service = _service();
      final now = DateTime(2026, 6, 26, 12);
      final temperatures = <double>[38, 24, 30, 30, 30, 30];

      service.record(
        _reading(
          at: now.subtract(const Duration(seconds: 2)),
          temperatures: temperatures,
        ),
        PatientPostureMode.supine,
      );
      service.record(
        _reading(at: now, temperatures: temperatures),
        PatientPostureMode.supine,
      );

      final trends = service
          .summarize(HistoryWindow.fiveMinutes, now: now)
          .ntcTrends;

      expect(trends, hasLength(temperatureSensorCount));
      expect(trends[0].status, TemperatureTrendStatus.elevated);
      expect(trends[1].status, TemperatureTrendStatus.low);
      for (final index in <int>[2, 3, 4, 5]) {
        expect(trends[index].status, TemperatureTrendStatus.stable);
      }
    });

    test('detects rising dropping and rapid thermal changes', () {
      final service = _service();
      final now = DateTime(2026, 6, 26, 12);

      service.record(
        _reading(
          at: now.subtract(const Duration(minutes: 4)),
          temperatures: const <double>[30, 30, 31, 31, 30, 30],
        ),
        PatientPostureMode.supine,
      );
      service.record(
        _reading(
          at: now,
          temperatures: const <double>[30.6, 29.4, 33, 29, 30, 30],
        ),
        PatientPostureMode.supine,
      );

      final trends = service
          .summarize(HistoryWindow.fiveMinutes, now: now)
          .ntcTrends;

      expect(trends[0].status, TemperatureTrendStatus.rising);
      expect(trends[1].status, TemperatureTrendStatus.dropping);
      expect(trends[2].status, TemperatureTrendStatus.rapidRise);
      expect(trends[3].status, TemperatureTrendStatus.rapidDrop);
    });

    test('reports insufficient data for missing or single readings', () {
      final service = _service();
      final now = DateTime(2026, 6, 26, 12);

      service.record(
        _reading(
          at: now,
          validity: const <bool>[true, false, false, false, false, false],
        ),
        PatientPostureMode.supine,
      );

      final trends = service
          .summarize(HistoryWindow.fifteenMinutes, now: now)
          .ntcTrends;

      expect(trends[0].status, TemperatureTrendStatus.insufficientData);
      expect(trends[0].sampleCount, 1);
      for (var index = 1; index < temperatureSensorCount; index++) {
        expect(trends[index].status, TemperatureTrendStatus.insufficientData);
        expect(trends[index].sampleCount, 0);
      }
    });
  });
}

SensorHistoryService _service() {
  return SensorHistoryService(
    minimumSampleInterval: Duration.zero,
    retention: const Duration(minutes: 30),
    maxSamples: 1800,
  );
}

MatReading _reading({
  required DateTime at,
  List<int>? pressure,
  List<double>? temperatures,
  List<bool>? validity,
}) {
  return MatReading(
    pressure: pressure ?? List<int>.filled(pressureCellCount, 0),
    temperatures:
        temperatures ?? List<double>.filled(temperatureSensorCount, 30),
    temperatureValidity:
        validity ?? List<bool>.filled(temperatureSensorCount, true),
    receivedAt: at,
  );
}

List<int> _pressure({required int cell, required int value}) {
  final pressure = List<int>.filled(pressureCellCount, 0);
  pressure[cell] = value;
  return pressure;
}
