import 'package:flutter/services.dart';

import '/services/logging_service.dart';

enum SoundType { tap, navigate, success, error, warning }

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool _enabled = true;
  bool get isEnabled => _enabled;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> play(SoundType type) async {
    if (!_enabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      LoggingService.debug('SoundService.play failed: $e', tag: 'SoundService');
    }
  }

  void playTap() => play(SoundType.tap);
  void playNavigate() => play(SoundType.navigate);
  void playSuccess() => play(SoundType.success);
  void playError() => play(SoundType.error);
  void playWarning() => play(SoundType.warning);
}
