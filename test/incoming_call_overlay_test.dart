import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/pages/call/incoming_call_overlay.dart';
import 'package:serbisyohubph/services/call/call_controller.dart';

import 'call_controller_test.dart' show Harness;

Widget _wrap(CallController c) => MaterialApp(
      home: ChangeNotifierProvider<CallController>.value(
        value: c,
        child: const Scaffold(body: IncomingCallOverlay()),
      ),
    );

void main() {
  testWidgets('hidden when idle', (tester) async {
    final h = Harness();
    await tester.pumpWidget(_wrap(h.controller));
    expect(find.text('Incoming call'), findsNothing);
    await h.ws.close();
  });

  testWidgets('shows caller and rejects on tap', (tester) async {
    final h = Harness();
    await tester.pumpWidget(_wrap(h.controller));

    h.inbound({
      'type': 'call_initiate',
      'threadId': 't1',
      'targetUserId': '99',
      'callId': 'call-9',
      'callerUserId': '42'
    });
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Caller 42'), findsOneWidget);

    await tester.tap(find.byKey(const Key('call_reject_btn')));
    await tester.pump();
    expect(h.apiCalls, contains('reject:call-9'));
    await h.ws.close();
  });
}
