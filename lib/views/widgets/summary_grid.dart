import 'package:flutter/material.dart';

import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/core/utils/formatters.dart';
import 'package:derma_sense/core/utils/visual_mappers.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/views/widgets/common/premium_card.dart';

/// Rejilla superior con las cuatro métricas clave de la lectura actual:
/// presión máxima, presión promedio, temperatura clínica máxima y hora de la
/// última lectura.
///
/// El número de columnas (1, 2 o 4) se adapta al ancho disponible.
class SummaryGrid extends StatelessWidget {
  const SummaryGrid({super.key, required this.reading});

  /// Lectura actual de la que se derivan las métricas.
  final MatReading reading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 320
            ? 1
            : constraints.maxWidth < 760
            ? 2
            : 4;
        const spacing = 14.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final itemHeight = columns == 1 ? 104.0 : 110.0;
        final cards = [
          _MetricCard(
            icon: Icons.speed_rounded,
            label: 'Presion maxima',
            value: '${reading.maxPressure}',
            accent: pressureColor(reading.maxPressure),
          ),
          _MetricCard(
            icon: Icons.grid_view_rounded,
            label: 'Promedio',
            value: reading.averagePressure.round().toString(),
            accent: AppColors.cyan,
          ),
          _MetricCard(
            icon: reading.hasAnyValidClinicalTemperature
                ? Icons.thermostat_rounded
                : Icons.sensors_off_rounded,
            label: 'Temp. clinica max.',
            value: reading.hasAnyValidClinicalTemperature
                ? formatTemperature(reading.peakClinicalTemperature)
                : 'Sin lectura',
            accent: reading.hasAnyValidClinicalTemperature
                ? temperatureColor(reading.peakClinicalTemperature)
                : AppColors.textSecondary,
          ),
          _MetricCard(
            icon: Icons.schedule_rounded,
            label: 'Ultima lectura',
            value: formatTime(reading.receivedAt),
            accent: AppColors.orange,
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(width: itemWidth, height: itemHeight, child: card),
          ],
        );
      },
    );
  }
}

/// Tarjeta individual de métrica: ícono con acento de color, valor destacado y
/// etiqueta descriptiva. Privada porque solo la usa [SummaryGrid].
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withAlpha(24),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
