import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:derma_sense/core/constants/app_config.dart';
import 'package:derma_sense/models/enums.dart';
import 'package:derma_sense/models/mat_reading.dart';
import 'package:derma_sense/models/sensor_history.dart';
import 'package:derma_sense/services/sensor_history_service.dart';

/// Resultado de intentar aplicar una nueva URL de WebSocket.
///
/// Permite a la vista decidir si debe reescribir el campo de texto (solo
/// cuando la URL realmente cambió y fue válida).
enum ApplyUrlResult {
  /// La URL era válida y distinta a la anterior: se aplicó y se reconecta.
  applied,

  /// La URL era válida pero igual a la actual: solo se reconecta.
  reconnected,

  /// La URL era inválida: no se aplica nada (se muestra un error).
  invalid,
}

/// ViewModel del dashboard: orquesta la conexión con el ESP32, la simulación
/// de datos y todo el estado observable de la pantalla.
///
/// Es la capa que separa la *lógica* de la *presentación*. La vista
/// (`PressureMatDashboard`) no sabe nada de WebSockets ni de timers: solo
/// escucha a este [ChangeNotifier] y dibuja su estado.
///
/// Responsabilidades:
/// - Conectarse al WebSocket del ESP32 y manejar errores/timeouts/reconexión.
/// - Parsear los mensajes entrantes a [MatReading] y publicarlos por [readings]
///   con *throttling* para no saturar la UI.
/// - Generar lecturas simuladas cuando el usuario activa "Simular Datos".
/// - Enviar comandos al firmware (snapshot, escenarios mock).
/// - Exponer el estado de conexión, errores, modo postura y la racha de presión
///   alta a la vista mediante `notifyListeners()`.
class DashboardController extends ChangeNotifier {
  final StreamController<MatReading> _readingsController =
      StreamController<MatReading>.broadcast();
  final Random _random = Random();
  final SensorHistoryService _historyService = SensorHistoryService();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _simulationTimer;
  Timer? _uiThrottleTimer;
  Timer? _connectTimeoutTimer;
  MatReading? _queuedReading;
  DateTime? _lastUiEmitAt;
  DateTime? _lastSocketParseErrorAt;
  Esp32ConnectionStatus _connectionStatus = Esp32ConnectionStatus.connecting;
  String? _lastError;
  bool _isSimulating = false;
  int _highPressureStreak = 0;
  int _connectionGeneration = 0;
  String _socketUrl = initialEsp32WebSocketUrl;
  bool _isRemoteMock = false;
  String? _remoteMockMode;
  PatientPostureMode _postureMode = PatientPostureMode.supine;
  HistoryWindow _historyWindow = HistoryWindow.fiveMinutes;
  bool _isDisposed = false;

  /// Flujo de lecturas listas para la UI (ya filtradas y *throttled*).
  Stream<MatReading> get readings => _readingsController.stream;

  /// Estado actual de la conexión con el ESP32.
  Esp32ConnectionStatus get connectionStatus => _connectionStatus;

  /// Último mensaje de error a mostrar (o `null` si no hay).
  String? get lastError => _lastError;

  /// `true` si actualmente se están generando datos simulados.
  bool get isSimulating => _isSimulating;

  /// Racha de lecturas consecutivas con puntos de presión alta.
  int get highPressureStreak => _highPressureStreak;

  /// URL del WebSocket en uso.
  String get socketUrl => _socketUrl;

  /// `true` si el origen remoto declara estar en modo mock.
  bool get isRemoteMock => _isRemoteMock;

  /// Escenario mock activo reportado por el origen remoto (o `null`).
  String? get remoteMockMode => _remoteMockMode;

  /// Modo de interpretación según la postura del paciente.
  PatientPostureMode get postureMode => _postureMode;

  /// Ventana activa del panel de historial.
  HistoryWindow get historyWindow => _historyWindow;

  /// Resumen preventivo de presión y de los seis NTC en la ventana activa.
  SensorHistorySummary get historySummary =>
      _historyService.summarize(_historyWindow);

  /// `true` cuando la presión alta se ha mantenido suficientes frames como para
  /// disparar la alerta de presión prolongada.
  bool get hasProlongedPressure =>
      _highPressureStreak >= prolongedPressureFrames;

  // -------------------------------------------------------------------------
  // Conexión
  // -------------------------------------------------------------------------

