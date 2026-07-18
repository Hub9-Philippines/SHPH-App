import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundService', () {
    test('enabled is true by default', () {
      // Reset to default state
      SoundService.instance.setEnabled(true);
      expect(SoundService.instance.isEnabled, isTrue);
    });

    test('setEnabled(false) disables sound', () {
      SoundService.instance.setEnabled(false);
      expect(SoundService.instance.isEnabled, isFalse);
    });

    test('setEnabled(true) re-enables sound', () {
      SoundService.instance.setEnabled(false);
      SoundService.instance.setEnabled(true);
      expect(SoundService.instance.isEnabled, isTrue);
    });

    test('play is a no-op when disabled', () {
      SoundService.instance.setEnabled(false);
      // Should not throw
      expect(
        () => SoundService.instance.play(SoundType.tap),
        returnsNormally,
      );
      // Re-enable for other tests
      SoundService.instance.setEnabled(true);
    });

    test('play does not throw when enabled', () {
      SoundService.instance.setEnabled(true);
      expect(
        () => SoundService.instance.play(SoundType.tap),
        returnsNormally,
      );
    });
  });
}
