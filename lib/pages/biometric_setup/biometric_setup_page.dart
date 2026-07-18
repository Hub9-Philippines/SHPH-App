import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/exceptions.dart';
import 'package:passkeys/types.dart';

import '/api/models/session.dart';
import '/api/resources/auth_api.dart';
import '/theme/app_theme.dart';

/// Setup biometric login via WebAuthn passkeys.
///
/// Mirrors `shph-app/src/views/auth/BiometricSetupPage.vue`. The SHPH backend
/// uses WebAuthn-style credential registration
/// (`/api/auth/biometric/register/*`). On Flutter native we use the `passkeys`
/// package (Corbado) which delegates to the platform's native Credential
/// Manager (Android) / ASAuthorizationCredentialManager (iOS) — producing real
/// WebAuthn attestations that the backend can verify.
///
/// Flow:
///   1. POST `/api/auth/biometric/register/options/` → backend returns
///      `publicKeyCredentialCreationOptions` (challenge, rp, user, etc.).
///   2. `PasskeyAuthenticator.register(RegisterRequestType.fromJson(options))`
///      → OS prompts Face ID / Touch ID → returns `RegisterResponseType`
///      containing `attestationObject` + `clientDataJSON`.
///   3. POST `/api/auth/biometric/register/verify/` with the attestation JSON
///      → backend verifies the WebAuthn signature and stores the public key.
class BiometricSetupPage extends StatefulWidget {
  const BiometricSetupPage({super.key});

  static String routeName = 'BiometricSetup';
  static String routePath = '/biometric-setup';

  @override
  State<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends State<BiometricSetupPage> {
  final PasskeyAuthenticator _authenticator = PasskeyAuthenticator();
  final _deviceNameCtrl = TextEditingController();

  List<ShphBiometricCredential> _credentials = const [];
  bool _isLoading = true;
  bool _isEnrolling = false;
  bool _isTesting = false;
  bool _passkeysSupported = false;
  String? _errorMessage;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInitial());
  }

  @override
  void dispose() {
    _deviceNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final availability = _authenticator.getAvailability();
      bool supported = false;
      try {
        // Platform-specific availability checks; failures mean unsupported.
        if (Theme.of(context).platform == TargetPlatform.android) {
          supported = (await availability.android()).hasPasskeySupport;
        } else if (Theme.of(context).platform == TargetPlatform.iOS ||
            Theme.of(context).platform == TargetPlatform.macOS) {
          supported = (await availability.iOS()).hasPasskeySupport;
        } else {
          supported = true; // optimistic for web/desktop
        }
      } catch (_) {
        supported = false;
      }
      final creds = await ShphAuthApi.instance.listBiometricCredentials();
      if (mounted) {
        setState(() {
          _passkeysSupported = supported;
          _credentials = creds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load: $e';
        });
      }
    }
  }

  Future<void> _enroll() async {
    if (!_passkeysSupported) {
      setState(() => _errorMessage =
          'Passkeys are not available on this device. Set up Face ID / Touch ID or update your OS.');
      return;
    }
    final deviceName = _deviceNameCtrl.text.trim().isEmpty
        ? 'Flutter device'
        : _deviceNameCtrl.text.trim();
    setState(() {
      _isEnrolling = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      // Step 1: request registration options from the backend.
      final options = await ShphAuthApi.instance
          .biometricRegisterOptions(deviceName: deviceName);
      // Step 2: ask the platform authenticator to create a passkey.
      // The backend returns a WebAuthn `publicKeyCredentialCreationOptions`
      // map; `RegisterRequestType.fromJson` parses it into the request type
      // expected by the platform.
      final request = RegisterRequestType.fromJson(options);
      final response = await _authenticator.register(request);
      // Step 3: send the attestation back to the backend for verification.
      final attestation = response.toJson();
      attestation['device_name'] = deviceName;
      await ShphAuthApi.instance
          .biometricRegisterVerify(attestation: attestation);
      if (mounted) {
        setState(() {
          _isEnrolling = false;
          _statusMessage = 'Device registered for biometric login';
          _deviceNameCtrl.clear();
        });
        await _loadInitial();
      }
    } on PasskeyAuthCancelledException {
      if (mounted) {
        setState(() {
          _isEnrolling = false;
          _errorMessage = 'Biometric authentication cancelled';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEnrolling = false;
          _errorMessage = 'Enrollment failed: $e';
        });
      }
    }
  }

  Future<void> _testLogin() async {
    if (!_passkeysSupported) return;
    setState(() {
      _isTesting = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      // Step 1: request authentication options from the backend.
      final options = await ShphAuthApi.instance.biometricAuthOptions();
      // Step 2: ask the platform authenticator to sign the challenge.
      final request = AuthenticateRequestType.fromJson(options);
      final response = await _authenticator.authenticate(request);
      // Step 3: send the assertion back to the backend for verification.
      final assertion = response.toJson();
      await ShphAuthApi.instance.biometricAuthVerify(assertion: assertion);
      if (mounted) {
        setState(() {
          _isTesting = false;
          _statusMessage = 'Biometric login verified';
        });
      }
    } on PasskeyAuthCancelledException {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _errorMessage = 'Authentication cancelled';
        });
      }
    } on NoCredentialsAvailableException {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _errorMessage = 'No passkey registered on this device';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _errorMessage = 'Test login failed: $e';
        });
      }
    }
  }

  Future<void> _delete(ShphBiometricCredential cred) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove device?'),
        content: Text(
            'Remove "${cred.deviceName ?? 'Device #${cred.id}'}" from biometric login?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ShphAuthApi.instance.deleteBiometricCredential(cred.id);
      await _loadInitial();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Remove failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Biometric Login',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                if (!_passkeysSupported)
                  _InfoBanner(
                    icon: Icons.info_outline,
                    color: Colors.orange.shade700,
                    text:
                        'Passkeys are not available on this device. Set up Face ID / Touch ID in your system settings first, or update to iOS 16+ / Android 9+.',
                  )
                else ...[
                  Text('Register a device',
                      style: theme.titleMedium
                          .override(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _deviceNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Device name (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. iPhone 15 Pro',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isEnrolling ? null : _enroll,
                    icon: _isEnrolling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(
                        _isEnrolling ? 'Registering…' : 'Register passkey'),
                  ),
                  const SizedBox(height: 24),
                  if (_credentials.isNotEmpty) ...[
                    Text('Registered devices',
                        style: theme.titleMedium
                            .override(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    for (final cred in _credentials)
                      _CredentialTile(
                        credential: cred,
                        onDelete: () => _delete(cred),
                      ),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: _isTesting ? null : _testLogin,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_open),
                      label: Text(
                          _isTesting ? 'Verifying…' : 'Test biometric login'),
                    ),
                  ],
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _InfoBanner(
                    icon: Icons.error_outline,
                    color: theme.error,
                    text: _errorMessage!,
                  ),
                ],
                if (_statusMessage != null) ...[
                  const SizedBox(height: 16),
                  _InfoBanner(
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    text: _statusMessage!,
                  ),
                ],
              ],
            ),
    );
  }
}

class _CredentialTile extends StatelessWidget {
  const _CredentialTile({required this.credential, required this.onDelete});
  final ShphBiometricCredential credential;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.devices, size: 28),
        title: Text(credential.deviceName ?? 'Device #${credential.id}'),
        subtitle: Text('Added ${credential.createdAt ?? 'recently'}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