  /// Inicia (o reinicia) la conexión con el ESP32 usando [socketUrl].
  ///
  /// Cancela cualquier simulación o conexión previa, arranca un timeout de
  /// seguridad y se suscribe al flujo de mensajes. Usa un contador de
  /// "generación" para ignorar callbacks de conexiones ya descartadas.
  void connect() {
    final generation = ++_connectionGeneration;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _cancelSocketResources();

    _isSimulating = false;
    _connectionStatus = Esp32ConnectionStatus.connecting;
    _lastError = null;
    _safeNotify();

    try {
      final channel = WebSocketChannel.connect(Uri.parse(_socketUrl));
      _channel = channel;
      _connectTimeoutTimer = Timer(websocketConnectTimeout, () {
        if (_isDisposed || generation != _connectionGeneration) {
          return;
        }
        _connectionGeneration++;
        _cancelSocketResources();
        _connectionStatus = Esp32ConnectionStatus.error;
        _lastError =
            'ESP32 sin respuesta. Use simulacion o pulse Reconectar cuando este disponible.';
        _safeNotify();
      });

      unawaited(
        channel.ready
            .then((_) {
              if (_isDisposed || generation != _connectionGeneration) {
                return;
              }
              _connectTimeoutTimer?.cancel();
              _connectTimeoutTimer = null;
              if (_connectionStatus != Esp32ConnectionStatus.connected ||
                  _lastError != null) {
                _connectionStatus = Esp32ConnectionStatus.connected;
                _lastError = null;
                _safeNotify();
              }
            })
            .catchError((Object error, StackTrace stackTrace) {
              _handleSocketFailure(error, generation);
            }),
      );

      _socketSubscription = channel.stream.listen(
        _handleSocketMessage,
        onError: (Object error) {
          _handleSocketFailure(error, generation);
        },
        onDone: () {
          if (_isDisposed || generation != _connectionGeneration) {
            return;
          }
          _connectTimeoutTimer?.cancel();
          _connectTimeoutTimer = null;
          _connectionStatus = Esp32ConnectionStatus.disconnected;
          _safeNotify();
        },
        cancelOnError: false,
      );
    } catch (error) {
      _connectionStatus = Esp32ConnectionStatus.error;
      _lastError = _friendlySocketError(error);
      _safeNotify();
    }
  }

  /// Valida y aplica una nueva URL de WebSocket introducida por el usuario.
  ///
  /// Normaliza el valor (añade `ws://` si falta), valida el esquema y el host, y
  /// devuelve un [ApplyUrlResult] para que la vista sepa cómo actualizar su
  /// campo de texto.
  ApplyUrlResult applySocketUrl(String rawInput) {
    final rawValue = rawInput.trim();
    final normalizedUrl = rawValue.isEmpty
        ? defaultEsp32WebSocketUrl
        : rawValue.startsWith('ws://') || rawValue.startsWith('wss://')
        ? rawValue
        : 'ws://$rawValue';

    Uri? parsedUri;
    try {
      parsedUri = Uri.parse(normalizedUrl);
    } catch (_) {
      parsedUri = null;
    }

    if (parsedUri == null ||
        !parsedUri.hasScheme ||
        parsedUri.host.isEmpty ||
        (parsedUri.scheme != 'ws' && parsedUri.scheme != 'wss')) {
      _lastError =
          'URL invalida. Use algo como ws://192.168.4.1:81 o ws://127.0.0.1:81';
      _safeNotify();
      return ApplyUrlResult.invalid;
    }

    if (normalizedUrl == _socketUrl) {
      connect();
      return ApplyUrlResult.reconnected;
    }

    _socketUrl = normalizedUrl;
    _lastError = null;
    _safeNotify();
    connect();
    return ApplyUrlResult.applied;
  }

  void _cancelSocketResources() {
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
    _socketSubscription?.cancel();
    _socketSubscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _handleSocketFailure(Object error, int generation) {
    if (_isDisposed || generation != _connectionGeneration) {
      return;
    }

    _connectionGeneration++;
    _cancelSocketResources();
    _connectionStatus = Esp32ConnectionStatus.error;
    _lastError = _friendlySocketError(error);
    _safeNotify();
  }

  String _friendlySocketError(Object error) {
    final text = error.toString();
    final lowerText = text.toLowerCase();
    if (text.contains('errno = 121') ||
        lowerText.contains('semaforo') ||
        lowerText.contains('semaphore') ||
        lowerText.contains('timed out')) {
      return 'No se pudo conectar al ESP32. Verifique Wi-Fi/IP o use Simular Datos.';
    }
    return 'Conexion ESP32 no disponible: $text';
  }

  // -------------------------------------------------------------------------
  // Recepción y parseo de mensajes
  // -------------------------------------------------------------------------

  void _handleSocketMessage(dynamic event) {
    try {
      final payload = event is List<int>
          ? utf8.decode(event)
          : event.toString();
      final trimmedPayload = payload.trim();
      if (trimmedPayload.isEmpty) {
        return;
      }

      final decoded = jsonDecode(trimmedPayload);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('El JSON debe ser un objeto.');
      }

      _handleSocketPayload(decoded);

      if (_isDisposed) {
        return;
      }
      if (_connectionStatus != Esp32ConnectionStatus.connected ||
          _lastError != null) {
        _connectionStatus = Esp32ConnectionStatus.connected;
        _lastError = null;
        _safeNotify();
      }
    } catch (error) {
      if (_isDisposed || !_shouldShowSocketParseError()) {
        return;
      }
      _lastError = 'Dato descartado: $error';
      _safeNotify();
    }
  }

