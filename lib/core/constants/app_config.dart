/// Configuración y constantes globales de Derma Sense.
///
/// Este archivo concentra todos los "números mágicos" y cadenas de
/// configuración del proyecto: la URL del ESP32, la geometría del tapete
/// (matriz de presión y sensores NTC), los umbrales clínicos y los intervalos
/// de tiempo de la capa de red.
///
/// Centralizarlos aquí cumple dos objetivos:
/// 1. Quien se integre al proyecto encuentra en un solo lugar "qué significan"
///    los valores clínicos y de hardware.
/// 2. Ajustar un umbral (p. ej. la temperatura de hiperemia) no obliga a
///    buscar literales repartidos por la UI o la lógica.
library;

// ---------------------------------------------------------------------------
// Conexión WebSocket con el ESP32
// ---------------------------------------------------------------------------

/// URL por defecto del WebSocket que expone el ESP32 en modo Access Point.
const String defaultEsp32WebSocketUrl = 'ws://192.168.4.1:81';

/// URL inicial usada al arrancar la app.
///
/// Puede sobreescribirse en tiempo de compilación con
/// `--dart-define=ESP32_WS_URL=ws://otra-ip:puerto`, lo que resulta útil para
/// apuntar a un servidor de pruebas sin tocar el código.
const String initialEsp32WebSocketUrl = String.fromEnvironment(
  'ESP32_WS_URL',
  defaultValue: defaultEsp32WebSocketUrl,
);

/// Escenarios de simulación que el firmware/servidor mock puede activar
/// mediante el comando `mode:<valor>` enviado por el WebSocket.
const List<String> mockScenarioModes = <String>[
  'empty',
  'supine',
  'left',
  'right',
  'hotspot',
  'rolling',
];

// ---------------------------------------------------------------------------
// Geometría del tapete y sensores
// ---------------------------------------------------------------------------

/// Número de celdas de la matriz de presión (rejilla 8x8).
const int pressureCellCount = 64;

/// Número total de sensores de temperatura NTC.
const int temperatureSensorCount = 6;

/// Índice del sensor NTC usado como referencia ambiental (no clínico).
const int ambientTemperatureSensorIndex = 5;

/// Índices de los sensores NTC con relevancia clínica (excluye el ambiental).
const List<int> clinicalTemperatureSensorIndexes = <int>[0, 1, 2, 3, 4];

/// Etiquetas cortas de los NTC para el modo "Sentado" (sedestación).
const List<String> seatedNtcDisplayLabels = <String>[
  'Muslo izq.',
  'Muslo der.',
  'Isquion izq.',
  'Isquion der.',
  'Sacro',
  'Ambiente',
];

/// Etiquetas completas de los NTC para el modo "Sentado" (sedestación).
const List<String> seatedNtcFullLabels = <String>[
  'NTC1 - Muslo izquierdo',
  'NTC2 - Muslo derecho',
  'NTC3 - Isquion izquierdo',
  'NTC4 - Isquion derecho',
  'NTC5 - Sacro / coccix',
  'NTC6 - Referencia ambiental',
];

/// Etiquetas cortas de los NTC para el modo "Acostado" (decúbito supino).
const List<String> supineNtcDisplayLabels = <String>[
  'Muslo post. izq.',
  'Muslo post. der.',
  'Pelvis izq.',
  'Pelvis der.',
  'Sacro',
  'Ambiente',
];

/// Etiquetas completas de los NTC para el modo "Acostado" (decúbito supino).
const List<String> supineNtcFullLabels = <String>[
  'NTC1 - Muslo posterior izquierdo',
  'NTC2 - Muslo posterior derecho',
  'NTC3 - Pelvis / gluteo izquierdo',
  'NTC4 - Pelvis / gluteo derecho',
  'NTC5 - Sacro',
  'NTC6 - Referencia ambiental',
];

// ---------------------------------------------------------------------------
// Umbrales clínicos
// ---------------------------------------------------------------------------

/// Valor máximo que puede entregar el ADC de presión (12 bits).
const int maxPressureValue = 4095;

/// Temperatura considerada segura: por debajo de este valor no hay alerta.
const double safeTemperatureCelsius = 37.2;

/// Temperatura de precaución: a partir de aquí se cuenta como alerta térmica.
const double cautionTemperatureCelsius = 37.5;

/// Temperatura de hiperemia: por encima sugiere revisar la piel.
const double hyperemiaAlertCelsius = 37.8;

/// Presión por celda a partir de la cual un punto se considera "alto".
const int prolongedPressureThreshold = 3500;

/// Número de lecturas consecutivas con presión alta que disparan la alerta de
/// presión prolongada.
const int prolongedPressureFrames = 3;

// ---------------------------------------------------------------------------
// Tiempos de la capa de red / UI
// ---------------------------------------------------------------------------

/// Intervalo mínimo entre actualizaciones de la UI (limita la frecuencia de
/// repintado aunque el ESP32 envíe datos más rápido).
const Duration uiUpdateInterval = Duration(milliseconds: 120);

/// Ventana de silencio entre mensajes de error de parseo para no inundar la UI.
const Duration socketParseErrorInterval = Duration(seconds: 2);

/// Tiempo máximo de espera para establecer la conexión WebSocket.
const Duration websocketConnectTimeout = Duration(seconds: 4);

// ---------------------------------------------------------------------------
// Rutas de assets (ilustraciones de recomendación)
// ---------------------------------------------------------------------------

/// Ilustración de estado seguro / sin alertas.
const String safeAsset = 'assets/estado_seguro.png';

/// Ilustración de alerta de presión.
const String pressureAlertAsset = 'assets/alerta_presion.png';

/// Ilustración para sugerir giro/descarga hacia la izquierda.
const String turnLeftAsset = 'assets/girar_izq.png';

/// Ilustración para sugerir giro/descarga hacia la derecha.
const String turnRightAsset = 'assets/girar_der.png';

/// Ilustración para sugerir revisión de la piel (hiperemia).
const String skinCheckAsset = 'assets/revisar_piel.png';
