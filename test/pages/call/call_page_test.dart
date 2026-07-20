import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/pages/call/call_page.dart';
import 'package:serbisyohubph/services/call/call_controller.dart';
import 'package:serbisyohubph/services/call/call_peer.dart';

import '../../services/call/call_controller_test.dart' show ControllerHarness;

Widget _wrap(CallController controller) => MaterialApp(
      home: ChangeNotifierProvider<CallController>.value(
        value: controller,
        child: const CallPage(),
      ),
    );

void main() {
  late ControllerHarness harness;

  setUp(() => harness = ControllerHarness());
  tearDown(() async => harness.dispose());

  testWidgets('video call controls update the controller', (tester) async {
    await harness.startOutgoing();
    await tester.pumpWidget(_wrap(harness.controller));

    expect(find.byKey(const Key('call_camera_btn')), findsOneWidget);
    expect(harness.controller.isMuted, isFalse);
    await tester.tap(find.byKey(const Key('call_mute_btn')));
    await tester.pump();
    expect(harness.controller.isMuted, isTrue);

    await tester.tap(find.byKey(const Key('call_camera_btn')));
    await tester.pump();
    expect(harness.controller.isCameraOff, isTrue);
  });

  testWidgets('audio calls hide camera controls', (tester) async {
    await harness.controller.initiateCall(
      threadId: 'thread-1',
      participant: const CallParticipant(userId: '42', name: 'Provider'),
      mediaType: CallMediaType.audio,
    );
    await tester.pumpWidget(_wrap(harness.controller));

    expect(find.byKey(const Key('call_mute_btn')), findsOneWidget);
    expect(find.byKey(const Key('call_camera_btn')), findsNothing);
    expect(find.byKey(const Key('call_switch_btn')), findsNothing);
  });

  testWidgets('hangup persists and ends the active call', (tester) async {
    await harness.startOutgoing();
    await tester.pumpWidget(_wrap(harness.controller));

    await tester.tap(find.byKey(const Key('call_hangup_btn')));
    await tester.pumpAndSettle();

    expect(harness.apiCalls, contains('end:call-1:user_ended'));
    expect(harness.controller.status, CallStatus.ended);
  });
}
