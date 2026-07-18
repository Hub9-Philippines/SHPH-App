import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import 'logging_service.dart';

/// Result of a biometric authentication attempt.
enum BiometricAuthResult {
  success,
  cancelled,
  notAvailable,
  notEnrolled,
  failed,
}

/// Handles device-level biometric authentication and secure storage of the
/// refresh token. Biometric credentials never leave the device; the stored
/// refresh token is only released after a successful local auth prompt.
class BiometricAuthService {
  BiometricAuthService._();

  static final BiometricAuthService _instance = BiometricAuthService._();
  static BiometricAuthService get instance => _instance;

  static const String _refreshTokenKey = 'shph_biometric_refresh_token';
  static const String _biometricEnabledKey = 'shph_biometric_enabled';

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Secure storage configured for highest available protection. On iOS this
  /// uses keychain; on Android it uses encrypted SharedPreferences.
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accountName: 'shph_biometric_account',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Whether the device supports biometric authentication.
  Future<bool> get isDeviceSupported => _localAuth.isDeviceSupported();

  /// Whether any biometric hardware is available.
  Future<bool> get canCheckBiometrics => _localAuth.canCheckBiometrics;

  /// List of enrolled biometric types (fingerprint, face, etc.).
  Future<List<BiometricType>> get availableBiometrics async {
    if (!await canCheckBiometrics) {
      return [];
    }
    return _localAuth.getAvailableBiometrics();
  }

  /// Check if biometric login is enabled and a refresh token is stored.
  Future<bool> get isBiometricLoginEnabled async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    final token = await _secureStorage.read(key: _refreshTokenKey);
    return enabled == 'true' && token != null && token.isNotEmpty;
  }

  /// Prompt for biometric authentication.
  Future<BiometricAuthResult> authenticate({
    String localizedReason = 'Please authenticate to sign in to SerbisyoHub',
  }) async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric authentication',
            cancelButton: 'Cancel',
            biometricHint: 'Verify your identity',
            biometricNotRecognized: 'Not recognized, try again',
            biometricRequiredTitle: 'Biometric authentication required',
            biometricSuccess: 'Authentication successful',
            deviceCredentialsRequiredTitle:
                'Please enable device credentials to continue',
            deviceCredentialsSetupDescription:
                'Device credentials are required to use biometric authentication',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription:
                'Please set up biometric authentication in Settings',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription:
                'Please set up Face ID / Touch ID in Settings',
            lockOut: 'Biometric authentication is disabled. Please try again.',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      return didAuthenticate
          ? BiometricAuthResult.success
          : BiometricAuthResult.cancelled;
    } on PlatformException catch (e) {
      LoggingService.warning(
        'Biometric authentication platform error: ${e.code}',
        tag: 'BiometricAuth',
        error: e,
      );

      switch (e.code) {
        case 'NotAvailable':
        case 'NotSupported':
        case 'PasscodeNotSet':
          return BiometricAuthResult.notAvailable;
        case 'NotEnrolled':
          return BiometricAuthResult.notEnrolled;
        case 'UserCancel':
        case 'UserFallback':
        case 'SystemCancel':
          return BiometricAuthResult.cancelled;
        default:
          return BiometricAuthResult.failed;
      }
    }
  }

  /// Store the refresh token after the user opts in to biometric login.
  /// Does not require a biometric prompt here; the prompt happens on read.
  Future<bool> enableBiometricLogin(String refreshToken) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      return true;
    } catch (e) {
      LoggingService.error(
        'Failed to enable biometric login',
        tag: 'BiometricAuth',
        error: e,
      );
      return false;
    }
  }

  /// Retrieve the stored refresh token after successful biometric auth.
  /// Returns null if auth fails or no token is stored.
  Future<String?> getRefreshTokenWithAuth() async {
    final result = await authenticate();
    if (result != BiometricAuthResult.success) {
      return null;
    }

    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      LoggingService.error(
        'Failed to read secure refresh token',
        tag: 'BiometricAuth',
        error: e,
      );
      return null;
    }
  }

  /// Disable biometric login and remove the stored refresh token.
  Future<void> disableBiometricLogin() async {
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
  }
}
