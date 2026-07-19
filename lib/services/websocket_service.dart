import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '/api/api_config.dart';
import '/api/shph_token_storage.dart';
import '/flutter_flow/token_refresh_manager.dart';
import '/services/logging_service.dart';

enum ShphConnectionState { disconnected, connecting, connected, exhausted }

abstract class ShphSocket {
  Future<void> get ready;
  Stream<dynamic> get stream;
  void add(String data);
  Future<void> close();
}

typedef ShphSocketConnector = ShphSocket Function(
  Uri uri,
  List<String> protocols,
);
typedef AccessTokenProvider = Future<String?> Function();
typedef WebSocketUrlProvider = String Function();

/// Guarded SHPH WebSocket transport adapted from
/// `feature/sync-from-shph-main` and verified against `shph-web`.
class ShphWebSocketService {
  ShphWebSocketService({
    ShphSocketConnector? connector,
    AccessTokenProvider? tokenProvider,
    WebSocketUrlProvider? urlProvider,
    this.heartbeatInterval = const Duration(seconds: 30),
    this.silenceTimeout = const Duration(seconds: 45),
    this.initialReconnectDelay = const Duration(seconds: 1),
    this.maxReconnectDelay = const Duration(seconds: 30),
    this.maxReconnectAttempts = 5,
  })  : _connector = connector ?? _defaultConnector,
        _tokenProvider = tokenProvider ?? ShphTokenStorage.getAccessToken,
        _urlProvider = urlProvider ?? (() => ApiConfig.wsUrl);

  static final ShphWebSocketService instance = ShphWebSocketService();

  final ShphSocketConnector _connector;
  final AccessTokenProvider _tokenProvider;
  final WebSocketUrlProvider _urlProvider;
  final Duration heartbeatInterval;
  final Duration silenceTimeout;
  final Duration initialReconnectDelay;
  final Duration maxReconnectDelay;
  final int maxReconnectAttempts;

  final StreamController<ShphConnectionState> _stateController =
      StreamController<ShphConnectionState>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  ShphSocket? _socket;
  // Subscription is cancelled by `_closeSocket`, `disconnect`, and `dispose`.
  // ignore: cancel_subscriptions
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  Future<bool>? _connectFuture;
  ShphConnectionState _state = ShphConnectionState.disconnected;
  DateTime? _lastInboundAt;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;

  Stream<ShphConnectionState> get connectionState => _stateController.stream;
  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  ShphConnectionState get state => _state;
  bool get isConnected => _state == ShphConnectionState.connected;

