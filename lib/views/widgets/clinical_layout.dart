import 'package:flutter/material.dart';

import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/views/widgets/pressure_heatmap_panel.dart';
import 'package:derma_sense/views/widgets/smart_recommendations_panel.dart';
import 'package:derma_sense/views/widgets/summary_grid.dart';
import 'package:derma_sense/views/widgets/temperature_section.dart';

/// Contenido en vivo del dashboard para una [MatReading] dada: la rejilla de
/// métricas resumidas más el layout clínico (presión, temperatura y
/// recomendaciones).
///
/// Es el subárbol que el `StreamBuilder` reconstruye con cada nueva lectura.
class LiveDashboardContent extends StatelessWidget {
  const LiveDashboardContent({
    super.key,
    required this.reading,
    required this.hasProlongedPressure,
    required this.highPressureStreak,
    required this.postureMode,
  });

  /// Lectura actual a representar.
  final MatReading reading;

  /// `true` si hay presión alta sostenida.
  final bool hasProlongedPressure;

  /// Racha de lecturas con presión alta.
  final int highPressureStreak;

  /// Modo de interpretación según la postura.
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryGrid(reading: reading),
        const SizedBox(height: 20),
        _ResponsiveClinicalLayout(
          reading: reading,
          hasProlongedPressure: hasProlongedPressure,
          highPressureStreak: highPressureStreak,
          postureMode: postureMode,
        ),
      ],
    );
  }
}

/// Distribuye los tres paneles clínicos según el ancho disponible: en pantallas
/// anchas (>= 940 px) los pone en dos columnas; en pantallas estrechas los
/// apila en vertical. Privado: solo lo usa [LiveDashboardContent].
class _ResponsiveClinicalLayout extends StatelessWidget {
  const _ResponsiveClinicalLayout({
    required this.reading,
    required this.hasProlongedPressure,
    required this.highPressureStreak,
    required this.postureMode,
  });

  final MatReading reading;
  final bool hasProlongedPressure;
  final int highPressureStreak;
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pressurePanel = PressureHeatmapPanel(
          reading: reading,
          postureMode: postureMode,
        );
        final temperaturePanel = TemperatureSection(
          reading: reading,
          postureMode: postureMode,
        );
        final recommendationsPanel = SmartRecommendationsPanel(
          reading: reading,
          hasProlongedPressure: hasProlongedPressure,
          highPressureStreak: highPressureStreak,
          postureMode: postureMode,
        );

        if (constraints.maxWidth >= 940) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    pressurePanel,
                    const SizedBox(height: 20),
                    temperaturePanel,
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(width: 370, child: recommendationsPanel),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            pressurePanel,
            const SizedBox(height: 20),
            recommendationsPanel,
            const SizedBox(height: 20),
            temperaturePanel,
          ],
        );
      },
    );
  }
}
