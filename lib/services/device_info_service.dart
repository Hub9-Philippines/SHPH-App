import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Builds the web-compatible `device_info` payload attached to login and
/// registration requests (mirrors `src/services/deviceInfo.ts`).
class DeviceInfoService {
  DeviceInfoService._();
  static final DeviceInfoService instance = DeviceInfoService._();

  Map<String, dynamic>? _cached;

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final cached = _cached;
    if (cached != null) return cached;

    String? model;
    String? manufacturer;
    String? osVersion;
    String? deviceId;
    String platform = _platformName;
    String platformType = _platformName;

    try {
      final plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        // device_info_plus has no web support; keep defaults.
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        model = info.model;
        manufacturer = info.manufacturer;
        osVersion = info.version.release;
        deviceId = info.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        model = info.utsname.machine;
        manufacturer = 'Apple';
        osVersion = info.systemVersion;
        deviceId = info.identifierForVendor;
      }
    } catch (e) {
      debugPrint('DeviceInfoService: failed to read device info: $e');
    }

    final deviceName = (manufacturer != null && model != null)
        ? '$manufacturer $model'
        : (model ?? platform);

    final result = <String, dynamic>{
      'platform': platform,
      'platformType': platformType,
      if (osVersion != null && osVersion.isNotEmpty) 'osVersion': osVersion,
      if (model != null && model.isNotEmpty) 'deviceModel': model,
      'deviceName': deviceName,
      'deviceFingerprint': _fingerprint(
        platform,
        model,
        manufacturer,
        osVersion,
        deviceId,
      ),
    };

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      result['appVersion'] = packageInfo.version;
    } catch (_) {}

    _cached = result;
    return result;
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }

  /// Stable, opaque fingerprint from device identifiers (mirrors the web
  /// app's hash of the same inputs).
  static String _fingerprint(
    String platform,
    String? model,
    String? manufacturer,
    String? osVersion,
    String? deviceId,
  ) {
    final raw =
        [platform, model, manufacturer, osVersion, deviceId].join('|');
    final bytes = utf8.encode(raw);
    var hash = 0;
    for (final byte in bytes) {
      hash = (hash << 5) - hash + byte;
      hash = hash & hash;
    }
    return hash.abs().toRadixString(16);
  }
}