  static String connectionUrl(String baseUrl) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$normalized/chat/';
  }

  Future<bool> connect() {
    if (isConnected) {
      return Future<bool>.value(true);
    }
    final pending = _connectFuture;
    if (pending != null) {
      return pending;
    }
    _manualDisconnect = false;
    _reconnectAttempts = 0;
    final connection = _connect(resetBudget: true);
    _connectFuture = connection;
    return connection.whenComplete(() {
      if (identical(_connectFuture, connection)) {
        _connectFuture = null;
      }
    });
  }

  Future<bool> _connect({required bool resetBudget}) async {
    if (isConnected || _state == ShphConnectionState.connecting) {
      return isConnected;
    }
    if (resetBudget) {
      _reconnectAttempts = 0;
    }

    final token = await _tokenProvider();
    if (!_isUsableToken(token)) {
      LoggingService.info(
        'WebSocket connection skipped: no valid access token',
        tag: 'WebSocket',
      );
      _setState(ShphConnectionState.disconnected);
      return false;
    }

    final baseUrl = _urlProvider().trim();
    final uri = Uri.tryParse(connectionUrl(baseUrl));
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'ws' && uri.scheme != 'wss')) {
      LoggingService.warning(
        'WebSocket connection skipped: invalid URL',
        tag: 'WebSocket',
      );
      return false;
    }

    _setState(ShphConnectionState.connecting);
    try {
      final socket = _connector(uri, ['shph-auth', token!]);
      _socket = socket;
      _subscription = socket.stream.listen(
        _onMessage,
        onError: _onSocketError,
        onDone: _onSocketDone,
        cancelOnError: false,
      );
      await socket.ready;
      if (_socket != socket || _manualDisconnect) {
        if (_socket == socket) {
          await _closeSocket();
          _setState(ShphConnectionState.disconnected);
        }
        return false;
      }
      _lastInboundAt = DateTime.now();
      _reconnectAttempts = 0;
      _setState(ShphConnectionState.connected);
      _startHeartbeat();
      return true;
    } catch (error, stackTrace) {
      LoggingService.warning(
        'WebSocket handshake failed',
        tag: 'WebSocket',
        error: error,
        stackTrace: stackTrace,
      );
      await _closeSocket();
      _setState(ShphConnectionState.disconnected);
      return false;
    }
  }

  bool send(Map<String, dynamic> message) {
    final socket = _socket;
    if (!isConnected || socket == null) {
      return false;
    }
    try {
      socket.add(jsonEncode(message));
      return true;
    } catch (error, stackTrace) {
      LoggingService.warning(
        'WebSocket send failed',
        tag: 'WebSocket',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    await _closeSocket();
    _setState(ShphConnectionState.disconnected);
  }

  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
    await _messageController.close();
  }

  void _onMessage(dynamic raw) {
    _lastInboundAt = DateTime.now();
    try {
      final decoded = jsonDecode(raw.toString());
      if (decoded is Map<String, dynamic>) {
        _messageController.add(decoded);
      } else if (decoded is Map) {
        _messageController.add(decoded.cast<String, dynamic>());
      }
    } on FormatException {
      LoggingService.warning(
        'Discarded malformed WebSocket message',
        tag: 'WebSocket',
      );
    }
  }

  void _onSocketError(Object error, StackTrace stackTrace) {
    LoggingService.warning(
      'WebSocket transport error',
      tag: 'WebSocket',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _onSocketDone() {
    unawaited(_handleUnexpectedClose());
  }

  Future<void> _handleUnexpectedClose() async {
    await _closeSocket();
    _setState(ShphConnectionState.disconnected);
    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      final lastInbound = _lastInboundAt;
      if (lastInbound != null &&
          DateTime.now().difference(lastInbound) > silenceTimeout) {
        unawaited(_handleUnexpectedClose());
        return;
      }
      send({'type': 'ping'});
    });
  }

  void _scheduleReconnect() {
    if (_manualDisconnect || _reconnectTimer != null) {
      return;
    }
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _setState(ShphConnectionState.exhausted);
      return;
    }
    _reconnectAttempts++;
    final multiplier = 1 << (_reconnectAttempts - 1);
    final computed = initialReconnectDelay * multiplier;
    final delay = computed > maxReconnectDelay ? maxReconnectDelay : computed;
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(_connect(resetBudget: false));
    });
  }

  Future<void> _closeSocket() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    final socket = _socket;
    _socket = null;
    await socket?.close();
  }

  void _setState(ShphConnectionState value) {
    if (_state == value) {
      return;
    }
    _state = value;
    _stateController.add(value);
  }

  static bool _isUsableToken(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }
    final expiry = TokenRefreshManager.extractExpiry(token);
    return expiry == null || expiry.isAfter(DateTime.now().toUtc());
  }

  static ShphSocket _defaultConnector(Uri uri, List<String> protocols) =>
      _ChannelSocket(WebSocketChannel.connect(uri, protocols: protocols));
}

class _ChannelSocket implements ShphSocket {
  _ChannelSocket(this._channel);

  final WebSocketChannel _channel;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<dynamic> get stream => _channel.stream;

  @override
  void add(String data) => _channel.sink.add(data);

  @override
  Future<void> close() async {
    await _channel.sink.close();
  }
}
