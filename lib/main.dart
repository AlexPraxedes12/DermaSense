import 'package:flutter/material.dart';

import 'package:derma_sense/app.dart';

// Se reexporta [MedicalMatApp] para que `import 'package:derma_sense/main.dart'`
// siga exponiendo el widget raíz (lo usan, p. ej., las pruebas de widget).
export 'package:derma_sense/app.dart' show MedicalMatApp;

/// Punto de entrada de la aplicación Derma Sense.
///
/// La estructura del proyecto sigue una separación por capas estilo MVVM:
/// - `core/`        → configuración, tema y utilidades transversales.
/// - `models/`      → datos y lógica de dominio ([MatReading], recomendaciones).
/// - `viewmodels/`  → estado y orquestación (`DashboardController`).
/// - `views/`       → pantallas y widgets de presentación.
///
/// Ver `ARCHITECTURE.md` en la raíz del repositorio para una guía completa.
void main() {
  runApp(const MedicalMatApp());
}
