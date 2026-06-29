import 'package:flutter/material.dart';

import 'package:derma_sense/core/localization/app_localizations.dart';
import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/core/utils/formatters.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/posture_labels.dart';
import 'package:derma_sense/models/sensor_history.dart';
import 'package:derma_sense/views/widgets/common/premium_card.dart';
import 'package:derma_sense/views/widgets/common/section_header.dart';

/// Panel preventivo de historial de presión y tendencias de los seis NTC.
class HistoryTrendsPanel extends StatelessWidget {
  const HistoryTrendsPanel({
    super.key,
    required this.summary,
    required this.selectedWindow,
    required this.postureMode,
    required this.onWindowChanged,
  });

  final SensorHistorySummary summary;
  final HistoryWindow selectedWindow;
  final PatientPostureMode postureMode;
  final ValueChanged<HistoryWindow> onWindowChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: l10n.text('history_trends'),
            subtitle: l10n.text('history_subtitle'),
            trailing: _WindowSelector(
              selected: selectedWindow,
              onChanged: onWindowChanged,
            ),
          ),
          const SizedBox(height: 18),
          if (!summary.hasFullWindow)
            _InformationBanner(
              text: summary.hasAnyData
                  ? l10n.text('history_incomplete')
                  : l10n.text('history_waiting'),
            ),
          if (!summary.hasFullWindow) const SizedBox(height: 14),
          _PressureWindowMetrics(summary: summary),
          const SizedBox(height: 18),
          Text(
            l10n.text('trend_by_sensor'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          _TemperatureTrendGrid(
            trends: summary.ntcTrends,
            postureMode: postureMode,
          ),
          const SizedBox(height: 16),
          const _CalibrationNote(),
        ],
      ),
    );
  }
}

class _WindowSelector extends StatelessWidget {
  const _WindowSelector({required this.selected, required this.onChanged});

  final HistoryWindow selected;
  final ValueChanged<HistoryWindow> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<HistoryWindow>(
      segments: HistoryWindow.values
          .map(
            (window) => ButtonSegment<HistoryWindow>(
              value: window,
              label: SizedBox(
                width: 48,
                child: Text(
                  window.label,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
          .toList(growable: false),
      selected: <HistoryWindow>{selected},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -2, vertical: -2),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
      ),
    );
  }
}

class _PressureWindowMetrics extends StatelessWidget {
  const _PressureWindowMetrics({required this.summary});

  final SensorHistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hotspot = summary.sustainedHotspotIndex;
    final hotspotLabel = hotspot == null
        ? l10n.text('no_persistent_load')
        : l10n.text('row_column', {
            'row': hotspot ~/ 8 + 1,
            'column': hotspot % 8 + 1,
          });
    final items = <_TrendMetricData>[
      _TrendMetricData(
        icon: Icons.speed_rounded,
        label: l10n.text('pressure_max'),
        value: '${summary.maximumPressure}',
        color: AppColors.orange,
      ),
      _TrendMetricData(
        icon: Icons.functions_rounded,
        label: l10n.text('average_pressure'),
        value: summary.averagePressure.toStringAsFixed(0),
        color: AppColors.cyan,
      ),
      _TrendMetricData(
        icon: Icons.timelapse_rounded,
        label: l10n.text('sustained_load'),
        value: '${summary.sustainedRelativeLoad.toStringAsFixed(0)} %',
        color: AppColors.blue,
      ),
      _TrendMetricData(
        icon: Icons.grid_on_rounded,
        label: l10n.text('persistent_zone'),
        value: hotspotLabel,
        color: AppColors.green,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 420
            ? 1
            : constraints.maxWidth < 860
            ? 2
            : 4;
        const spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _TrendMetric(data: item),
              ),
          ],
        );
      },
    );
  }
}

