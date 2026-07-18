import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/pages/chat_page/chat_page_widget.dart';
import 'package:serbisyohubph/services/call/call_controller.dart';
import 'package:serbisyohubph/services/call/call_peer.dart';

import 'call_controller_test.dart' show Harness;

void main() {
  testWidgets('tapping the call button initiates a call to the resolved callee',
      (tester) async {
    final h = Harness();
    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<CallController>.value(
        value: h.controller,
        child: Scaffold(
          appBar: AppBar(actions: [
            ChatCallButton(
              threadId: 't1',
              resolveCallee: () async =>
                  const CallParticipant(userId: '42', name: 'Bob'),
            ),
          ]),
        ),
      ),
    ));

    await tester.tap(find.byKey(const Key('chat_call_btn')));
    await tester.pump();
    await tester.pump();

    expect(h.controller.status, CallStatus.outgoing);
    expect(h.controller.participant?.userId, '42');
    await h.controller.endCall();
    await h.ws.close();
  });

  testWidgets(
      'tapping the call button when resolveCallee throws does not start a call',
      (tester) async {
    final h = Harness();
    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<CallController>.value(
        value: h.controller,
        child: Scaffold(
          appBar: AppBar(actions: [
            ChatCallButton(
              threadId: 't1',
              resolveCallee: () async => throw Exception('boom'),
            ),
          ]),
        ),
      ),
    ));

    await tester.tap(find.byKey(const Key('chat_call_btn')));
    await tester.pump();
    await tester.pump();

    // Call must NOT have started — status stays idle.
    expect(h.controller.status, CallStatus.idle);
    await h.ws.close();
  });
}
