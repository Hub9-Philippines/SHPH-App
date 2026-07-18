import 'package:flutter/services.dart';

import '/services/logging_service.dart';

enum SoundType { tap, navigate, success, error, warning }

/// Provides optional lightweight system-sound feedback without audio assets.
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  bool _enabled = true;

  bool get isEnabled => _enabled;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> play(SoundType type) async {
    if (!_enabled) {
      return;
    }

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (error, stackTrace) {
      LoggingService.debug(
        'Unable to play ${type.name} system sound',
        tag: 'SoundService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> playTap() => play(SoundType.tap);
  Future<void> playNavigate() => play(SoundType.navigate);
  Future<void> playSuccess() => play(SoundType.success);
  Future<void> playError() => play(SoundType.error);
  Future<void> playWarning() => play(SoundType.warning);
}
