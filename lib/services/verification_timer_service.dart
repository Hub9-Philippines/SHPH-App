import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

/// Persistent countdown timer service for verification progress screen.
/// Maintains timer state across navigation without resetting.
class VerificationTimerService {
  VerificationTimerService._internal();
  
  static final VerificationTimerService _instance = VerificationTimerService._internal();
  static VerificationTimerService get instance => _instance;
  
  static const int _totalSeconds = 30 * 60; // 30 minutes
  
  StreamController<int>? _controller;
  Timer? _timer;
  DateTime? _startTime;
  
  /// Stream that emits remaining seconds every second
  Stream<int> get timerStream {
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<int>.broadcast();
      _startTimer();
    }
    return _controller!.stream;
  }
  
  /// Get current remaining seconds without subscribing to stream
  int get remainingSeconds {
    if (_startTime == null) {
      return _totalSeconds;
    }
    final elapsed = DateTime.now().difference(_startTime!).inSeconds;
    return (_totalSeconds - elapsed).clamp(0, _totalSeconds);
  }
  
  void _startTimer() {
    _startTime ??= DateTime.now();
    
    final initialRemaining = remainingSeconds;
    if (initialRemaining <= 0) {
      _controller?.add(0);
      _stopTimer();
      _performVerificationApprovalSync();
      return;
    }
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      final remaining = _totalSeconds - elapsed;
      
      if (remaining <= 0) {
        _controller?.add(0);
        _stopTimer();
        _performVerificationApprovalSync();
      } else {
        _controller?.add(remaining);
      }
    });
    
    // Emit initial value
    _controller?.add(initialRemaining);
  }

  Future<void> _performVerificationApprovalSync() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        return;
      }

      // 1. Prepare verification_status to 'verified' in Supabase
      final updateData = <String, dynamic>{
        'verification_status': 'verified',
      };

      // 2. Fetch local staged edits from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final pendingKey = 'pending_profile_edits_$userId';
      final pendingJson = prefs.getString(pendingKey);
      
      if (pendingJson != null) {
        final stagedData = jsonDecode(pendingJson) as Map<String, dynamic>;
        // Merge the staged fields
        if (stagedData['display_name'] != null) {
          updateData['display_name'] = stagedData['display_name'];
        }
        if (stagedData['email'] != null) {
          updateData['email'] = stagedData['email'];
        }
        if (stagedData['phone_number'] != null) {
          updateData['phone_number'] = stagedData['phone_number'];
        }
      }

      // 3. Update Supabase
      await ProfilesTable().update(
        data: updateData,
        matchingRows: (rows) => rows.eq('id', userId),
      );

      // 4. Clear the local staged edits on success
      if (pendingJson != null) {
        await prefs.remove(pendingKey);
      }

      LoggingService.info('Verification status and staged edits synced successfully for user $userId.', tag: 'VerificationTimerService');
    } catch (e) {
      LoggingService.error('Error during verification approval sync: $e', tag: 'VerificationTimerService');
    }
  }
  
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Reset the timer to start fresh
  void reset() {
    _stopTimer();
    _controller?.close();
    _controller = null;
    _startTime = null;
  }
  
  /// Pause the timer (keeps elapsed time)
  void pause() {
    _stopTimer();
  }
  
  /// Resume the timer from where it left off
  void resume() {
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<int>.broadcast();
    }
    _startTimer();
  }
  
  /// Clean up resources
  void dispose() {
    _stopTimer();
    _controller?.close();
    _controller = null;
    _startTime = null;
  }
  
  /// Format seconds to MM:SS
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
