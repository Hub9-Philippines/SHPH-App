import 'dart:async';
import 'dart:io';

import '/api/api_config.dart';
import '/services/logging_service.dart';

typedef NetworkProbe = Future<bool> Function();

/// Monitors whether the configured SHPH API host is reachable.
///
/// Adapted from `feature/sync-from-shph-main`'s
/// `lib/services/network_status_service.dart`; probes the configured SHPH host
/// instead of a third-party domain and supports deterministic injection.
class NetworkStatusService {
  NetworkStatusService({
    NetworkProbe? probe,
    this.interval = const Duration(seconds: 30),
  }) : _probe = probe ?? _probeShphApi;

  static final NetworkStatusService instance = NetworkStatusService();

  final NetworkProbe _probe;
  final Duration interval;
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool _initialized = false;
  Timer? _checkTimer;

  Stream<bool> get onOnlineChanged => _onlineController.stream;
  bool get isOnline => _isOnline;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await checkConnection();
    _checkTimer = Timer.periodic(interval, (_) => unawaited(checkConnection()));
  }

  Future<bool> checkConnection() async {
    bool online;
    try {
      online = await _probe();
    } catch (error, stackTrace) {
      online = false;
      LoggingService.debug(
        'Network probe failed',
        tag: 'NetworkStatusService',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (online != _isOnline) {
      _isOnline = online;
      _onlineController.add(online);
    }
    return online;
  }

  void stop() {
    _checkTimer?.cancel();
    _checkTimer = null;
    _initialized = false;
  }

  Future<void> dispose() async {
    stop();
    await _onlineController.close();
  }

  static Future<bool> _probeShphApi() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await client
          .headUrl(Uri.parse(ApiConfig.baseUrl))
          .timeout(const Duration(seconds: 5));
      final response =
          await request.close().timeout(const Duration(seconds: 5));
      await response.drain<void>();
      return true;
    } finally {
      client.close(force: true);
    }
  }
}
