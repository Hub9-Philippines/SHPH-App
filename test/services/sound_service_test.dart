import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => SoundService.instance.setEnabled(true));

  test('sound feedback is enabled by default', () {
    expect(SoundService.instance.isEnabled, isTrue);
  });

  test('sound feedback can be disabled and enabled', () {
    SoundService.instance.setEnabled(false);
    expect(SoundService.instance.isEnabled, isFalse);

    SoundService.instance.setEnabled(true);
    expect(SoundService.instance.isEnabled, isTrue);
  });

  test('play completes without a platform call when disabled', () async {
    SoundService.instance.setEnabled(false);
    await expectLater(
      SoundService.instance.play(SoundType.tap),
      completes,
    );
  });
}
