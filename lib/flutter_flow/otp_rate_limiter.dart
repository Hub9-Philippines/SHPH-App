import 'auth_logger.dart';

/// Manages rate limiting for OTP requests
/// Prevents brute force attacks and excessive API usage
class OtpRateLimiter {

  factory OtpRateLimiter() => _instance;

  OtpRateLimiter._internal();
  static final OtpRateLimiter _instance = OtpRateLimiter._internal();

  /// Phone number -> Last OTP request timestamp
  final Map<String, DateTime> _requestTimestamps = {};

  /// Minimum time between OTP requests for the same phone number
  /// 60 seconds between requests (prevent rapid-fire attacks)
  static const Duration _minInterval = Duration(seconds: 60);

  /// Maximum OTP requests per phone number within time window
  /// 5 attempts per 24 hours per phone number
  static const int _maxAttemptsPerDay = 5;

  /// Time window for max attempts tracking
  static const Duration _timeWindow = Duration(hours: 24);

  /// Phone number -> List of attempt timestamps
  final Map<String, List<DateTime>> _attemptHistory = {};

  /// Get time remaining before user can request another OTP
  /// Returns null if user can request immediately
  Duration? getTimeUntilNextRequest(String phoneNumber) {
    final normalizedPhone = _normalizePhoneNumber(phoneNumber);
    final lastRequest = _requestTimestamps[normalizedPhone];

    if (lastRequest == null) {
      return null; // First request, no wait needed
    }

    final timeSinceLastRequest = DateTime.now().difference(lastRequest);

    if (timeSinceLastRequest < _minInterval) {
      return _minInterval - timeSinceLastRequest;
    }

    return null; // Enough time has passed
  }

  /// Check if phone number has exceeded daily rate limit
  bool isExceededDailyLimit(String phoneNumber) {
    final normalizedPhone = _normalizePhoneNumber(phoneNumber);
    final history = _attemptHistory[normalizedPhone] ?? [];

    // Remove old attempts outside the time window
    final now = DateTime.now();
    final recentAttempts =
        history.where((time) => now.difference(time) < _timeWindow).toList();

    return recentAttempts.length >= _maxAttemptsPerDay;
  }

  /// Validate if OTP request is allowed
  /// Returns error message if request is not allowed, null if allowed
  String? validateOtpRequest(String phoneNumber) {
    final normalizedPhone = _normalizePhoneNumber(phoneNumber);

    // Check daily limit first
    if (isExceededDailyLimit(normalizedPhone)) {
      AuthLogger.debug(
        'OTP request exceeded daily limit for $normalizedPhone',
        tag: 'RateLimit',
      );
      return 'Too many verification attempts. Please try again tomorrow.';
    }

    // Check minimum interval
    final timeUntilNext = getTimeUntilNextRequest(normalizedPhone);
    if (timeUntilNext != null) {
      final secondsRemaining = timeUntilNext.inSeconds;
      AuthLogger.debug(
        'OTP request rate limited for $normalizedPhone. '
        'Try again in $secondsRemaining seconds',
        tag: 'RateLimit',
      );
      return 'Please wait ${secondsRemaining}s before requesting another code.';
    }

    return null; // Request is allowed
  }

  /// Record an OTP request attempt
  /// Call this AFTER successful OTP request to the SHPH API
  void recordOtpRequest(String phoneNumber) {
    final normalizedPhone = _normalizePhoneNumber(phoneNumber);
    final now = DateTime.now();

    // Update last request timestamp
    _requestTimestamps[normalizedPhone] = now;

    // Add to attempt history
    if (!_attemptHistory.containsKey(normalizedPhone)) {
      _attemptHistory[normalizedPhone] = [];
    }
    _attemptHistory[normalizedPhone]?.add(now);

    // Clean up old attempts to prevent memory issues
    _cleanupOldAttempts(normalizedPhone);

    AuthLogger.debug(
      'OTP request recorded for $normalizedPhone',
      tag: 'RateLimit',
    );
  }

  /// Clean up old attempts outside the time window
  void _cleanupOldAttempts(String normalizedPhone) {
    if (!_attemptHistory.containsKey(normalizedPhone)) {
      return;
    }

    final now = DateTime.now();
    final attempts = _attemptHistory[normalizedPhone]!;

    // Keep only recent attempts within the time window
    _attemptHistory[normalizedPhone] =
        attempts.where((time) => now.difference(time) < _timeWindow).toList();

    // Remove phone number entry if no attempts remain
    if (_attemptHistory[normalizedPhone]?.isEmpty ?? true) {
      _attemptHistory.remove(normalizedPhone);
    }
  }

  /// Clear all rate limit data for a phone number (use after successful OTP verification)
  void clearPhoneNumber(String phoneNumber) {
    final normalizedPhone = _normalizePhoneNumber(phoneNumber);
    _requestTimestamps.remove(normalizedPhone);
    _attemptHistory.remove(normalizedPhone);

    AuthLogger.debug(
      'Cleared rate limit data for $normalizedPhone',
      tag: 'RateLimit',
    );
  }

  /// Normalize phone number for consistent tracking
  /// Removes spaces, dashes, and other formatting
  String _normalizePhoneNumber(String phoneNumber) => phoneNumber.replaceAll(RegExp('[^0-9+]'), '');

  /// Reset all rate limit data (for testing or config changes)
  void reset() {
    _requestTimestamps.clear();
    _attemptHistory.clear();

    AuthLogger.debug('Rate limiter reset', tag: 'RateLimit');
  }

  /// Get stats for debugging
  Map<String, dynamic> getStats() => {
        'tracked_numbers': _requestTimestamps.length,
        'min_interval_seconds': _minInterval.inSeconds,
        'max_attempts_per_day': _maxAttemptsPerDay,
        'time_window_hours': _timeWindow.inHours,
      };
}
