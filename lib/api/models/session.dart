/// An active session/device for the current user.
///
/// Mirrors `shph-api/auth_api/views.py::SessionListView` response items.
class ShphSession {
  const ShphSession({
    required this.sessionId,
    this.deviceInfo,
    this.ipAddress,
    this.userAgent,
    this.createdAt,
    this.lastActivity,
    this.isCurrent = false,
  });

  factory ShphSession.fromJson(Map<String, dynamic> json) => ShphSession(
        sessionId:
            json['session_id']?.toString() ?? json['id']?.toString() ?? '',
        deviceInfo: json['device_info'] as String?,
        ipAddress: json['ip_address'] as String?,
        userAgent: json['user_agent'] as String?,
        createdAt: json['created_at'] as String?,
        lastActivity: json['last_activity'] as String?,
        isCurrent: json['is_current'] as bool? ?? false,
      );

  final String sessionId;
  final String? deviceInfo;
  final String? ipAddress;
  final String? userAgent;
  final String? createdAt;
  final String? lastActivity;
  final bool isCurrent;
}

/// A registered biometric credential (WebAuthn passkey).
///
/// Mirrors `shph-api/auth_api/biometric_views.py::BiometricCredentialListView`.
class ShphBiometricCredential {
  const ShphBiometricCredential({
    required this.id,
    this.deviceName,
    this.credentialId,
    this.createdAt,
    this.lastUsedAt,
    this.signCount = 0,
  });

  factory ShphBiometricCredential.fromJson(Map<String, dynamic> json) =>
      ShphBiometricCredential(
        id: json['id'] as int? ?? 0,
        deviceName: json['device_name'] as String?,
        credentialId: json['credential_id'] as String?,
        createdAt: json['created_at'] as String?,
        lastUsedAt: json['last_used_at'] as String?,
        signCount: json['sign_count'] as int? ?? 0,
      );

  final int id;
  final String? deviceName;
  final String? credentialId;
  final String? createdAt;
  final String? lastUsedAt;
  final int signCount;
}
