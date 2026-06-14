import 'package:flutter/material.dart';

/// Paleta de colores central de Derma Sense.
///
/// Mantener todos los colores aquí (en lugar de literales `Color(0x...)`
/// repartidos por la UI) permite cambiar la identidad visual de la app desde
/// un solo lugar y garantiza consistencia entre pantallas y widgets.
///
/// Convención de uso:
/// - [background] / [card] / [border]: superficies y contenedores.
/// - [textPrimary] / [textSecondary]: jerarquía tipográfica.
/// - [blue] / [cyan] / [green] / [yellow] / [orange] / [red]: acentos y
///   estados (riesgo, presión, temperatura).
class AppColors {
  /// Fondo general de la aplicación (gris muy claro).
  static const background = Color(0xFFF5F7FA);

  /// Superficie de tarjetas y paneles.
  static const card = Color(0xFFFFFFFF);

  /// Color principal de texto (títulos y valores).
  static const textPrimary = Color(0xFF101828);

  /// Color secundario de texto (etiquetas y descripciones).
  static const textSecondary = Color(0xFF667085);

  /// Borde sutil para tarjetas, chips e inputs.
  static const border = Color(0xFFE9EEF5);

  /// Azul corporativo: color primario del tema y de acentos clave.
  static const blue = Color(0xFF0B4EA2);

  /// Cian de apoyo (métricas neutras, escala de presión media-baja).
  static const cyan = Color(0xFF00A6D6);

  /// Verde de estado seguro / riesgo bajo.
  static const green = Color(0xFF1EC997);

  /// Amarillo de transición en escalas de presión.
  static const yellow = Color(0xFFFFC857);

  /// Rojo de alerta crítica / riesgo alto.
  static const red = Color(0xFFFF3B30);

  /// Naranja de advertencia / riesgo medio.
  static const orange = Color(0xFFFF9500);

  /// Sombra ligera reutilizada por tarjetas y píldoras.
  static const shadow = Color(0x0D000000);
}
