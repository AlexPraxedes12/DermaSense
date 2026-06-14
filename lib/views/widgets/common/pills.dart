import 'package:flutter/material.dart';

import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/core/utils/visual_mappers.dart';
import 'package:derma_sense/models/enums.dart';

/// Píldora compacta con ícono y etiqueta de color.
///
/// Es el bloque básico de los indicadores del encabezado y de las secciones
/// ([ConnectionChip], [SourceBadge], [RiskBadge] se construyen sobre ella).
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  /// Ícono mostrado a la izquierda.
  final IconData icon;

  /// Texto de la píldora.
  final String label;

  /// Color del ícono y del texto.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Píldora que refleja el [Esp32ConnectionStatus] actual con color e ícono.
class ConnectionChip extends StatelessWidget {
  const ConnectionChip({super.key, required this.status});

  /// Estado de conexión a representar.
  final Esp32ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      Esp32ConnectionStatus.connecting => (
        'Conectando',
        AppColors.orange,
        Icons.sync_rounded,
      ),
      Esp32ConnectionStatus.connected => (
        'Conectado',
        AppColors.green,
        Icons.sensors_rounded,
      ),
      Esp32ConnectionStatus.disconnected => (
        'Desconectado',
        AppColors.textSecondary,
        Icons.wifi_off_rounded,
      ),
      Esp32ConnectionStatus.error => (
        'Error',
        AppColors.red,
        Icons.error_outline_rounded,
      ),
    };

    return InfoPill(icon: icon, label: label, color: color);
  }
}

/// Insignia que indica si los datos provienen del ESP32 real o del simulador.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.isSimulated});

  /// `true` si la fuente es simulada.
  final bool isSimulated;

  @override
  Widget build(BuildContext context) {
    return InfoPill(
      icon: isSimulated ? Icons.auto_awesome_rounded : Icons.memory_rounded,
      label: isSimulated ? 'SIM' : 'ESP32',
      color: isSimulated ? AppColors.orange : AppColors.green,
    );
  }
}

/// Insignia que muestra el nivel de riesgo como semáforo de color.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.level});

  /// Nivel de riesgo a representar.
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final color = riskColor(level);
    return InfoPill(
      icon: Icons.circle,
      label: 'Riesgo ${riskLabel(level)}',
      color: color,
    );
  }
}
