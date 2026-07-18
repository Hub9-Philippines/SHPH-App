import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/pages/call/call_page.dart';
import 'package:serbisyohubph/services/call/call_controller.dart';
import 'package:serbisyohubph/services/call/call_peer.dart';

import 'call_controller_test.dart' show Harness;

Widget _wrap(CallController c) => MaterialApp(
      home: ChangeNotifierProvider<CallController>.value(
        value: c,
        child: const CallPage(),
      ),
    );

void main() {
  testWidgets('mute button toggles controller.isMuted', (tester) async {
    final h = Harness();
    await h.controller.initiateCall(
      threadId: 't1',
      callee: const CallParticipant(userId: '42', name: 'Bob'),
    );
    await tester.pumpWidget(_wrap(h.controller));
    await tester.pump();

    expect(h.controller.isMuted, isFalse);
    await tester.tap(find.byKey(const Key('call_mute_btn')));
    await tester.pump();
    expect(h.controller.isMuted, isTrue);

    await h.controller.endCall();
    await h.ws.close();
  });

  testWidgets('hangup button ends the call', (tester) async {
    final h = Harness();
    await h.controller.initiateCall(
      threadId: 't1',
      callee: const CallParticipant(userId: '42', name: 'Bob'),
    );
    await tester.pumpWidget(_wrap(h.controller));
    await tester.pump();

    await tester.tap(find.byKey(const Key('call_hangup_btn')));
    await tester.pump();
    expect(h.apiCalls, contains('end:call-1'));
    await h.ws.close();
  });
}
