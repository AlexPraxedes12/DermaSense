import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Lightweight application localization for Spanish, English and French.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('fr'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String text(String key, [Map<String, Object> values = const {}]) {
    var result =
        _values[locale.languageCode]?[key] ?? _values['es']![key] ?? key;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return result;
  }

  String languageName(String code) => text('language_$code');

  String ntcShortLabel(bool seated, int index) {
    return text('${seated ? 'seated' : 'supine'}_ntc_short_${index + 1}');
  }

  String ntcFullLabel(bool seated, int index) {
    return text('${seated ? 'seated' : 'supine'}_ntc_full_${index + 1}');
  }

  static const Map<String, Map<String, String>> _values = {
    'es': {
      'language': 'Idioma',
      'language_es': 'Español',
      'language_en': 'Inglés',
      'language_fr': 'Francés',
      'apply_url': 'Aplicar URL',
      'reconnect': 'Reconectar',
      'simulate_data': 'Simular datos',
      'stop': 'Detener',
      'interactive_demo': 'Demo interactiva',
      'interactive_demo_description':
          'Explora presión, temperatura, tendencias y recomendaciones con datos simulados.',
      'interpretation_mode': 'Modo de interpretación',
      'interpretation_description':
          'La misma distribución física de NTC y presión cambia de significado si la persona está sentada o acostada.',
      'seated': 'Sentado',
      'supine': 'Acostado',
      'pressure_max': 'Presión máxima',
      'average': 'Promedio',
      'clinical_temp_max': 'Temp. clínica máx.',
      'last_reading': 'Última lectura',
      'no_reading': 'Sin lectura',
      'pressure_map': 'Mapa de presión 8x8',
      'pressure_seated_subtitle':
          'Área activa 40 x 40 cm · vista para sedestación',
      'pressure_supine_subtitle':
          'Área activa 40 x 40 cm · vista para decúbito supino',
      'cell_value': 'Celda {cell}: {value}',
      'low_scale': '0 baja',
      'mid_scale': '2048 media',
      'high_scale': '4095 alta',
      'thermal_summary': 'Resumen térmico',
      'alerts': '{count} alertas',
      'clinical_count': '{count}/5 clínicos',
      'temperature_detail': 'Detalle de temperatura NTC',
      'temperature_subtitle':
          '5 sensores clínicos + 1 referencia ambiental ({posture})',
      'smart_recommendations': 'Recomendaciones inteligentes',
      'recommendation_seated_subtitle':
          'Interpretación orientada a sedestación',
      'recommendation_supine_subtitle':
          'Interpretación orientada a decúbito supino',
      'points_threshold': 'Puntos >3500',
      'sequence': 'Secuencia',
      'zone': 'Zona',
      'history_trends': 'Historial y tendencias',
      'history_subtitle': 'Presión relativa y evolución térmica preventiva',
      'history_incomplete':
          'Aún no hay suficientes datos para completar esta ventana.',
      'history_waiting': 'Esperando lecturas para iniciar el historial.',
      'trend_by_sensor': 'Tendencia por sensor NTC',
      'average_pressure': 'Presión promedio',
      'sustained_load': 'Carga sostenida relativa',
      'persistent_zone': 'Zona más persistente',
      'no_persistent_load': 'Sin carga persistente',
      'row_column': 'Fila {row}, columna {column}',
      'temperature_change': 'Cambio {change} °C',
      'calibration_note':
          'Lecturas relativas: requieren calibración para interpretación clínica. Las tendencias térmicas son señales complementarias, no diagnósticos.',
      'mock_scenarios': 'Escenarios de prueba',
      'snapshot': 'Captura',
      'mock_empty': 'Vacío',
      'mock_supine': 'Supino',
      'mock_left': 'Carga izq.',
      'mock_right': 'Carga der.',
      'mock_hotspot': 'Punto crítico',
      'mock_rolling': 'Movimiento',
      'connecting': 'Conectando',
      'connected': 'Conectado',
      'disconnected': 'Desconectado',
      'error': 'Error',
      'risk': 'Riesgo {level}',
      'risk_low': 'Verde',
      'risk_medium': 'Amarillo',
      'risk_high': 'Rojo',
      'trend_insufficient': 'Datos insuficientes',
      'trend_stable': 'Temperatura estable',
      'trend_elevated': 'Temperatura elevada',
      'trend_low': 'Temperatura baja',
      'trend_rising': 'Subiendo',
      'trend_dropping': 'Bajando',
      'trend_rapid_rise': 'Aumento rápido',
      'trend_rapid_drop': 'Descenso rápido',
      'preventive_elevated':
          'Zona con temperatura elevada: revisar junto con presión sostenida.',
      'preventive_low':
          'Zona anormalmente fría: revisar presión, comodidad y condición de la piel.',
      'preventive_rapid_drop':
          'Descenso rápido: observar el cambio local y revisar la posición.',
      'preventive_rapid_rise':
          'Aumento rápido: observar junto con presión y condición de la piel.',
      'preventive_wait':
          'Mantén la lectura unos minutos para calcular la tendencia.',
      'preventive_default':
          'Tendencia complementaria; no representa un diagnóstico.',
      'zone_no_reading': 'sin lectura',
      'zone_sacrum_coccyx': 'sacro / cóccix',
      'zone_left_ischium': 'isquion izquierdo',
      'zone_right_ischium': 'isquion derecho',
      'zone_left_thigh': 'muslo izquierdo',
      'zone_right_thigh': 'muslo derecho',
      'zone_sacrum': 'sacro',
      'zone_left_pelvis': 'pelvis / glúteo izquierdo',
      'zone_right_pelvis': 'pelvis / glúteo derecho',
      'zone_left_posterior_thigh': 'muslo posterior izquierdo',
      'zone_right_posterior_thigh': 'muslo posterior derecho',
      'seated_ntc_short_1': 'Muslo izq.',
      'seated_ntc_short_2': 'Muslo der.',
      'seated_ntc_short_3': 'Isquion izq.',
      'seated_ntc_short_4': 'Isquion der.',
      'seated_ntc_short_5': 'Sacro',
      'seated_ntc_short_6': 'Ambiente',
      'seated_ntc_full_1': 'NTC1 · Muslo izquierdo',
      'seated_ntc_full_2': 'NTC2 · Muslo derecho',
      'seated_ntc_full_3': 'NTC3 · Isquion izquierdo',
      'seated_ntc_full_4': 'NTC4 · Isquion derecho',
      'seated_ntc_full_5': 'NTC5 · Sacro / cóccix',
      'seated_ntc_full_6': 'NTC6 · Referencia ambiental',
      'supine_ntc_short_1': 'Muslo post. izq.',
      'supine_ntc_short_2': 'Muslo post. der.',
      'supine_ntc_short_3': 'Pelvis izq.',
      'supine_ntc_short_4': 'Pelvis der.',
      'supine_ntc_short_5': 'Sacro',
      'supine_ntc_short_6': 'Ambiente',
      'supine_ntc_full_1': 'NTC1 · Muslo posterior izquierdo',
      'supine_ntc_full_2': 'NTC2 · Muslo posterior derecho',
      'supine_ntc_full_3': 'NTC3 · Pelvis / glúteo izquierdo',
      'supine_ntc_full_4': 'NTC4 · Pelvis / glúteo derecho',
      'supine_ntc_full_5': 'NTC5 · Sacro',
      'supine_ntc_full_6': 'NTC6 · Referencia ambiental',
      'rec_skin_title': 'Revisar piel',
      'rec_skin_action': 'Evaluar hiperemia',
      'rec_skin_message':
          'Un sensor NTC supera {temperature}. Revisa coloración, humedad y temperatura local en {zone} antes de continuar.',
      'rec_prolonged_title': 'Alerta de presión',
      'rec_prolonged_action': 'Descargar zona crítica',
      'rec_prolonged_message_seated':
          'Hay puntos sobre {threshold} durante varias lecturas. El foco principal está en {zone}. Reacomoda la sedestación y alivia la presión con el cojín o la superficie de apoyo.',
      'rec_prolonged_message_supine':
          'Hay puntos sobre {threshold} durante varias lecturas. El foco principal está en {zone}. Redistribuye el apoyo con un cambio de posición, cuña o almohada y confirma una nueva lectura.',
      'rec_right_title_seated': 'Descargar lado derecho',
      'rec_right_title_supine': 'Redistribuir hacia la izquierda',
      'rec_right_action_seated': 'Inclinar o apoyar más hacia la izquierda',
      'rec_right_action_supine': 'Reducir apoyo en hemipelvis derecha',
      'rec_right_message_seated':
          'La presión se concentra en el lado derecho de la matriz. Realiza una descarga breve de ese lado o ajusta la postura y confirma una nueva lectura.',
      'rec_right_message_supine':
          'La presión se concentra en el lado derecho de la matriz. Haz un cambio postural suave hacia la izquierda y confirma una nueva lectura.',
      'rec_left_title_seated': 'Descargar lado izquierdo',
      'rec_left_title_supine': 'Redistribuir hacia la derecha',
      'rec_left_action_seated': 'Inclinar o apoyar más hacia la derecha',
      'rec_left_action_supine': 'Reducir apoyo en hemipelvis izquierda',
      'rec_left_message_seated':
          'La presión se concentra en el lado izquierdo de la matriz. Realiza una descarga breve de ese lado o ajusta la postura y confirma una nueva lectura.',
      'rec_left_message_supine':
          'La presión se concentra en el lado izquierdo de la matriz. Haz un cambio postural suave hacia la derecha y confirma una nueva lectura.',
      'rec_elevated_title': 'Presión elevada',
      'rec_elevated_action_seated': 'Ajustar apoyo en sedestación',
      'rec_elevated_action_supine': 'Ajustar apoyo en decúbito',
      'rec_elevated_message_seated':
          'Se detecta presión alta en {zone}. Si se mantiene, descarga peso, corrige la postura y revisa el cojín.',
      'rec_elevated_message_supine':
          'Se detecta presión alta en {zone}. Si se mantiene, cambia el apoyo, usa una cuña o almohada y revisa el acolchado.',
      'rec_wait_title': 'Esperando lecturas',
      'rec_wait_action': 'Verificar sensores',
      'rec_wait_pressure':
          'El mapa de presión ya transmite, pero los NTC clínicos aún no entregan lecturas válidas. Revisa montaje, divisor de 6.8 kΩ y cableado.',
      'rec_wait_empty':
          'El ESP32 está activo, pero todavía no hay lecturas válidas de presión ni temperatura. Verifica tapete, NTC y ADS1115.',
      'rec_safe_title': 'Estado seguro',
      'rec_safe_action': 'Continuar monitoreo',
      'rec_safe_message_seated':
          'La presión promedio es baja y las temperaturas están por debajo de {temperature}. Mantén vigilancia de la postura y del tiempo en sedestación.',
      'rec_safe_message_supine':
          'La presión promedio es baja y las temperaturas están por debajo de {temperature}. Mantén vigilancia del apoyo sacro-pélvico y de los cambios de posición.',
      'rec_monitor_title': 'Monitoreo preventivo',
      'rec_monitor_action': 'Revisar tendencia',
      'rec_monitor_message_seated':
          'Los valores se mantienen dentro de un rango aceptable, pero conviene observar la tendencia de presión y temperatura. Si la carga se concentra, ajusta la sedestación antes de que aparezca molestia.',
      'rec_monitor_message_supine':
          'Los valores se mantienen dentro de un rango aceptable, pero conviene observar la tendencia de presión y temperatura. Si el apoyo se concentra, redistribuye la posición antes de que la zona se caliente.',
      'socket_timeout':
          'ESP32 sin respuesta. Usa la simulación o pulsa Reconectar cuando esté disponible.',
      'invalid_url':
          'URL inválida. Usa algo como ws://192.168.4.1:81 o ws://127.0.0.1:81',
      'socket_unavailable':
          'No se pudo conectar al ESP32. Verifica Wi-Fi/IP o usa Simular datos.',
      'socket_error': 'Conexión ESP32 no disponible: {error}',
      'invalid_json': 'El JSON debe ser un objeto.',
      'discarded_data': 'Dato descartado: {error}',
      'no_active_socket': 'No hay un WebSocket activo para enviar comandos.',
      'command_error': 'No se pudo enviar el comando: {error}',
    },
    'en': {
      'language': 'Language',
      'language_es': 'Spanish',
      'language_en': 'English',
      'language_fr': 'French',
      'apply_url': 'Apply URL',
      'reconnect': 'Reconnect',
      'simulate_data': 'Simulate data',
      'stop': 'Stop',
      'interactive_demo': 'Interactive demo',
      'interactive_demo_description':
          'Explore pressure, temperature, trends and recommendations with simulated data.',
      'interpretation_mode': 'Interpretation mode',
      'interpretation_description':
          'The same physical NTC and pressure layout has a different meaning when the person is seated or lying down.',
      'seated': 'Seated',
      'supine': 'Lying down',
      'pressure_max': 'Maximum pressure',
      'average': 'Average',
      'clinical_temp_max': 'Max. clinical temp.',
      'last_reading': 'Last reading',
      'no_reading': 'No reading',
      'pressure_map': '8x8 pressure map',
      'pressure_seated_subtitle': '40 x 40 cm active area · seated view',
      'pressure_supine_subtitle': '40 x 40 cm active area · supine view',
      'cell_value': 'Cell {cell}: {value}',
      'low_scale': '0 low',
      'mid_scale': '2048 medium',
      'high_scale': '4095 high',
      'thermal_summary': 'Thermal summary',
      'alerts': '{count} alerts',
      'clinical_count': '{count}/5 clinical',
      'temperature_detail': 'NTC temperature detail',
      'temperature_subtitle':
          '5 clinical sensors + 1 ambient reference ({posture})',
      'smart_recommendations': 'Smart recommendations',
      'recommendation_seated_subtitle': 'Seated-position interpretation',
      'recommendation_supine_subtitle': 'Supine-position interpretation',
      'points_threshold': 'Points >3500',
      'sequence': 'Sequence',
      'zone': 'Zone',
      'history_trends': 'History and trends',
      'history_subtitle': 'Relative pressure and preventive thermal evolution',
      'history_incomplete':
          'There is not enough data yet to complete this window.',
      'history_waiting': 'Waiting for readings to start history.',
      'trend_by_sensor': 'Trend by NTC sensor',
      'average_pressure': 'Average pressure',
      'sustained_load': 'Relative sustained load',
      'persistent_zone': 'Most persistent zone',
      'no_persistent_load': 'No persistent load',
      'row_column': 'Row {row}, column {column}',
      'temperature_change': 'Change {change} °C',
      'calibration_note':
          'Relative readings require calibration for clinical interpretation. Thermal trends are complementary signals, not diagnoses.',
      'mock_scenarios': 'Test scenarios',
      'snapshot': 'Snapshot',
      'mock_empty': 'Empty',
      'mock_supine': 'Supine',
      'mock_left': 'Left load',
      'mock_right': 'Right load',
      'mock_hotspot': 'Hotspot',
      'mock_rolling': 'Movement',
      'connecting': 'Connecting',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'error': 'Error',
      'risk': '{level} risk',
      'risk_low': 'Green',
      'risk_medium': 'Yellow',
      'risk_high': 'Red',
      'trend_insufficient': 'Insufficient data',
      'trend_stable': 'Stable temperature',
      'trend_elevated': 'Elevated temperature',
      'trend_low': 'Low temperature',
      'trend_rising': 'Rising',
      'trend_dropping': 'Dropping',
      'trend_rapid_rise': 'Rapid rise',
      'trend_rapid_drop': 'Rapid drop',
      'preventive_elevated':
          'Elevated temperature zone: review together with sustained pressure.',
      'preventive_low':
          'Unusually cold zone: review pressure, comfort and skin condition.',
      'preventive_rapid_drop':
          'Rapid drop: observe the local change and review positioning.',
      'preventive_rapid_rise':
          'Rapid rise: observe together with pressure and skin condition.',
      'preventive_wait':
          'Keep the reading active for a few minutes to calculate its trend.',
      'preventive_default':
          'Complementary trend; it does not represent a diagnosis.',
      'zone_no_reading': 'no reading',
      'zone_sacrum_coccyx': 'sacrum / coccyx',
      'zone_left_ischium': 'left ischium',
      'zone_right_ischium': 'right ischium',
      'zone_left_thigh': 'left thigh',
      'zone_right_thigh': 'right thigh',
      'zone_sacrum': 'sacrum',
      'zone_left_pelvis': 'left pelvis / gluteal area',
      'zone_right_pelvis': 'right pelvis / gluteal area',
      'zone_left_posterior_thigh': 'left posterior thigh',
      'zone_right_posterior_thigh': 'right posterior thigh',
      'seated_ntc_short_1': 'Left thigh',
      'seated_ntc_short_2': 'Right thigh',
      'seated_ntc_short_3': 'Left ischium',
      'seated_ntc_short_4': 'Right ischium',
      'seated_ntc_short_5': 'Sacrum',
      'seated_ntc_short_6': 'Ambient',
      'seated_ntc_full_1': 'NTC1 · Left thigh',
      'seated_ntc_full_2': 'NTC2 · Right thigh',
      'seated_ntc_full_3': 'NTC3 · Left ischium',
      'seated_ntc_full_4': 'NTC4 · Right ischium',
      'seated_ntc_full_5': 'NTC5 · Sacrum / coccyx',
      'seated_ntc_full_6': 'NTC6 · Ambient reference',
      'supine_ntc_short_1': 'Left post. thigh',
      'supine_ntc_short_2': 'Right post. thigh',
      'supine_ntc_short_3': 'Left pelvis',
      'supine_ntc_short_4': 'Right pelvis',
      'supine_ntc_short_5': 'Sacrum',
      'supine_ntc_short_6': 'Ambient',
      'supine_ntc_full_1': 'NTC1 · Left posterior thigh',
      'supine_ntc_full_2': 'NTC2 · Right posterior thigh',
      'supine_ntc_full_3': 'NTC3 · Left pelvis / gluteal area',
      'supine_ntc_full_4': 'NTC4 · Right pelvis / gluteal area',
      'supine_ntc_full_5': 'NTC5 · Sacrum',
      'supine_ntc_full_6': 'NTC6 · Ambient reference',
      'rec_skin_title': 'Check skin',
      'rec_skin_action': 'Assess hyperemia',
      'rec_skin_message':
          'An NTC sensor is above {temperature}. Check color, moisture and local temperature at {zone} before continuing.',
      'rec_prolonged_title': 'Pressure alert',
      'rec_prolonged_action': 'Unload critical zone',
      'rec_prolonged_message_seated':
          'Points remained above {threshold} for several readings. The main focus is {zone}. Reposition the seated support and relieve pressure with the cushion or support surface.',
      'rec_prolonged_message_supine':
          'Points remained above {threshold} for several readings. The main focus is {zone}. Redistribute support with a position change, wedge or pillow and confirm a new reading.',
      'rec_right_title_seated': 'Unload right side',
      'rec_right_title_supine': 'Redistribute to the left',
      'rec_right_action_seated': 'Lean or support more toward the left',
      'rec_right_action_supine': 'Reduce support on the right hemipelvis',
      'rec_right_message_seated':
          'Pressure is concentrated on the right side of the matrix. Briefly unload that side or adjust posture and confirm a new reading.',
      'rec_right_message_supine':
          'Pressure is concentrated on the right side of the matrix. Make a gentle position change toward the left and confirm a new reading.',
      'rec_left_title_seated': 'Unload left side',
      'rec_left_title_supine': 'Redistribute to the right',
      'rec_left_action_seated': 'Lean or support more toward the right',
      'rec_left_action_supine': 'Reduce support on the left hemipelvis',
      'rec_left_message_seated':
          'Pressure is concentrated on the left side of the matrix. Briefly unload that side or adjust posture and confirm a new reading.',
      'rec_left_message_supine':
          'Pressure is concentrated on the left side of the matrix. Make a gentle position change toward the right and confirm a new reading.',
      'rec_elevated_title': 'Elevated pressure',
      'rec_elevated_action_seated': 'Adjust seated support',
      'rec_elevated_action_supine': 'Adjust supine support',
      'rec_elevated_message_seated':
          'High pressure is detected at {zone}. If it persists, unload weight, correct posture and check the cushion.',
      'rec_elevated_message_supine':
          'High pressure is detected at {zone}. If it persists, change support, use a wedge or pillow and check padding.',
      'rec_wait_title': 'Waiting for readings',
      'rec_wait_action': 'Check sensors',
      'rec_wait_pressure':
          'The pressure map is transmitting, but the clinical NTC sensors do not yet provide valid readings. Check mounting, the 6.8 kΩ divider and wiring.',
      'rec_wait_empty':
          'The ESP32 is active, but there are no valid pressure or temperature readings yet. Check the mat, NTC sensors and ADS1115.',
      'rec_safe_title': 'Safe state',
      'rec_safe_action': 'Continue monitoring',
      'rec_safe_message_seated':
          'Average pressure is low and temperatures are below {temperature}. Continue monitoring posture and seated time.',
      'rec_safe_message_supine':
          'Average pressure is low and temperatures are below {temperature}. Continue monitoring sacral-pelvic support and position changes.',
      'rec_monitor_title': 'Preventive monitoring',
      'rec_monitor_action': 'Review trend',
      'rec_monitor_message_seated':
          'Values remain within an acceptable range, but pressure and temperature trends should be observed. If load concentrates, adjust seating before discomfort appears.',
      'rec_monitor_message_supine':
          'Values remain within an acceptable range, but pressure and temperature trends should be observed. If support concentrates, redistribute position before the zone warms.',
      'socket_timeout':
          'ESP32 did not respond. Use simulation or tap Reconnect when it is available.',
      'invalid_url':
          'Invalid URL. Use ws://192.168.4.1:81 or ws://127.0.0.1:81',
      'socket_unavailable':
          'Could not connect to the ESP32. Check Wi-Fi/IP or use simulated data.',
      'socket_error': 'ESP32 connection unavailable: {error}',
      'invalid_json': 'JSON must be an object.',
      'discarded_data': 'Discarded data: {error}',
      'no_active_socket': 'There is no active WebSocket for sending commands.',
      'command_error': 'Could not send command: {error}',
    },
    'fr': {
      'language': 'Langue',
      'language_es': 'Espagnol',
      'language_en': 'Anglais',
      'language_fr': 'Français',
      'apply_url': 'Appliquer URL',
      'reconnect': 'Reconnecter',
      'simulate_data': 'Simuler les données',
      'stop': 'Arrêter',
      'interactive_demo': 'Démo interactive',
      'interactive_demo_description':
          'Explorez la pression, la température, les tendances et les recommandations avec des données simulées.',
      'interpretation_mode': "Mode d'interprétation",
      'interpretation_description':
          "La même disposition physique des NTC et de la pression change de sens selon que la personne est assise ou allongée.",
      'seated': 'Assis',
      'supine': 'Allongé',
      'pressure_max': 'Pression maximale',
      'average': 'Moyenne',
      'clinical_temp_max': 'Temp. clinique max.',
      'last_reading': 'Dernière lecture',
      'no_reading': 'Aucune lecture',
      'pressure_map': 'Carte de pression 8x8',
      'pressure_seated_subtitle': 'Zone active 40 x 40 cm · vue assise',
      'pressure_supine_subtitle':
          'Zone active 40 x 40 cm · vue en décubitus dorsal',
      'cell_value': 'Cellule {cell} : {value}',
      'low_scale': '0 faible',
      'mid_scale': '2048 moyenne',
      'high_scale': '4095 élevée',
      'thermal_summary': 'Résumé thermique',
      'alerts': '{count} alertes',
      'clinical_count': '{count}/5 cliniques',
      'temperature_detail': 'Détail des températures NTC',
      'temperature_subtitle':
          '5 capteurs cliniques + 1 référence ambiante ({posture})',
      'smart_recommendations': 'Recommandations intelligentes',
      'recommendation_seated_subtitle': "Interprétation en position assise",
      'recommendation_supine_subtitle': 'Interprétation en décubitus dorsal',
      'points_threshold': 'Points >3500',
      'sequence': 'Séquence',
      'zone': 'Zone',
      'history_trends': 'Historique et tendances',
      'history_subtitle': 'Pression relative et évolution thermique préventive',
      'history_incomplete':
          "Il n'y a pas encore assez de données pour compléter cette fenêtre.",
      'history_waiting': "En attente de mesures pour démarrer l'historique.",
      'trend_by_sensor': 'Tendance par capteur NTC',
      'average_pressure': 'Pression moyenne',
      'sustained_load': 'Charge relative soutenue',
      'persistent_zone': 'Zone la plus persistante',
      'no_persistent_load': 'Aucune charge persistante',
      'row_column': 'Ligne {row}, colonne {column}',
      'temperature_change': 'Variation {change} °C',
      'calibration_note':
          "Les mesures relatives nécessitent un étalonnage pour une interprétation clinique. Les tendances thermiques sont des signaux complémentaires, pas des diagnostics.",
      'mock_scenarios': 'Scénarios de test',
      'snapshot': 'Capture',
      'mock_empty': 'Vide',
      'mock_supine': 'Décubitus',
      'mock_left': 'Charge gauche',
      'mock_right': 'Charge droite',
      'mock_hotspot': 'Point critique',
      'mock_rolling': 'Mouvement',
      'connecting': 'Connexion',
      'connected': 'Connecté',
      'disconnected': 'Déconnecté',
      'error': 'Erreur',
      'risk': 'Risque {level}',
      'risk_low': 'Vert',
      'risk_medium': 'Jaune',
      'risk_high': 'Rouge',
      'trend_insufficient': 'Données insuffisantes',
      'trend_stable': 'Température stable',
      'trend_elevated': 'Température élevée',
      'trend_low': 'Température basse',
      'trend_rising': 'En hausse',
      'trend_dropping': 'En baisse',
      'trend_rapid_rise': 'Hausse rapide',
      'trend_rapid_drop': 'Baisse rapide',
      'preventive_elevated':
          'Zone à température élevée : à examiner avec la pression soutenue.',
      'preventive_low':
          'Zone anormalement froide : vérifier la pression, le confort et la peau.',
      'preventive_rapid_drop':
          'Baisse rapide : observer le changement local et revoir la position.',
      'preventive_rapid_rise':
          'Hausse rapide : observer avec la pression et l’état de la peau.',
      'preventive_wait':
          'Maintenez la mesure quelques minutes pour calculer la tendance.',
      'preventive_default':
          'Tendance complémentaire ; elle ne constitue pas un diagnostic.',
      'zone_no_reading': 'aucune lecture',
      'zone_sacrum_coccyx': 'sacrum / coccyx',
      'zone_left_ischium': 'ischion gauche',
      'zone_right_ischium': 'ischion droit',
      'zone_left_thigh': 'cuisse gauche',
      'zone_right_thigh': 'cuisse droite',
      'zone_sacrum': 'sacrum',
      'zone_left_pelvis': 'bassin / région fessière gauche',
      'zone_right_pelvis': 'bassin / région fessière droite',
      'zone_left_posterior_thigh': 'face postérieure de la cuisse gauche',
      'zone_right_posterior_thigh': 'face postérieure de la cuisse droite',
      'seated_ntc_short_1': 'Cuisse gauche',
      'seated_ntc_short_2': 'Cuisse droite',
      'seated_ntc_short_3': 'Ischion gauche',
      'seated_ntc_short_4': 'Ischion droit',
      'seated_ntc_short_5': 'Sacrum',
      'seated_ntc_short_6': 'Ambiance',
      'seated_ntc_full_1': 'NTC1 · Cuisse gauche',
      'seated_ntc_full_2': 'NTC2 · Cuisse droite',
      'seated_ntc_full_3': 'NTC3 · Ischion gauche',
      'seated_ntc_full_4': 'NTC4 · Ischion droit',
      'seated_ntc_full_5': 'NTC5 · Sacrum / coccyx',
      'seated_ntc_full_6': 'NTC6 · Référence ambiante',
      'supine_ntc_short_1': 'Cuisse post. gauche',
      'supine_ntc_short_2': 'Cuisse post. droite',
      'supine_ntc_short_3': 'Bassin gauche',
      'supine_ntc_short_4': 'Bassin droit',
      'supine_ntc_short_5': 'Sacrum',
      'supine_ntc_short_6': 'Ambiance',
      'supine_ntc_full_1': 'NTC1 · Face postérieure de la cuisse gauche',
      'supine_ntc_full_2': 'NTC2 · Face postérieure de la cuisse droite',
      'supine_ntc_full_3': 'NTC3 · Bassin / région fessière gauche',
      'supine_ntc_full_4': 'NTC4 · Bassin / région fessière droite',
      'supine_ntc_full_5': 'NTC5 · Sacrum',
      'supine_ntc_full_6': 'NTC6 · Référence ambiante',
      'rec_skin_title': 'Vérifier la peau',
      'rec_skin_action': "Évaluer l'hyperémie",
      'rec_skin_message':
          'Un capteur NTC dépasse {temperature}. Vérifiez la coloration, l’humidité et la température locale au niveau de {zone} avant de continuer.',
      'rec_prolonged_title': 'Alerte de pression',
      'rec_prolonged_action': 'Décharger la zone critique',
      'rec_prolonged_message_seated':
          'Des points sont restés au-dessus de {threshold} pendant plusieurs mesures. La zone principale est {zone}. Repositionnez l’appui assis et soulagez la pression avec le coussin ou la surface de support.',
      'rec_prolonged_message_supine':
          'Des points sont restés au-dessus de {threshold} pendant plusieurs mesures. La zone principale est {zone}. Redistribuez l’appui avec un changement de position, une cale ou un oreiller, puis confirmez une nouvelle mesure.',
      'rec_right_title_seated': 'Décharger le côté droit',
      'rec_right_title_supine': 'Redistribuer vers la gauche',
      'rec_right_action_seated': "S'incliner ou s'appuyer davantage à gauche",
      'rec_right_action_supine': "Réduire l'appui sur l'hémibassin droit",
      'rec_right_message_seated':
          'La pression est concentrée sur le côté droit de la matrice. Déchargez brièvement ce côté ou ajustez la posture, puis confirmez une nouvelle mesure.',
      'rec_right_message_supine':
          'La pression est concentrée sur le côté droit de la matrice. Effectuez un changement postural doux vers la gauche, puis confirmez une nouvelle mesure.',
      'rec_left_title_seated': 'Décharger le côté gauche',
      'rec_left_title_supine': 'Redistribuer vers la droite',
      'rec_left_action_seated': "S'incliner ou s'appuyer davantage à droite",
      'rec_left_action_supine': "Réduire l'appui sur l'hémibassin gauche",
      'rec_left_message_seated':
          'La pression est concentrée sur le côté gauche de la matrice. Déchargez brièvement ce côté ou ajustez la posture, puis confirmez une nouvelle mesure.',
      'rec_left_message_supine':
          'La pression est concentrée sur le côté gauche de la matrice. Effectuez un changement postural doux vers la droite, puis confirmez une nouvelle mesure.',
      'rec_elevated_title': 'Pression élevée',
      'rec_elevated_action_seated': "Ajuster l'appui assis",
      'rec_elevated_action_supine': "Ajuster l'appui en décubitus",
      'rec_elevated_message_seated':
          'Une pression élevée est détectée au niveau de {zone}. Si elle persiste, déchargez le poids, corrigez la posture et vérifiez le coussin.',
      'rec_elevated_message_supine':
          'Une pression élevée est détectée au niveau de {zone}. Si elle persiste, changez l’appui, utilisez une cale ou un oreiller et vérifiez le rembourrage.',
      'rec_wait_title': 'En attente de mesures',
      'rec_wait_action': 'Vérifier les capteurs',
      'rec_wait_pressure':
          'La carte de pression transmet, mais les capteurs NTC cliniques ne fournissent pas encore de mesures valides. Vérifiez le montage, le diviseur de 6,8 kΩ et le câblage.',
      'rec_wait_empty':
          "L'ESP32 est actif, mais aucune mesure valide de pression ou de température n'est encore disponible. Vérifiez le tapis, les NTC et l'ADS1115.",
      'rec_safe_title': 'État sûr',
      'rec_safe_action': 'Continuer la surveillance',
      'rec_safe_message_seated':
          'La pression moyenne est faible et les températures sont inférieures à {temperature}. Continuez à surveiller la posture et la durée en position assise.',
      'rec_safe_message_supine':
          'La pression moyenne est faible et les températures sont inférieures à {temperature}. Continuez à surveiller l’appui sacro-pelvien et les changements de position.',
      'rec_monitor_title': 'Surveillance préventive',
      'rec_monitor_action': 'Examiner la tendance',
      'rec_monitor_message_seated':
          'Les valeurs restent dans une plage acceptable, mais les tendances de pression et de température doivent être observées. Si la charge se concentre, ajustez la position assise avant l’apparition d’une gêne.',
      'rec_monitor_message_supine':
          'Les valeurs restent dans une plage acceptable, mais les tendances de pression et de température doivent être observées. Si l’appui se concentre, redistribuez la position avant que la zone ne se réchauffe.',
      'socket_timeout':
          "L'ESP32 ne répond pas. Utilisez la simulation ou Reconnecter lorsqu'il est disponible.",
      'invalid_url':
          'URL invalide. Utilisez ws://192.168.4.1:81 ou ws://127.0.0.1:81',
      'socket_unavailable':
          "Connexion à l'ESP32 impossible. Vérifiez le Wi-Fi/l'IP ou utilisez la simulation.",
      'socket_error': 'Connexion ESP32 indisponible : {error}',
      'invalid_json': 'Le JSON doit être un objet.',
      'discarded_data': 'Donnée ignorée : {error}',
      'no_active_socket': "Aucun WebSocket actif pour envoyer des commandes.",
      'command_error': "Impossible d'envoyer la commande : {error}",
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
