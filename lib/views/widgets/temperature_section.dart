import 'package:flutter/material.dart';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/core/localization/app_localizations.dart';
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

/// Sección de detalle de temperatura: encabezado con conteo de alertas y una
/// rejilla con una tarjeta por cada sensor NTC (5 clínicos + 1 ambiental).
class TemperatureSection extends StatelessWidget {
  const TemperatureSection({
    super.key,
    required this.reading,
    required this.postureMode,
  });

  /// Lectura actual a representar.
  final MatReading reading;

  /// Modo de interpretación (afecta etiquetas y subtítulo).
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final postureLabel = l10n.text(
      postureMode == PatientPostureMode.seated ? 'seated' : 'supine',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SectionHeader(
            title: l10n.text('temperature_detail'),
            subtitle: l10n.text('temperature_subtitle', {
              'posture': postureLabel.toLowerCase(),
            }),
            trailing: InfoPill(
              icon: reading.hasAnyValidClinicalTemperature
                  ? Icons.warning_amber_rounded
                  : Icons.sensors_off_rounded,
              label: reading.hasAnyValidClinicalTemperature
                  ? l10n.text('alerts', {
                      'count': reading.clinicalTemperatureAlertCount,
                    })
                  : l10n.text('clinical_count', {
                      'count': reading.validClinicalTemperatureSensorCount,
                    }),
              color: reading.hasAnyValidClinicalTemperature
                  ? (reading.clinicalTemperatureAlertCount > 0
                        ? AppColors.orange
                        : AppColors.green)
                  : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _TemperatureGrid(reading: reading, postureMode: postureMode),
      ],
    );
  }
}

/// Rejilla responsive (1, 2 o 3 columnas) de tarjetas de temperatura. Privada.
class _TemperatureGrid extends StatelessWidget {
  const _TemperatureGrid({required this.reading, required this.postureMode});

  final MatReading reading;
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 320
            ? 1
            : constraints.maxWidth < 760
            ? 2
            : 3;
        const spacing = 14.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final itemHeight = columns == 1 ? 102.0 : 108.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var index = 0; index < temperatureSensorCount; index++)
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _TemperatureCard(
                  index: index,
                  value: index < reading.temperatures.length
                      ? reading.temperatures[index]
                      : 0.0,
                  isValid: reading.isTemperatureSensorValid(index),
                  postureMode: postureMode,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Tarjeta de un sensor NTC: punto de color, etiqueta completa, temperatura e
/// ícono de estado. Privada: solo la usa [_TemperatureGrid].
class _TemperatureCard extends StatelessWidget {
  const _TemperatureCard({
    required this.index,
    required this.value,
    required this.isValid,
    required this.postureMode,
  });

  final int index;
  final double value;
  final bool isValid;
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    final color = isValid ? temperatureColor(value) : AppColors.textSecondary;
    final theme = Theme.of(context);

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TemperatureDot(color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ntcFullLabelsForMode(postureMode, context.l10n)[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isValid
                        ? formatTemperature(value)
                        : context.l10n.text('no_reading'),
                    maxLines: 1,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isValid
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            isValid ? temperatureIcon(value) : Icons.sensors_off_rounded,
            color: color,
            size: 22,
          ),
        ],
      ),
    );
  }
}
