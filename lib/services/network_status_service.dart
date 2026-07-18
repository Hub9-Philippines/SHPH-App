import 'dart:async';
import 'dart:io';

class NetworkStatusService {
  NetworkStatusService._();
  static final NetworkStatusService instance = NetworkStatusService._();

  final StreamController<bool> _onlineController = StreamController<bool>.broadcast();
  bool _isOnline = true;
  Timer? _checkTimer;

  Stream<bool> get onOnlineChanged => _onlineController.stream;
  bool get isOnline => _isOnline;

  void initialize() {
    _checkConnection();
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (online != _isOnline) {
        _isOnline = online;
        _onlineController.add(online);
      }
    } catch (_) {
      if (_isOnline) {
        _isOnline = false;
        _onlineController.add(false);
      }
    }
  }

  Future<bool> checkConnection() async {
    await _checkConnection();
    return _isOnline;
  }

  void dispose() {
    _checkTimer?.cancel();
    _onlineController.close();
  }
}
