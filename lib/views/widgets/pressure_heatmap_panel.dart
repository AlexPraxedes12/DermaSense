import 'package:flutter/material.dart';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/core/utils/formatters.dart';
import 'package:derma_sense/core/utils/visual_mappers.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/models/posture_labels.dart';
import 'package:derma_sense/views/widgets/common/indicators.dart';
import 'package:derma_sense/views/widgets/common/pills.dart';
import 'package:derma_sense/views/widgets/common/premium_card.dart';
import 'package:derma_sense/views/widgets/common/section_header.dart';

/// Panel del mapa de calor de presión 8x8, con su leyenda de escala y un
/// resumen térmico en línea de los sensores NTC.
class PressureHeatmapPanel extends StatelessWidget {
  const PressureHeatmapPanel({
    super.key,
    required this.reading,
    required this.postureMode,
  });

  /// Lectura actual a representar.
  final MatReading reading;

  /// Modo de interpretación (afecta el subtítulo y las etiquetas NTC).
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Mapa de presion 8x8',
            subtitle: postureMode.pressurePanelSubtitle,
            trailing: SourceBadge(isSimulated: reading.isSimulated),
          ),
          const SizedBox(height: 18),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: _PressureHeatmap(values: reading.pressure),
            ),
          ),
          const SizedBox(height: 14),
          const _PressureLegend(),
          const SizedBox(height: 18),
          _NtcInlineSummary(reading: reading, postureMode: postureMode),
        ],
      ),
    );
  }
}

/// Rejilla 8x8 que dibuja cada celda de presión con su color. Privada.
class _PressureHeatmap extends StatelessWidget {
  const _PressureHeatmap({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 1.0;
              final cellSize = (constraints.maxWidth - spacing * 7) / 8;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var index = 0; index < pressureCellCount; index++)
                    _PressureCell(
                      index: index,
                      value: index < values.length ? values[index] : 0,
                      size: cellSize,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Una celda individual del mapa de presión, con tooltip de su valor. Privada.
class _PressureCell extends StatelessWidget {
  const _PressureCell({
    required this.index,
    required this.value,
    required this.size,
  });

  final int index;
  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Celda ${index + 1}: $value',
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: pressureColor(value),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Barra de leyenda que explica la escala de color de la presión. Privada.
class _PressureLegend extends StatelessWidget {
  const _PressureLegend();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 10,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.blue,
                  AppColors.cyan,
                  AppColors.green,
                  AppColors.yellow,
                  AppColors.red,
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(child: Text('0 baja', style: style)),
              ),
            ),
            Flexible(
              child: Center(
                child: FittedBox(child: Text('2048 media', style: style)),
              ),
            ),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(child: Text('4095 alta', style: style)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Resumen térmico en línea: temperatura clínica máxima, alertas y un chip por
/// cada sensor NTC. Privado: solo lo usa [PressureHeatmapPanel].
class _NtcInlineSummary extends StatelessWidget {
  const _NtcInlineSummary({required this.reading, required this.postureMode});

  final MatReading reading;
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Resumen termico',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              InfoPill(
                icon: reading.hasAnyValidClinicalTemperature
                    ? Icons.thermostat_rounded
                    : Icons.sensors_off_rounded,
                label: reading.hasAnyValidClinicalTemperature
                    ? formatTemperature(reading.peakClinicalTemperature)
                    : 'Sin lectura',
                color: reading.hasAnyValidClinicalTemperature
                    ? temperatureColor(reading.peakClinicalTemperature)
                    : AppColors.textSecondary,
              ),
              InfoPill(
                icon: reading.hasAnyValidClinicalTemperature
                    ? Icons.warning_amber_rounded
                    : Icons.radio_button_checked_rounded,
                label: reading.hasAnyValidClinicalTemperature
                    ? '${reading.clinicalTemperatureAlertCount} alertas'
                    : '${reading.validClinicalTemperatureSensorCount}/5 clinicos',
                color: reading.hasAnyValidClinicalTemperature
                    ? (reading.clinicalTemperatureAlertCount > 0
                          ? AppColors.orange
                          : AppColors.green)
                    : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var index = 0; index < temperatureSensorCount; index++)
                _NtcInlineChip(
                  label: ntcDisplayLabelsForMode(postureMode)[index],
                  value: index < reading.temperatures.length
                      ? reading.temperatures[index]
                      : 0.0,
                  isValid: reading.isTemperatureSensorValid(index),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip compacto con la etiqueta y temperatura de un sensor NTC. Privado.
class _NtcInlineChip extends StatelessWidget {
  const _NtcInlineChip({
    required this.label,
    required this.value,
    required this.isValid,
  });

  final String label;
  final double value;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final color = isValid ? temperatureColor(value) : AppColors.textSecondary;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TemperatureDot(color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatTemperatureLabel(value, isValid: isValid),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isValid
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
