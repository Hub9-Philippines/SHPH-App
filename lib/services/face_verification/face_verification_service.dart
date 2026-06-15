import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing face verification status and session tracking
///
/// This service handles:
/// - Storing/retrieving face verification status
/// - Tracking verification timestamps for session management
/// - Checking if sessions have expired
class FaceVerificationService {
  static const String _verificationPrefix = 'face_verified_';
  static const String _timestampPrefix = 'face_verified_at_';

  /// Checks if the user has completed face verification
  ///
  /// Returns a map containing:
  /// - 'isVerified': bool indicating verification status
  /// - 'verifiedAt': DateTime? of when verification occurred
  Future<Map<String, dynamic>> getFaceVerificationStatus(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isVerified = prefs.getBool('$_verificationPrefix$userId') ?? false;
      final timestamp = prefs.getInt('$_timestampPrefix$userId');

      return {
        'isVerified': isVerified,
        'verifiedAt': timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(timestamp)
            : null,
      };
    } catch (e) {
      return {'isVerified': false, 'verifiedAt': null};
    }
  }

  /// Marks a user as face verified and records the timestamp
  ///
  /// Call this after successful face verification
  Future<void> markAsVerified(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_verificationPrefix$userId', true);
    await prefs.setInt(
      '$_timestampPrefix$userId',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Clears the verification status for a user
  ///
  /// Call this on logout or when re-verification is required
  Future<void> clearVerification(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_verificationPrefix$userId');
    await prefs.remove('$_timestampPrefix$userId');
  }

  /// Checks if the user's verification session is older than the given minutes
  ///
  /// Returns true if:
  /// - User is not verified
  /// - User was verified but session has expired
  /// Returns false if:
  /// - User is verified and session is still fresh
  Future<bool> isSessionOlderThan(String userId, int minutes) async {
    try {
      final status = await getFaceVerificationStatus(userId);
      final isVerified = status['isVerified'] as bool? ?? false;

      if (!isVerified) {
        return true; // Not verified = stale session
      }

      final verifiedAt = status['verifiedAt'] as DateTime?;
      if (verifiedAt == null) {
        return true; // No timestamp = stale session
      }

      final sessionAge = DateTime.now().difference(verifiedAt);
      return sessionAge.inMinutes > minutes;
    } catch (e) {
      return true; // On error, treat as stale
    }
  }

  /// Gets the time remaining before session expires
  ///
  /// Returns Duration.zero if session is already expired
  Future<Duration> getSessionTimeRemaining(String userId, int sessionMinutes) async {
    try {
      final status = await getFaceVerificationStatus(userId);
      final isVerified = status['isVerified'] as bool? ?? false;
      final verifiedAt = status['verifiedAt'] as DateTime?;

      if (!isVerified || verifiedAt == null) {
        return Duration.zero;
      }

      final expiryTime = verifiedAt.add(Duration(minutes: sessionMinutes));
      final remaining = expiryTime.difference(DateTime.now());

      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      return Duration.zero;
    }
  }
}
