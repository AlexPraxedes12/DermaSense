import 'package:flutter/material.dart';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/core/localization/app_localizations.dart';
import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/core/utils/formatters.dart';

/// Panel de escenarios mock que aparece cuando el origen remoto declara estar
/// en modo simulación.
///
/// Permite pedir una captura ("Snapshot") y seleccionar entre los
/// [mockScenarioModes] disponibles; cada selección envía un comando al firmware.
class MockScenarioPanel extends StatelessWidget {
  const MockScenarioPanel({
    super.key,
    required this.activeMode,
    required this.onRequestSnapshot,
    required this.onSelectMode,
  });

  /// Escenario actualmente activo (resaltado en la UI).
  final String? activeMode;

  /// Callback para solicitar un snapshot puntual.
  final VoidCallback onRequestSnapshot;

  /// Callback invocado al seleccionar un escenario.
  final ValueChanged<String> onSelectMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 430;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.science_rounded,
                          color: AppColors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.text('mock_scenarios'),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: onRequestSnapshot,
                      icon: const Icon(Icons.camera_rounded),
                      label: Text(context.l10n.text('snapshot')),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    const Icon(
                      Icons.science_rounded,
                      color: AppColors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.text('mock_scenarios'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: onRequestSnapshot,
                      icon: const Icon(Icons.camera_rounded),
                      label: Text(context.l10n.text('snapshot')),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mode in mockScenarioModes)
                    ChoiceChip(
                      label: Text(context.l10n.text(mockModeKey(mode))),
                      selected: activeMode == mode,
                      onSelected: (_) => onSelectMode(mode),
                      selectedColor: AppColors.cyan.withAlpha(38),
                      side: const BorderSide(color: AppColors.border),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: activeMode == mode
                            ? AppColors.blue
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
