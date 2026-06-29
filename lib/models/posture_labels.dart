import 'package:derma_sense/core/localization/app_localizations.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/mat_reading.dart';

/// Funciones que traducen la postura del paciente en etiquetas y zonas
/// anatómicas.
///
/// La misma posición física de un sensor significa una zona distinta del cuerpo
/// según la persona esté sentada o acostada; estas funciones encapsulan esa
/// correspondencia para que la UI y las recomendaciones hablen el mismo idioma.

/// Etiquetas cortas de los NTC para el [mode] indicado.
List<String> ntcDisplayLabelsForMode(
  PatientPostureMode mode,
  AppLocalizations l10n,
) {
  final seated = mode == PatientPostureMode.seated;
  return List.generate(6, (index) => l10n.ntcShortLabel(seated, index));
}

/// Etiquetas completas de los NTC para el [mode] indicado.
List<String> ntcFullLabelsForMode(
  PatientPostureMode mode,
  AppLocalizations l10n,
) {
  final seated = mode == PatientPostureMode.seated;
  return List.generate(6, (index) => l10n.ntcFullLabel(seated, index));
}

/// Describe la zona anatómica del punto caliente de [reading] interpretada
/// según [postureMode].
///
/// A diferencia de `MatReading.hotspotZone` (genérica), aquí la fila/columna de
/// la celda con mayor presión se traduce a regiones específicas de sedestación
/// (isquion, muslo, sacro) o de decúbito supino (pelvis, muslo posterior).
String describeHotspotZone(
  MatReading reading,
  PatientPostureMode postureMode,
  AppLocalizations l10n,
) {
  if (!reading.hasAnyPressureSignal) {
    return l10n.text('zone_no_reading');
  }

  final x = reading.hotspotIndex % 8;
  final y = reading.hotspotIndex ~/ 8;

  switch (postureMode) {
    case PatientPostureMode.seated:
      if (y <= 1) {
        return l10n.text('zone_sacrum_coccyx');
      }
      if (y <= 4) {
        return x <= 3
            ? l10n.text('zone_left_ischium')
            : l10n.text('zone_right_ischium');
      }
      return x <= 3
          ? l10n.text('zone_left_thigh')
          : l10n.text('zone_right_thigh');
    case PatientPostureMode.supine:
      if (y <= 1) {
        return l10n.text('zone_sacrum');
      }
      if (y <= 4) {
        return x <= 3
            ? l10n.text('zone_left_pelvis')
            : l10n.text('zone_right_pelvis');
      }
      return x <= 3
          ? l10n.text('zone_left_posterior_thigh')
          : l10n.text('zone_right_posterior_thigh');
  }
}
