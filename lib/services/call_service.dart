import 'dart:async';


import '/services/logging_service.dart';

enum CallState { idle, calling, ringing, connected, ended, failed }

class CallService {
  CallService._();
  static final CallService instance = CallService._();

  bool _initialized = false;
  final _stateController = StreamController<CallState>.broadcast();

  bool get isInitialized => _initialized;
  Stream<CallState> get stateStream => _stateController.stream;
  CallState _state = CallState.idle;
  CallState get state => _state;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    LoggingService.info('Call service initialized', tag: 'CallService');
  }

  Future<void> startCall({
    required String targetUserId,
    required String targetName,
    bool isVideo = false,
  }) async {
    _updateState(CallState.calling);
    LoggingService.info(
      'Starting ${isVideo ? "video" : "voice"} call to $targetName ($targetUserId)',
      tag: 'CallService',
    );
  }

  Future<void> endCall() async {
    _updateState(CallState.ended);
  }

  Future<void> acceptCall() async {
    _updateState(CallState.connected);
  }

  Future<void> rejectCall() async {
    _updateState(CallState.ended);
  }

  void _updateState(CallState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<void> dispose() async {
    await _stateController.close();
    _initialized = false;
  }
}
