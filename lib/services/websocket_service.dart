import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '/api/api_config.dart';
import '/api/shph_token_storage.dart';
import '/services/logging_service.dart';

/// Real-time WebSocket client for the SHPH chat backend (Django Channels).
///
/// Mirrors the reconnect/heartbeat behaviour of the Vue `websocketService.ts`:
/// - JWT token is sent via the `Sec-WebSocket-Protocol` subprotocol
///   (`["shph-auth", <token>]`) instead of the URL path, so tokens do not leak
///   to reverse-proxy / CDN access logs or browser history.
/// - Exponential backoff reconnect with a max-attempt budget.
/// - Reconnect budget resets on explicit [connect()] so a fresh login can retry.
/// - 1006 / handshake rejection before open is treated as fatal (no retry loop).
/// - Connection is considered stable once the server sends `{"type":"connected"}`.
class ShphWebSocketService {
  ShphWebSocketService._();

  static final ShphWebSocketService instance = ShphWebSocketService._();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final _connectionStateController =
      StreamController<ShphConnectionState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  ShphConnectionState _state = ShphConnectionState.disconnected;
  bool _isConnecting = false;
  bool _manualDisconnect = false;
  DateTime? _connectTime;
  int _reconnectAttempts = 0;
  final _random = Random();

  /// Current connection state stream.
  Stream<ShphConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Stream of all incoming JSON messages from the server.
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Current connection state (synchronous read).
  ShphConnectionState get state => _state;

  bool get isConnected => _state == ShphConnectionState.connected;

  static const int _maxReconnectAttempts = 5;
  static const int _initialReconnectDelayMs = 1000;
  static const int _maxReconnectDelayMs = 30000;
  static const int _heartbeatIntervalMs = 30000;

  void _setState(ShphConnectionState value) {
    if (_state == value) {
      return;
    }
    _state = value;
    _connectionStateController.add(value);
  }

  /// Open the WebSocket connection. Safe to call multiple times.
  ///
  /// If the connection is already open this returns immediately. If there is
  /// no valid JWT token the connection is skipped (non-fatal).
  Future<void> connect() async {
    if (_isConnecting || _state == ShphConnectionState.connected) {
      return;
    }

    if (!ApiConfig.isWebSocketConfigured) {
      LoggingService.warning(
        'WebSocket URL not configured; skipping connect',
        tag: 'WebSocket',
      );
      return;
    }

    final token = await ShphTokenStorage.getAccessToken();
    if (token == null || token.isEmpty || _isTokenExpired(token)) {
      LoggingService.info(
        'Skipping WebSocket connect — no valid auth token',
        tag: 'WebSocket',
      );
      return;
    }

    _manualDisconnect = false;
    _isConnecting = true;
    _setState(ShphConnectionState.connecting);
    // Reset budget on explicit connect so a fresh login can retry fully.
    _reconnectAttempts = 0;

    await _initiateConnection(token);
  }

  /// Build the path-only WebSocket URL. The JWT is sent via
  /// `Sec-WebSocket-Protocol` instead of being embedded here.
  static String connectionUrl(String baseWsUrl) => '$baseWsUrl/chat/';

