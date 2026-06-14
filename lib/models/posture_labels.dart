import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/mat_reading.dart';

/// Funciones que traducen la postura del paciente en etiquetas y zonas
/// anatómicas.
///
/// La misma posición física de un sensor significa una zona distinta del cuerpo
/// según la persona esté sentada o acostada; estas funciones encapsulan esa
/// correspondencia para que la UI y las recomendaciones hablen el mismo idioma.

/// Etiquetas cortas de los NTC para el [mode] indicado.
List<String> ntcDisplayLabelsForMode(PatientPostureMode mode) {
  switch (mode) {
    case PatientPostureMode.seated:
      return seatedNtcDisplayLabels;
    case PatientPostureMode.supine:
      return supineNtcDisplayLabels;
  }
}

/// Etiquetas completas de los NTC para el [mode] indicado.
List<String> ntcFullLabelsForMode(PatientPostureMode mode) {
  switch (mode) {
    case PatientPostureMode.seated:
      return seatedNtcFullLabels;
    case PatientPostureMode.supine:
      return supineNtcFullLabels;
  }
}

/// Describe la zona anatómica del punto caliente de [reading] interpretada
/// según [postureMode].
///
/// A diferencia de `MatReading.hotspotZone` (genérica), aquí la fila/columna de
/// la celda con mayor presión se traduce a regiones específicas de sedestación
/// (isquion, muslo, sacro) o de decúbito supino (pelvis, muslo posterior).
String describeHotspotZone(MatReading reading, PatientPostureMode postureMode) {
  if (!reading.hasAnyPressureSignal) {
    return 'sin lectura';
  }

  final x = reading.hotspotIndex % 8;
  final y = reading.hotspotIndex ~/ 8;

  switch (postureMode) {
    case PatientPostureMode.seated:
      if (y <= 1) {
        return 'sacro / coccix';
      }
      if (y <= 4) {
        return x <= 3 ? 'isquion izquierdo' : 'isquion derecho';
      }
      return x <= 3 ? 'muslo izquierdo' : 'muslo derecho';
    case PatientPostureMode.supine:
      if (y <= 1) {
        return 'sacro';
      }
      if (y <= 4) {
        return x <= 3 ? 'pelvis / gluteo izquierdo' : 'pelvis / gluteo derecho';
      }
      return x <= 3 ? 'muslo posterior izquierdo' : 'muslo posterior derecho';
  }
}
