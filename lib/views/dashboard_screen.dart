import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/viewmodels/dashboard_controller.dart';
import 'package:derma_sense/views/widgets/clinical_layout.dart';
import 'package:derma_sense/views/widgets/dashboard_header.dart';
import 'package:derma_sense/views/widgets/posture_mode_panel.dart';

/// Pantalla principal de Derma Sense (capa View).
///
/// Es deliberadamente "delgada": toda la lógica vive en [DashboardController].
/// La pantalla solo:
/// 1. Crea y destruye el controlador y el `TextEditingController` de la URL.
/// 2. Precarga las ilustraciones de recomendación.
/// 3. Escucha al controlador ([ListenableBuilder]) y al flujo de lecturas
///    ([StreamBuilder]) para dibujar el estado.
class PressureMatDashboard extends StatefulWidget {
  const PressureMatDashboard({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<PressureMatDashboard> createState() => _PressureMatDashboardState();
}

class _PressureMatDashboardState extends State<PressureMatDashboard> {
  late final DashboardController _controller;
  late final TextEditingController _socketUrlController;
  bool _didPrecacheAssets = false;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(locale: widget.locale);
    _socketUrlController = TextEditingController(text: _controller.socketUrl);
    if (kIsWeb) {
      _controller.toggleSimulation();
    } else {
      _controller.connect();
    }
  }

  @override
  void didUpdateWidget(covariant PressureMatDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      _controller.setLocale(widget.locale);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheAssets) {
      return;
    }
    _didPrecacheAssets = true;
    for (final asset in const [
      safeAsset,
      pressureAlertAsset,
      turnLeftAsset,
      turnRightAsset,
      skinCheckAsset,
    ]) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _socketUrlController.dispose();
    super.dispose();
  }

  /// Aplica la URL escrita en el campo y, solo si realmente cambió y era
  /// válida, normaliza el texto mostrado en el campo.
  void _handleApplySocketUrl() {
    final result = _controller.applySocketUrl(_socketUrlController.text);
    if (result == ApplyUrlResult.applied) {
      final url = _controller.socketUrl;
      _socketUrlController.value = TextEditingValue(
        text: url,
        selection: TextSelection.collapsed(offset: url.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 720;
            final horizontalPadding = isMobile ? 16.0 : 28.0;
            final maxContentWidth = constraints.maxWidth > 1360
                ? 1280.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DashboardHeader(
                            status: _controller.connectionStatus,
                            isSimulating: _controller.isSimulating,
                            isRemoteMock: _controller.isRemoteMock,
                            lastError: _controller.lastError,
                            socketUrl: _controller.socketUrl,
                            socketUrlController: _socketUrlController,
                            activeMockMode: _controller.remoteMockMode,
                            locale: widget.locale,
                            isWebDemo: kIsWeb,
                            onLocaleChanged: widget.onLocaleChanged,
                            onReconnect: _controller.connect,
                            onApplySocketUrl: _handleApplySocketUrl,
                            onRequestSnapshot: _controller.requestSnapshot,
                            onSelectMockMode: _controller.setMockScenario,
                            onToggleSimulation: _controller.toggleSimulation,
                          ),
                          const SizedBox(height: 20),
                          PostureModePanel(
                            postureMode: _controller.postureMode,
                            onChanged: _controller.setPostureMode,
                          ),
                          const SizedBox(height: 20),
                          StreamBuilder<MatReading>(
                            stream: _controller.readings,
                            initialData: MatReading.empty(),
                            builder: (context, snapshot) {
                              final reading =
                                  snapshot.data ?? MatReading.empty();
                              return LiveDashboardContent(
                                reading: reading,
                                hasProlongedPressure:
                                    _controller.hasProlongedPressure,
                                highPressureStreak:
                                    _controller.highPressureStreak,
                                postureMode: _controller.postureMode,
                                historySummary: _controller.historySummary,
                                historyWindow: _controller.historyWindow,
                                onHistoryWindowChanged:
                                    _controller.setHistoryWindow,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
