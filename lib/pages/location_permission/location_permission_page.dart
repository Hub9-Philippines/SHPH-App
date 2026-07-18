import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '/theme/app_theme.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  static String routeName = 'LocationPermission';
  static String routePath = '/location-permission';

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

enum _PermissionState { unknown, denied }

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _detecting = false;
  String _errorMessage = '';
  _PermissionState _permissionState = _PermissionState.unknown;

  @override
  void initState() {
    super.initState();
    _checkExistingPermission();
  }

  Future<void> _checkExistingPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _permissionState = _PermissionState.denied);
        return;
      }
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        unawaited(_handleRequest());
      } else {
        setState(() => _permissionState = _PermissionState.unknown);
      }
    } catch (_) {
      setState(() => _permissionState = _PermissionState.unknown);
    }
  }

  Future<void> _handleRequest() async {
    setState(() {
      _detecting = true;
      _errorMessage = '';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _permissionState = _PermissionState.denied;
          _errorMessage =
              'Location services are disabled. Please enable them in your device settings.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _permissionState = _PermissionState.unknown;
          _errorMessage = 'Location permission was denied.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _permissionState = _PermissionState.denied;
          _errorMessage =
              'Location access is blocked. Please enable it in your device settings.';
        });
        return;
      }

      // Permission granted — verify we can get coordinates
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        _proceedToApp();
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Could not detect your location. You can try again or continue without it.';
      });
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  void _proceedToApp() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _handleSkip() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  String get _primaryButtonLabel {
    if (_detecting) return 'Detecting…';
    if (_permissionState == _PermissionState.denied) return 'Retry';
    return 'Enable Location';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 64,
                color: theme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Location Access Required',
                style: theme.headlineSmall.override(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Serbisyo Hub needs your location to match you with nearby service providers. Your location is only used for booking and matching — never shared without your consent.',
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  color: theme.secondaryText,
                ),
              ),
              if (_permissionState == _PermissionState.denied) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: theme.warning, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Location access is blocked. Please enable it in your device settings, then tap the button below.',
                          style: theme.bodySmall.override(color: theme.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_detecting) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text('Detecting your location…',
                        style: theme.bodyMedium
                            .override(color: theme.secondaryText)),
                  ],
                ),
              ],
              if (_errorMessage.isNotEmpty &&
                  _permissionState != _PermissionState.denied) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: theme.error, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: theme.bodySmall.override(color: theme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _detecting ? null : _handleRequest,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _detecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 20),
                            const SizedBox(width: 8),
                            Text(_primaryButtonLabel),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _detecting ? null : _handleSkip,
                child: Text(
                  'Skip for now',
                  style: TextStyle(color: theme.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