  Future<void> _initiateConnection(String token) async {
    try {
      final baseWsUrl = ApiConfig.wsUrl;
      final wsUrl = connectionUrl(baseWsUrl);
      LoggingService.info(
        'Connecting to WebSocket',
        tag: 'WebSocket',
      );
      LoggingService.debug('WebSocket URL: $wsUrl', tag: 'WebSocket');

      // Send the JWT via Sec-WebSocket-Protocol instead of the URL path so it
      // does not appear in reverse-proxy / CDN access logs or browser history.
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['shph-auth', token],
      );
      _connectTime = null;

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onClose,
        cancelOnError: false,
      );
    } catch (e) {
      LoggingService.error('WebSocket connection error: $e', tag: 'WebSocket');
      _isConnecting = false;
      _setState(ShphConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      LoggingService.debug('WebSocket message received: $message',
          tag: 'WebSocket');

      final type = message['type'] as String?;
      if (type == 'connected') {
        _connectTime = DateTime.now();
        _isConnecting = false;
        _reconnectAttempts = 0;
        _setState(ShphConnectionState.connected);
        _startHeartbeat();
      }

      _messageController.add(message);
    } catch (e) {
      LoggingService.error('Failed to parse WebSocket message: $e',
          tag: 'WebSocket');
    }
  }

  void _onError(dynamic error) {
    LoggingService.error('WebSocket error: $error', tag: 'WebSocket');
  }

  void _onClose() {
    _subscription?.cancel();
    _subscription = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _isConnecting = false;
    _setState(ShphConnectionState.disconnected);

    if (_manualDisconnect) {
      _manualDisconnect = false;
      return;
    }

    // Connection was rejected before the server ever accepted it. This is
    // usually an invalid/expired token or a server-side auth failure. Do not
    // retry in a loop.
    if (_connectTime == null) {
      LoggingService.info(
        'WebSocket rejected before handshake; not retrying',
        tag: 'WebSocket',
      );
      _reconnectAttempts = _maxReconnectAttempts;
      return;
    }

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) {
      return;
    }
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      LoggingService.error(
        'WebSocket max reconnect attempts reached',
        tag: 'WebSocket',
      );
      return;
    }

    _reconnectAttempts++;
    final delay = _computeReconnectDelay(_reconnectAttempts);

    LoggingService.info(
      'WebSocket reconnecting in ${delay}ms (attempt $_reconnectAttempts/$_maxReconnectAttempts)',
      tag: 'WebSocket',
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      _reconnectTimer = null;
      _tryReconnect();
    });
  }

  int _computeReconnectDelay(int attempt) {
    final exponential = _initialReconnectDelayMs * (1 << (attempt - 1));
    return exponential > _maxReconnectDelayMs
        ? _maxReconnectDelayMs
        : exponential;
  }

  Future<void> _tryReconnect() async {
    final token = await ShphTokenStorage.getAccessToken();
    if (token == null || token.isEmpty || _isTokenExpired(token)) {
      LoggingService.info(
        'Skipping WebSocket reconnect — no valid token',
        tag: 'WebSocket',
      );
      return;
    }
    await _initiateConnection(token);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(milliseconds: _heartbeatIntervalMs),
      (_) => send({'type': 'ping'}),
    );
  }

  /// Send a raw JSON message. Silently ignored if not connected.
  void send(Map<String, dynamic> message) {
    if (_channel == null || _state != ShphConnectionState.connected) {
      LoggingService.warning(
        'Cannot send WebSocket message — not connected',
        tag: 'WebSocket',
      );
      return;
    }
    _channel!.sink.add(jsonEncode(message));
  }

  /// Send a chat message to [threadId].
  void sendChatMessage(
    String threadId,
    String content, {
    String? requestId,
  }) {
    send({
      'type': 'chat_send_message',
      'request_id': requestId ?? _generateRequestId(),
      'thread_id': threadId,
      'content': content,
    });
  }

  /// Send a typing indicator for [threadId].
  void sendTyping(
    String threadId, {
    bool isTyping = true,
    String? requestId,
  }) {
    send({
      'type': 'chat_typing',
      'request_id': requestId ?? _generateRequestId(),
      'thread_id': threadId,
      'is_typing': isTyping,
    });
  }

  /// Send a read receipt for [threadId].
  void markRead(String threadId, {String? requestId}) {
    send({
      'type': 'chat_read_receipt',
      'request_id': requestId ?? _generateRequestId(),
      'thread_id': threadId,
    });
  }

  /// Close the WebSocket and stop all reconnect attempts.
  void disconnect() {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _isConnecting = false;
    _setState(ShphConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
    _messageController.close();
  }

  String _generateRequestId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000000)}';

  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }
      final normalized = base64Url.normalize(parts[1]);
      final decoded = base64Url.decode(normalized);
      final payload = jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null) {
        return false;
      }
      return exp * 1000 < DateTime.now().millisecondsSinceEpoch;
    } catch (_) {
      return true;
    }
  }
}

enum ShphConnectionState {
  disconnected,
  connecting,
  connected,
}
