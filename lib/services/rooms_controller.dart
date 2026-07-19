import 'package:flutter/foundation.dart';

import '/api/models/room.dart';
import '/api/resources/rooms_api.dart';
import '/services/logging_service.dart';

enum RoomsState { idle, loading, ready, mutating, error }

class RoomsController extends ChangeNotifier {
  RoomsController({required ShphRoomsApi api}) : _api = api;

  factory RoomsController.production() =>
      RoomsController(api: ShphRoomsApi.instance);

  final ShphRoomsApi _api;
  RoomsState _state = RoomsState.idle;
  List<ShphRoom> _rooms = const [];
  ShphRoom? _currentRoom;
  ShphRoom? _previewRoom;
  String? _errorMessage;

  RoomsState get state => _state;
  List<ShphRoom> get rooms => List.unmodifiable(_rooms);
  ShphRoom? get currentRoom => _currentRoom;
  ShphRoom? get previewRoom => _previewRoom;
  String? get errorMessage => _errorMessage;
  bool get isBusy =>
      _state == RoomsState.loading || _state == RoomsState.mutating;

  Future<bool> load({String? status, int? page, int? pageSize}) async {
    if (!_begin(RoomsState.loading)) {
      return false;
    }
    try {
      final result =
          await _api.list(status: status, page: page, pageSize: pageSize);
      _rooms = List.unmodifiable(result.results);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to load rooms.', error, stackTrace);
      return false;
    }
  }

  Future<bool> open(String id) async {
    if (isBusy) {
      return false;
    }
    try {
      ShphRoomsApi.validRoomId(id);
    } on FormatException {
      return false;
    }
    _begin(RoomsState.loading);
    try {
      _currentRoom = await _api.detail(id);
      _replace(_currentRoom!);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to load this room.', error, stackTrace);
      return false;
    }
  }

  Future<ShphRoom?> create(Map<String, dynamic> payload) async {
    if (!_begin(RoomsState.mutating)) {
      return null;
    }
    try {
      final room = await _api.create(payload);
      _currentRoom = room;
      _replace(room, prepend: true);
      _complete();
      return room;
    } catch (error, stackTrace) {
      _fail('Unable to create the room.', error, stackTrace);
      return null;
    }
  }

  Future<bool> lookup(String token) async {
    if (!_begin(RoomsState.loading)) {
      return false;
    }
    try {
      _previewRoom = await _api.byToken(token);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _previewRoom = null;
      _fail('Unable to find a room for this token.', error, stackTrace);
      return false;
    }
  }

  Future<bool> joinPreview(String token) async {
    final preview = _previewRoom;
    if (preview == null || !_begin(RoomsState.mutating)) {
      return false;
    }
    try {
      final room = await _api.join(preview.id, joinToken: token);
      _currentRoom = room;
      _previewRoom = null;
      _replace(room, prepend: true);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail('Unable to join this room.', error, stackTrace);
      return false;
    }
  }

  Future<bool> lock() => _mutateCurrent(
        _api.lock,
        failureMessage: 'Unable to lock this room.',
      );

  Future<bool> leave() => _removeCurrent(
        _api.leave,
        failureMessage: 'Unable to leave this room.',
      );

  Future<bool> cancel() => _removeCurrent(
        _api.cancel,
        failureMessage: 'Unable to cancel this room.',
      );

  Future<bool> _mutateCurrent(
    Future<ShphRoom> Function(String id) action, {
    required String failureMessage,
  }) async {
    final room = _currentRoom;
    if (room == null || !_begin(RoomsState.mutating)) {
      return false;
    }
    try {
      final updated = await action(room.id);
      _currentRoom = updated;
      _replace(updated);
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail(failureMessage, error, stackTrace);
      return false;
    }
  }

  Future<bool> _removeCurrent(
    Future<ShphRoom> Function(String id) action, {
    required String failureMessage,
  }) async {
    final room = _currentRoom;
    if (room == null || !_begin(RoomsState.mutating)) {
      return false;
    }
    try {
      await action(room.id);
      _rooms = List.unmodifiable(_rooms.where((item) => item.id != room.id));
      _currentRoom = null;
      _complete();
      return true;
    } catch (error, stackTrace) {
      _fail(failureMessage, error, stackTrace);
      return false;
    }
  }

  bool _begin(RoomsState next) {
    if (isBusy) {
      return false;
    }
    _state = next;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void _replace(ShphRoom room, {bool prepend = false}) {
    final updated = [..._rooms];
    final index = updated.indexWhere((item) => item.id == room.id);
    if (index >= 0) {
      updated[index] = room;
    } else if (prepend) {
      updated.insert(0, room);
    } else {
      updated.add(room);
    }
    _rooms = List.unmodifiable(updated);
  }

  void _complete() {
    _state = RoomsState.ready;
    _errorMessage = null;
    notifyListeners();
  }

  void _fail(String message, Object error, StackTrace stackTrace) {
    _state = RoomsState.error;
    _errorMessage = message;
    LoggingService.warning(
      'Rooms operation failed',
      tag: 'RoomsController',
      error: error,
      stackTrace: stackTrace,
    );
    notifyListeners();
  }
}
