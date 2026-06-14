import 'package:flutter/material.dart';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/core/utils/visual_mappers.dart';
import 'package:derma_sense/models/intelligent_recommendation.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/posture_labels.dart';
import 'package:derma_sense/views/widgets/common/pills.dart';
import 'package:derma_sense/views/widgets/common/premium_card.dart';
import 'package:derma_sense/views/widgets/common/section_header.dart';

/// Panel de recomendaciones inteligentes.
///
/// Calcula la [IntelligentRecommendation] a partir de la lectura y la postura, y
/// muestra su ilustración, título, acción y mensaje, junto con tres señales
/// numéricas de apoyo ([_RecommendationSignals]).
class SmartRecommendationsPanel extends StatelessWidget {
  const SmartRecommendationsPanel({
    super.key,
    required this.reading,
    required this.hasProlongedPressure,
    required this.highPressureStreak,
    required this.postureMode,
  });

  /// Lectura actual.
  final MatReading reading;

  /// `true` si hay presión alta sostenida (dispara la alerta prolongada).
  final bool hasProlongedPressure;

  /// Racha de lecturas con presión alta (para la señal "Secuencia").
  final int highPressureStreak;

  /// Modo de interpretación según la postura.
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    final recommendation = IntelligentRecommendation.fromReading(
      reading,
      hasProlongedPressure: hasProlongedPressure,
      postureMode: postureMode,
    );
    final color = riskColor(recommendation.riskLevel);
    final theme = Theme.of(context);

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Recomendaciones inteligentes',
            subtitle: postureMode.recommendationSubtitle,
            trailing: RiskBadge(level: recommendation.riskLevel),
          ),
          const SizedBox(height: 18),
          Container(
            height: 220,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: RepaintBoundary(
              child: Image.asset(
                recommendation.assetPath,
                fit: BoxFit.contain,
                cacheWidth: 720,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            recommendation.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            recommendation.action,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            recommendation.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 18),
          _RecommendationSignals(
            reading: reading,
            highPressureStreak: highPressureStreak,
            postureMode: postureMode,
          ),
        ],
      ),
    );
  }
}

/// Fila de tres señales numéricas: puntos > umbral, racha y zona del punto
/// caliente. Privada: solo la usa [SmartRecommendationsPanel].
class _RecommendationSignals extends StatelessWidget {
  const _RecommendationSignals({
    required this.reading,
    required this.highPressureStreak,
    required this.postureMode,
  });

  final MatReading reading;
  final int highPressureStreak;
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SignalTile(
            label: 'Puntos >3500',
            value: '${reading.highPressurePointCount}',
            color: reading.highPressurePointCount > 0
                ? AppColors.red
                : AppColors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SignalTile(
            label: 'Secuencia',
            value: '$highPressureStreak',
            color: highPressureStreak >= prolongedPressureFrames
                ? AppColors.red
                : AppColors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SignalTile(
            label: 'Zona',
            value: describeHotspotZone(reading, postureMode),
            color: AppColors.blue,
          ),
        ),
      ],
    );
  }
}

/// Pequeña tarjeta con una etiqueta y un valor de color. Privada.
class _SignalTile extends StatelessWidget {
  const _SignalTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
