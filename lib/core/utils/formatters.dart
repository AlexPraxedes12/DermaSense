/// Funciones puras de formateo de texto reutilizadas por la UI.
///
/// No dependen de Flutter ni de estado: reciben un valor y devuelven la cadena
/// lista para mostrar. Mantenerlas separadas evita duplicar el formato de
/// temperaturas u horas en cada widget.
library;

/// Formatea una temperatura en grados Celsius con un decimal, p. ej. `37.5 °C`.
String formatTemperature(double value) {
  return '${value.toStringAsFixed(1)} °C';
}

/// Formatea una temperatura para una etiqueta, devolviendo `Sin lectura`
/// cuando el sensor no es válido en lugar de un número engañoso.
String formatTemperatureLabel(double value, {required bool isValid}) {
  if (!isValid) {
    return 'Sin lectura';
  }
  return formatTemperature(value);
}

/// Convierte el identificador interno de un escenario mock en su etiqueta
/// legible para los chips de la UI.
String mockModeKey(String mode) {
  return switch (mode) {
    'empty' => 'mock_empty',
    'supine' => 'mock_supine',
    'left' => 'mock_left',
    'right' => 'mock_right',
    'hotspot' => 'mock_hotspot',
    'rolling' => 'mock_rolling',
    _ => mode,
  };
}

/// Formatea una marca de tiempo como `HH:mm:ss`, usada para "Ultima lectura".
String formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final second = dateTime.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}
