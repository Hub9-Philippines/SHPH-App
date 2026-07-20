import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/pages/call/incoming_call_overlay.dart';
import 'package:serbisyohubph/services/call/call_controller.dart';
import 'package:serbisyohubph/services/call/call_peer.dart';

import '../../services/call/call_controller_test.dart' show ControllerHarness;

Widget _wrap(
  CallController controller, {
  Future<void> Function()? onAccepted,
}) =>
    MaterialApp(
      home: ChangeNotifierProvider<CallController>.value(
        value: controller,
        child: Scaffold(
          body: Stack(
            children: [IncomingCallOverlay(onAccepted: onAccepted)],
          ),
        ),
      ),
    );

void main() {
  late ControllerHarness harness;

  setUp(() => harness = ControllerHarness());
  tearDown(() async => harness.dispose());

  testWidgets('is hidden when no call is ringing', (tester) async {
    await tester.pumpWidget(_wrap(harness.controller));

    expect(find.byKey(const Key('call_accept_btn')), findsNothing);
    expect(find.byKey(const Key('call_reject_btn')), findsNothing);
  });

  testWidgets('shows the resolved caller and rejects once', (tester) async {
    await tester.pumpWidget(_wrap(harness.controller));
    harness.inbound(harness.incomingSignal());
    await Future<void>.delayed(Duration.zero);
    await tester.pump();
    await tester.pump();

    expect(find.text('User 77'), findsOneWidget);
    expect(find.text('Incoming video call'), findsOneWidget);
    await tester.tap(find.byKey(const Key('call_reject_btn')));
    await tester.pump();
    await Future<void>.delayed(Duration.zero);
    await tester.pump();

    expect(harness.apiCalls.where((call) => call == 'reject:call-2:declined'),
        hasLength(1));
    expect(harness.controller.status, CallStatus.ended);
  });

  testWidgets('accepts an audio call and invokes navigation callback',
      (tester) async {
    var accepted = 0;
    await tester.pumpWidget(_wrap(
      harness.controller,
      onAccepted: () async => accepted++,
    ));
    harness.inbound({
      ...harness.incomingSignal(),
      'callType': CallMediaType.audio.name,
    });
    await Future<void>.delayed(Duration.zero);
    await tester.pump();
    await tester.pump();

    expect(find.text('Incoming audio call'), findsOneWidget);
    await tester.tap(find.byKey(const Key('call_accept_btn')));
    await tester.pump();
    await Future<void>.delayed(Duration.zero);
    await tester.pump();

    expect(harness.apiCalls, contains('accept:call-2'));
    expect(harness.controller.status, CallStatus.connecting);
    expect(accepted, 1);
  });
}