  void _handleSocketPayload(Map<String, dynamic> payload) {
    _syncRemoteSourceMetadata(payload);

    if (_isTelemetryPayload(payload)) {
      _publishReading(MatReading.fromJson(payload));
    }
  }

  bool _isTelemetryPayload(Map<String, dynamic> payload) {
    return payload['p'] is List && payload['t'] is List;
  }

  void _syncRemoteSourceMetadata(Map<String, dynamic> payload) {
    final status = payload['status'];
    final isMockStatus = status is Map<String, dynamic>
        ? status['mock'] == true
        : false;
    final mockMode = status is Map<String, dynamic>
        ? status['mode']?.toString()
        : payload['mode']?.toString();

    if (_isDisposed) {
      return;
    }

    if (_isRemoteMock != isMockStatus || _remoteMockMode != mockMode) {
      _isRemoteMock = isMockStatus;
      _remoteMockMode = mockMode;
      _safeNotify();
    }
  }

  // -------------------------------------------------------------------------
  // Comandos hacia el firmware
  // -------------------------------------------------------------------------

  void _sendSocketCommand(String command) {
    if (_channel == null || _isSimulating) {
      _lastError = 'No hay un WebSocket activo para enviar comandos.';
      _safeNotify();
      return;
    }

    try {
      _channel!.sink.add(command);
      if (_lastError != null) {
        _lastError = null;
        _safeNotify();
      }
    } catch (error) {
      _lastError = 'No se pudo enviar comando: $error';
      _safeNotify();
    }
  }

  /// Solicita al firmware una captura puntual ("snapshot").
  void requestSnapshot() {
    _sendSocketCommand('snapshot');
  }

  /// Pide al firmware activar el escenario mock [mode].
  void setMockScenario(String mode) {
    _sendSocketCommand('mode:$mode');
  }

  bool _shouldShowSocketParseError() {
    final now = DateTime.now();
    final lastErrorAt = _lastSocketParseErrorAt;
    if (lastErrorAt != null &&
        now.difference(lastErrorAt) < socketParseErrorInterval) {
      return false;
    }
    _lastSocketParseErrorAt = now;
    return true;
  }

  // -------------------------------------------------------------------------
  // Publicación de lecturas (con throttling)
  // -------------------------------------------------------------------------

  void _publishReading(MatReading reading) {
    if (reading.highPressurePointCount > 0) {
      _highPressureStreak = min(_highPressureStreak + 1, 999);
    } else {
      _highPressureStreak = 0;
    }

    _queuedReading = reading;
    final now = DateTime.now();
    final lastEmitAt = _lastUiEmitAt;
    if (lastEmitAt == null || now.difference(lastEmitAt) >= uiUpdateInterval) {
      _flushQueuedReading();
      return;
    }

    _uiThrottleTimer ??= Timer(
      uiUpdateInterval - now.difference(lastEmitAt),
      _flushQueuedReading,
    );
  }

  void _flushQueuedReading() {
    _uiThrottleTimer?.cancel();
    _uiThrottleTimer = null;

    final reading = _queuedReading;
    if (reading == null || _readingsController.isClosed) {
      return;
    }

    _queuedReading = null;
    _lastUiEmitAt = DateTime.now();
    _historyService.record(reading, _postureMode);
    _readingsController.add(reading);
  }

  // -------------------------------------------------------------------------
  // Simulación y modo postura
  // -------------------------------------------------------------------------

  /// Activa o desactiva la generación de datos simulados.
  ///
  /// Al activarla corta la conexión WebSocket y emite lecturas cada 650 ms; al
  /// desactivarla solo detiene el timer (la reconexión es manual).
  void toggleSimulation() {
    if (_isSimulating) {
      _simulationTimer?.cancel();
      _isSimulating = false;
      _safeNotify();
      return;
    }

    _connectionGeneration++;
    _cancelSocketResources();
    _isSimulating = true;
    _connectionStatus = Esp32ConnectionStatus.disconnected;
    _lastError = null;
    _safeNotify();

    _publishReading(MatReading.simulated(_random));
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      _publishReading(MatReading.simulated(_random));
    });
  }

  /// Cambia el modo de interpretación (sentado / acostado).
  void setPostureMode(PatientPostureMode mode) {
    if (_postureMode == mode) {
      return;
    }
    _postureMode = mode;
    _safeNotify();
  }

  /// Cambia la ventana de análisis sin alterar ni descartar el historial.
  void setHistoryWindow(HistoryWindow window) {
    if (_historyWindow == window) {
      return;
    }
    _historyWindow = window;
    _safeNotify();
  }

  /// Notifica a los oyentes solo si el controlador sigue vivo.
  void _safeNotify() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectionGeneration++;
    _simulationTimer?.cancel();
    _uiThrottleTimer?.cancel();
    _connectTimeoutTimer?.cancel();
    _cancelSocketResources();
    _readingsController.close();
    super.dispose();
  }
}
