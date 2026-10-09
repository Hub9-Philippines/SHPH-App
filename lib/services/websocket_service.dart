import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '/api/api_config.dart';
import '/api/shph_token_storage.dart';
import '/services/logging_service.dart';

/// Realtime websocket client for the SHPH backend — port of the web app's
/// `websocketService.ts` (direct-call subset).
///
/// Contract parity with the web client:
/// - URL: `wss://<api-host>/ws/` (scheme/host derived from `ApiConfig.baseUrl`).
/// - Auth: JWT sent via the `shph-auth` subprotocol, not the URL.
/// - Heartbeat: `{"type":"ping"}` every 30s; forces reconnect after 45s of
///   inbound silence.
/// - Reconnect: exponential backoff (1s × 2^n, capped at 30s), 5 attempts,
///   counter reset only after a connection that stayed up ≥15s.
/// - Messages: JSON with a `type` field; handlers registered per type. A
///   `call_signal` message is dispatched with its `data` unwrapped so
///   subscribers receive the signaling payload directly.
class ShphWebSocketService {
  ShphWebSocketService._();

  static final ShphWebSocketService instance = ShphWebSocketService._();

  static const int _maxReconnectAttempts = 5;
  static const Duration _baseReconnectDelay = Duration(seconds: 1);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);
  static const Duration _stableConnection = Duration(seconds: 15);
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _pongTimeout = Duration(seconds: 45);

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _isConnecting = false;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;
  DateTime? _connectTime;
  DateTime _lastInbound = DateTime.now();
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  final List<Map<String, dynamic>> _messageQueue = [];

  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  /// Emits `true` when connected and `false` when disconnected.
  Stream<bool> get connectionState => _connectionStateController.stream;

  bool get isConnected => _channel != null && !_isConnecting;

  /// Injectable token reader (tests override this; defaults to
  /// [ShphTokenStorage]).
  Future<String?> Function() tokenReader = ShphTokenStorage.getAccessToken;

  /// Handlers keyed by message `type`; a type can hold multiple subscribers.
  final Map<String, List<void Function(Map<String, dynamic>)>> _handlers = {};

  /// Registers a handler for messages with the given `type`.
  void addHandler(
    String type,
    void Function(Map<String, dynamic> data) handler,
  ) {
    _handlers.putIfAbsent(type, () => []).add(handler);
  }

  /// Removes a previously registered handler (identity match).
  void removeHandler(
    String type,
    void Function(Map<String, dynamic> data) handler,
  ) {
    _handlers[type]?.remove(handler);
    if (_handlers[type]?.isEmpty ?? false) {
      _handlers.remove(type);
    }
  }

  /// Derives the websocket URL from the REST base URL:
  /// `https://serbisyohubph.com` → `wss://serbisyohubph.com/ws/`.
  static String deriveWsUrl(String baseUrl) {
    final trimmed = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final String scheme;
    if (trimmed.startsWith('https://')) {
      scheme = 'wss://';
    } else if (trimmed.startsWith('http://')) {
      scheme = 'ws://';
    } else {
      scheme = 'wss://';
    }
    final hostPort = trimmed
        .replaceFirst('https://', '')
        .replaceFirst('http://', '')
        .replaceFirst('wss://', '')
        .replaceFirst('ws://', '');
    return '$scheme$hostPort/ws/';
  }

  /// Connects if not already connected. Safe to call repeatedly.
  Future<void> connect() async {
    if (isConnected || _isConnecting) {
      return;
    }
    _isConnecting = true;
    try {
      final token = await tokenReader();
      if (token == null || token.isEmpty) {
        LoggingService.info(
          'WebSocket connect skipped — no auth token',
          tag: 'WebSocket',
        );
        _isConnecting = false;
        return;
      }

      final uri = Uri.parse(deriveWsUrl(ApiConfig.baseUrl));
      // The JWT rides in the subprotocol header so it never appears in
      // URLs or logs (web parity: ["shph-auth", token]).
      final channel = WebSocketChannel.connect(
        uri,
        protocols: ['shph-auth', token],
      );

      // Handshake watchdog: a blackholed proxy can hold the socket in
      // CONNECTING with neither open nor close firing until the OS-level TCP
      // timeout. Closing it runs the normal close path and bounded reconnect.
      var handshakeSettled = false;
      unawaited(channel.ready.then((_) {
        handshakeSettled = true;
      }).catchError((Object e) {
        handshakeSettled = true;
      }));
      Timer(const Duration(milliseconds: _connectTimeoutMs), () async {
        if (!handshakeSettled) {
          LoggingService.warning(
            'WebSocket handshake watchdog fired; aborting stalled socket',
            tag: 'WebSocket',
          );
          try {
            await channel.sink.close();
          } catch (_) {}
        }
      });

      await channel.ready;

      _channel = channel;
      _connectTime = DateTime.now();
      _lastInbound = DateTime.now();
      _isConnecting = false;
      _connectionStateController.add(true);
      LoggingService.info(
        'WebSocket connected: ${uri.host}',
        tag: 'WebSocket',
      );

      _subscription = channel.stream.listen(
        _onData,
        onDone: _onDone,
        onError: (Object e) => _onError(e),
      );

      _startHeartbeat();
      _flushQueue();
    } catch (e) {
      _isConnecting = false;
      LoggingService.warning(
        'WebSocket connect failed: $e',
        tag: 'WebSocket',
      );
      _scheduleReconnect();
    }
  }

  /// Disconnects without scheduling reconnects.
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopHeartbeat();
    _messageQueue.clear();
    final sub = _subscription;
    _subscription = null;
    await sub?.cancel();
    final channel = _channel;
    _channel = null;
    try {
      await channel?.sink.close();
    } catch (_) {}
    if (_connectTime != null) {
      _connectTime = null;
      _connectionStateController.add(false);
    }
  }

  /// Sends a JSON message; queues it when offline. Returns false when the
  /// message could not be sent now (it stays queued for later delivery).
  Future<bool> send(Map<String, dynamic> message) async {
    final channel = _channel;
    if (channel == null) {
      _messageQueue.add(message);
      return false;
    }
    try {
      channel.sink.add(jsonEncode(message));
      return true;
    } catch (e) {
      LoggingService.warning(
        'WebSocket send failed: $e',
        tag: 'WebSocket',
      );
      _messageQueue.add(message);
      return false;
    }
  }

  void _onData(dynamic raw) {
    _lastInbound = DateTime.now();
    final Map<String, dynamic> message;
    try {
      final decoded = jsonDecode(raw.toString());
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      message = decoded;
    } catch (e) {
      LoggingService.warning(
        'WebSocket message parse error: $e',
        tag: 'WebSocket',
      );
      return;
    }

    final type = message['type']?.toString();
    if (type == null) {
      return;
    }

    if (type == 'call_signal') {
      // Dispatch with the envelope unwrapped so call_signal subscribers get
      // the signaling payload directly (web parity).
      final data = message['data'];
      if (data is Map) {
        _dispatch(type, Map<String, dynamic>.from(data));
      } else {
        LoggingService.warning(
          'call_signal received with invalid payload',
          tag: 'WebSocket',
        );
      }
      return;
    }

    _dispatch(type, message);
  }

  void _dispatch(String type, Map<String, dynamic> data) {
    final handlers = _handlers[type];
    if (handlers == null || handlers.isEmpty) {
      return;
    }
    for (final handler in List.of(handlers)) {
      try {
        handler(data);
      } catch (e) {
        LoggingService.error(
          'WebSocket handler for "$type" threw: $e',
          tag: 'WebSocket',
          error: e,
        );
      }
    }
  }

  void _onDone() {
    final hadConnection = _connectTime != null;
    _teardownSocket();
    if (_manualDisconnect) {
      _manualDisconnect = false;
      return;
    }
    if (hadConnection) {
      _connectionStateController.add(false);
      LoggingService.info('WebSocket closed', tag: 'WebSocket');
    }
    _scheduleReconnect();
  }

  void _onError(Object error) {
    LoggingService.warning(
      'WebSocket error: $error',
      tag: 'WebSocket',
    );
    final hadConnection = _connectTime != null;
    _teardownSocket();
    if (hadConnection) {
      _connectionStateController.add(false);
    }
    // onDone follows onError for sockets; reconnect is scheduled there.
  }

  void _teardownSocket() {
    _stopHeartbeat();
    _subscription = null;
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) {
      return;
    }
    if (_reconnectTimer != null || _isConnecting || isConnected) {
      return;
    }
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      LoggingService.error(
        'WebSocket max reconnect attempts reached',
        tag: 'WebSocket',
      );
      return;
    }

    // Reset the backoff counter only after a connection that stayed up a
    // while; sockets that never opened keep incrementing toward the cap.
    final connectTime = _connectTime;
    if (connectTime != null &&
        DateTime.now().difference(connectTime) >= _stableConnection) {
      _reconnectAttempts = 0;
    }
    _reconnectAttempts++;

    final delayMs = (_baseReconnectDelay.inMilliseconds *
            (1 << (_reconnectAttempts - 1)))
        .clamp(0, _maxReconnectDelay.inMilliseconds);
    LoggingService.info(
      'WebSocket reconnecting in ${delayMs}ms '
      '(attempt $_reconnectAttempts/$_maxReconnectAttempts)',
      tag: 'WebSocket',
    );

    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      _reconnectTimer = null;
      if (isConnected || _isConnecting) {
        return;
      }
      unawaited(connect());
    });
  }

  /// Called when the app returns to the foreground: verifies the socket is
  /// actually usable and reconnects immediately when it is gone or stale, so
  /// incoming call signals are not missed after backgrounding.
  ///
  /// - No channel → connect now.
  /// - Channel present but inbound silence exceeded a full heartbeat interval
  ///   → the socket is effectively dead; force-close so the existing bounded
  ///   reconnect takes over (the heartbeat would catch this within 15s
  ///   anyway — this only accelerates it).
  /// - Healthy socket → no-op; when [pingFirst] is set (a call is active),
  ///   send an immediate ping to confirm liveness without a reconnect.
  Future<void> ensureAlive({bool pingFirst = false}) async {
    final channel = _channel;
    if (channel == null) {
      if (!_isConnecting && !_manualDisconnect) {
        LoggingService.info(
          'ensureAlive: no socket on resume — connecting',
          tag: 'WebSocket',
        );
        await connect();
      }
      return;
    }
    final silence = DateTime.now().difference(_lastInbound);
    if (silence > _heartbeatInterval) {
      LoggingService.warning(
        'ensureAlive: socket stale (${silence.inSeconds}s silence) — forcing reconnect',
        tag: 'WebSocket',
      );
      _teardownSocket();
      _connectionStateController.add(false);
      _scheduleReconnect();
      return;
    }
    if (pingFirst) {
      unawaited(send(const {'type': 'ping'}));
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (!isConnected) {
        return;
      }
      final silence = DateTime.now().difference(_lastInbound);
      if (silence > _pongTimeout) {
        LoggingService.warning(
          'WebSocket silent for ${silence.inSeconds}s; forcing reconnect',
          tag: 'WebSocket',
        );
        _teardownSocket();
        _connectionStateController.add(false);
        _scheduleReconnect();
        return;
      }
      // Lightweight ping keeps NAT/firewall mappings alive; any inbound
      // traffic (pong or otherwise) refreshes _lastInbound.
      unawaited(send(const {'type': 'ping'}));
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _flushQueue() {
    final queued = List<Map<String, dynamic>>.from(_messageQueue);
    _messageQueue.clear();
    for (final message in queued) {
      unawaited(send(message));
    }
  }
}

const int _connectTimeoutMs = 15000;