class _TrendMetricData {
  const _TrendMetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _TrendMetric extends StatelessWidget {
  const _TrendMetric({required this.data});

  final _TrendMetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(data.icon, color: data.color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  data.label,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
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

class _TemperatureTrendGrid extends StatelessWidget {
  const _TemperatureTrendGrid({
    required this.trends,
    required this.postureMode,
  });

  final List<NtcTrend> trends;
  final PatientPostureMode postureMode;

  @override
  Widget build(BuildContext context) {
    final labels = ntcDisplayLabelsForMode(postureMode, context.l10n);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 480
            ? 1
            : constraints.maxWidth < 920
            ? 2
            : 3;
        const spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final trend in trends)
              SizedBox(
                width: width,
                child: _TemperatureTrendTile(
                  trend: trend,
                  label: labels[trend.sensorIndex],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TemperatureTrendTile extends StatelessWidget {
  const _TemperatureTrendTile({required this.trend, required this.label});

  final NtcTrend trend;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _trendColor(trend.status);
    final change = trend.changeCelsius;
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_trendIcon(trend.status), color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                trend.currentTemperature == null
                    ? '--'
                    : formatTemperature(trend.currentTemperature!),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            _trendLabel(context.l10n, trend.status),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          if (change != null)
            Text(
              context.l10n.text('temperature_change', {
                'change':
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
              }),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0,
              ),
            ),
          if (_isPreventiveAlert(trend.status)) ...[
            const SizedBox(height: 5),
            Text(
              _preventiveMessage(context.l10n, trend.status),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InformationBanner extends StatelessWidget {
  const _InformationBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.blue.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blue.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationNote extends StatelessWidget {
  const _CalibrationNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.text('calibration_note'),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
        letterSpacing: 0,
      ),
    );
  }
}

String _trendLabel(AppLocalizations l10n, TemperatureTrendStatus status) {
  final key = switch (status) {
    TemperatureTrendStatus.insufficientData => 'trend_insufficient',
    TemperatureTrendStatus.stable => 'trend_stable',
    TemperatureTrendStatus.elevated => 'trend_elevated',
    TemperatureTrendStatus.low => 'trend_low',
    TemperatureTrendStatus.rising => 'trend_rising',
    TemperatureTrendStatus.dropping => 'trend_dropping',
    TemperatureTrendStatus.rapidRise => 'trend_rapid_rise',
    TemperatureTrendStatus.rapidDrop => 'trend_rapid_drop',
  };
  return l10n.text(key);
}

String _preventiveMessage(
  AppLocalizations l10n,
  TemperatureTrendStatus status,
) {
  final key = switch (status) {
    TemperatureTrendStatus.elevated => 'preventive_elevated',
    TemperatureTrendStatus.low => 'preventive_low',
    TemperatureTrendStatus.rapidDrop => 'preventive_rapid_drop',
    TemperatureTrendStatus.rapidRise => 'preventive_rapid_rise',
    TemperatureTrendStatus.insufficientData => 'preventive_wait',
    _ => 'preventive_default',
  };
  return l10n.text(key);
}

bool _isPreventiveAlert(TemperatureTrendStatus status) {
  return status == TemperatureTrendStatus.elevated ||
      status == TemperatureTrendStatus.low ||
      status == TemperatureTrendStatus.rapidDrop ||
      status == TemperatureTrendStatus.rapidRise;
}

Color _trendColor(TemperatureTrendStatus status) {
  switch (status) {
    case TemperatureTrendStatus.elevated:
    case TemperatureTrendStatus.rapidRise:
      return AppColors.orange;
    case TemperatureTrendStatus.low:
    case TemperatureTrendStatus.rapidDrop:
      return AppColors.blue;
    case TemperatureTrendStatus.rising:
    case TemperatureTrendStatus.dropping:
      return AppColors.cyan;
    case TemperatureTrendStatus.stable:
      return AppColors.green;
    case TemperatureTrendStatus.insufficientData:
      return AppColors.textSecondary;
  }
}

IconData _trendIcon(TemperatureTrendStatus status) {
  switch (status) {
    case TemperatureTrendStatus.elevated:
      return Icons.thermostat_rounded;
    case TemperatureTrendStatus.low:
      return Icons.ac_unit_rounded;
    case TemperatureTrendStatus.rising:
    case TemperatureTrendStatus.rapidRise:
      return Icons.trending_up_rounded;
    case TemperatureTrendStatus.dropping:
    case TemperatureTrendStatus.rapidDrop:
      return Icons.trending_down_rounded;
    case TemperatureTrendStatus.stable:
      return Icons.trending_flat_rounded;
    case TemperatureTrendStatus.insufficientData:
      return Icons.hourglass_empty_rounded;
  }
}
