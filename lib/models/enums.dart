/// Enumeraciones de dominio compartidas por toda la aplicación.
///
/// Reunir los `enum` en un único archivo facilita descubrir los estados
/// posibles del sistema (conexión, riesgo, postura, tipo de recomendación) sin
/// rastrearlos por la UI.
library;

/// Estado de la conexión con el ESP32 vía WebSocket.
enum Esp32ConnectionStatus {
  /// Intentando establecer la conexión.
  connecting,

  /// Conexión activa y recibiendo datos.
  connected,

  /// Conexión cerrada de forma ordenada por el otro extremo.
  disconnected,

  /// La conexión falló o no respondió a tiempo.
  error,
}

/// Nivel de riesgo clínico derivado de una lectura.
enum RiskLevel {
  /// Riesgo bajo (verde).
  low,

  /// Riesgo medio (amarillo).
  medium,

  /// Riesgo alto (rojo).
  high,
}

/// Modo de interpretación de los sensores según la postura del paciente.
///
/// La misma distribución física de NTC y presión cambia de significado si la
/// persona está sentada o acostada; por eso la app interpreta las zonas de
/// forma distinta en cada modo.
enum PatientPostureMode {
  /// Paciente sentado (sedestación).
  seated,

  /// Paciente acostado (decúbito supino).
  supine,
}

/// Tipo de recomendación inteligente mostrada al usuario.
///
/// Determina la ilustración y la intención del mensaje generado por el motor
/// de reglas clínicas.
enum RecommendationKind {
  /// Todo en orden, continuar monitoreo.
  safe,

  /// Aún no hay lecturas válidas suficientes.
  awaitingData,

  /// Alerta por presión elevada o prolongada.
  pressureAlert,

  /// Sugerir descarga/giro hacia la izquierda.
  turnLeft,

  /// Sugerir descarga/giro hacia la derecha.
  turnRight,

  /// Sugerir revisión de la piel (hiperemia).
  skinCheck,
}

/// Textos derivados del [PatientPostureMode] usados en la UI.
extension PatientPostureModeX on PatientPostureMode {
  /// Etiqueta corta para el selector de modo ("Sentado" / "Acostado").
  String get shortLabel {
    switch (this) {
      case PatientPostureMode.seated:
        return 'Sentado';
      case PatientPostureMode.supine:
        return 'Acostado';
    }
  }

  /// Subtítulo del panel de recomendaciones según la postura.
  String get recommendationSubtitle {
    switch (this) {
      case PatientPostureMode.seated:
        return 'Interpretacion orientada a sedestacion';
      case PatientPostureMode.supine:
        return 'Interpretacion orientada a decubito supino';
    }
  }

  /// Subtítulo del panel del mapa de presión según la postura.
  String get pressurePanelSubtitle {
    switch (this) {
      case PatientPostureMode.seated:
        return 'Area activa 40 x 40 cm - vista para sedestacion';
      case PatientPostureMode.supine:
        return 'Area activa 40 x 40 cm - vista para decubito supino';
    }
  }
}
