import 'package:flutter/material.dart';

import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/models/enums.dart';

/// Panel que permite elegir el modo de interpretación según la postura del
/// paciente (sentado o acostado).
///
/// La elección no cambia los datos físicos, solo cómo se traducen las zonas y
/// los textos de las recomendaciones.
class PostureModePanel extends StatelessWidget {
  const PostureModePanel({
    super.key,
    required this.postureMode,
    required this.onChanged,
  });

  /// Modo actualmente seleccionado.
  final PatientPostureMode postureMode;

  /// Callback invocado al elegir un modo distinto.
  final ValueChanged<PatientPostureMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo de interpretacion',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'La misma distribucion fisica de NTC y presion cambia de significado si la persona esta sentada o acostada.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _PostureModeToggle(postureMode: postureMode, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Conmutador de dos opciones (sentado / acostado) que se apila en vertical
/// cuando el ancho es reducido. Privado: solo lo usa [PostureModePanel].
class _PostureModeToggle extends StatelessWidget {
  const _PostureModeToggle({required this.postureMode, required this.onChanged});

  final PatientPostureMode postureMode;
  final ValueChanged<PatientPostureMode> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget buildOption(PatientPostureMode mode, IconData icon, String label) {
      return _PostureModeOption(
        icon: icon,
        label: label,
        selected: postureMode == mode,
        onTap: () => onChanged(mode),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: compact
              ? Column(
                  children: [
                    buildOption(
                      PatientPostureMode.seated,
                      Icons.event_seat_rounded,
                      'Sentado',
                    ),
                    const SizedBox(height: 6),
                    buildOption(
                      PatientPostureMode.supine,
                      Icons.airline_seat_flat_rounded,
                      'Acostado',
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: buildOption(
                        PatientPostureMode.seated,
                        Icons.event_seat_rounded,
                        'Sentado',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: buildOption(
                        PatientPostureMode.supine,
                        Icons.airline_seat_flat_rounded,
                        'Acostado',
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// Una opción individual del conmutador de postura, con estado seleccionado
/// animado. Privada: solo la usa [_PostureModeToggle].
class _PostureModeOption extends StatelessWidget {
  const _PostureModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.blue.withValues(alpha: 0.10)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.blue : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.blue : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? AppColors.blue : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_rounded, size: 18, color: AppColors.blue),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
