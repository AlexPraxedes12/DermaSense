import 'package:flutter/material.dart';

import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/views/widgets/common/pills.dart';
import 'package:derma_sense/views/widgets/mock_scenario_panel.dart';

/// Encabezado del dashboard: título, estado de conexión, campo de URL del
/// WebSocket, panel mock (si aplica), mensajes de error y botones de acción
/// (Aplicar URL, Reconectar, Simular Datos).
///
/// Es un widget "tonto": no contiene lógica, solo recibe el estado y los
/// callbacks desde la vista, que a su vez los delega al `DashboardController`.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.status,
    required this.isSimulating,
    required this.isRemoteMock,
    required this.lastError,
    required this.socketUrl,
    required this.socketUrlController,
    required this.activeMockMode,
    required this.onReconnect,
    required this.onApplySocketUrl,
    required this.onRequestSnapshot,
    required this.onSelectMockMode,
    required this.onToggleSimulation,
  });

  /// Estado actual de la conexión.
  final Esp32ConnectionStatus status;

  /// `true` si la simulación está activa.
  final bool isSimulating;

  /// `true` si el origen remoto está en modo mock.
  final bool isRemoteMock;

  /// Último error a mostrar (o `null`).
  final String? lastError;

  /// URL del WebSocket en uso (para la píldora informativa).
  final String socketUrl;

  /// Controlador del campo de texto de la URL.
  final TextEditingController socketUrlController;

  /// Escenario mock activo (o `null`).
  final String? activeMockMode;

  /// Acción para reconectar.
  final VoidCallback onReconnect;

  /// Acción para aplicar la URL escrita.
  final VoidCallback onApplySocketUrl;

  /// Acción para pedir un snapshot.
  final VoidCallback onRequestSnapshot;

  /// Acción para seleccionar un escenario mock.
  final ValueChanged<String> onSelectMockMode;

  /// Acción para alternar la simulación.
  final VoidCallback onToggleSimulation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Derma Sense',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  ConnectionChip(status: status),
                  InfoPill(
                    icon: Icons.lan_rounded,
                    label: socketUrl,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: TextField(
                  controller: socketUrlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onApplySocketUrl(),
                  decoration: InputDecoration(
                    labelText: 'WebSocket URL',
                    hintText: 'ws://192.168.4.1:81 o ws://127.0.0.1:81',
                    prefixIcon: const Icon(Icons.settings_ethernet_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              if (isRemoteMock) ...[
                const SizedBox(height: 12),
                MockScenarioPanel(
                  activeMode: activeMockMode,
                  onRequestSnapshot: onRequestSnapshot,
                  onSelectMode: onSelectMockMode,
                ),
              ],
              if (lastError != null) ...[
                const SizedBox(height: 10),
                Text(
                  lastError!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: onApplySocketUrl,
              icon: const Icon(Icons.link_rounded),
              label: const Text('Aplicar URL'),
            ),
            OutlinedButton.icon(
              onPressed: onReconnect,
              icon: const Icon(Icons.wifi_tethering_rounded),
              label: const Text('Reconectar'),
            ),
            FilledButton.icon(
              onPressed: onToggleSimulation,
              icon: Icon(
                isSimulating ? Icons.stop_rounded : Icons.auto_awesome_rounded,
              ),
              label: Text(isSimulating ? 'Detener' : 'Simular Datos'),
            ),
          ],
        ),
      ],
    );
  }
}
