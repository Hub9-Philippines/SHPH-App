import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/network_status_service.dart';
import 'package:serbisyohubph/services/session_timeout_service.dart';
import 'package:serbisyohubph/widgets/app_guardrail_scope.dart';

void main() {
  testWidgets('shows and clears the offline banner', (tester) async {
    var online = false;
    final network = NetworkStatusService(
      probe: () async => online,
      interval: const Duration(hours: 1),
    );
    final session = SessionTimeoutService();
    addTearDown(network.dispose);
    addTearDown(session.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AppGuardrailScope(
          authenticated: false,
          networkStatusService: network,
          sessionTimeoutService: session,
          onSessionTimeout: () async {},
          child: const Scaffold(body: Text('Content')),
        ),
      ),
    );
    await tester.runAsync(network.checkConnection);
    await tester.pump();

    expect(find.textContaining('No connection to SerbisyoHub'), findsOneWidget);

    online = true;
    await tester.runAsync(network.checkConnection);
    await tester.pump();

    expect(find.textContaining('No connection to SerbisyoHub'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('invokes the timeout callback only when authenticated',
      (tester) async {
    var timeoutCalls = 0;
    final network = NetworkStatusService(
      probe: () async => true,
      interval: const Duration(hours: 1),
    );
    final session = SessionTimeoutService(
      inactiveTimeout: const Duration(milliseconds: 60),
      warningBefore: const Duration(milliseconds: 30),
    );
    addTearDown(network.dispose);
    addTearDown(session.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AppGuardrailScope(
          authenticated: true,
          networkStatusService: network,
          sessionTimeoutService: session,
          onSessionTimeout: () async => timeoutCalls++,
          child: const Scaffold(body: Text('Content')),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 35));
    expect(find.textContaining('session will expire'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 35));
    expect(timeoutCalls, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('pointer activity resets the authenticated timeout',
      (tester) async {
    var timeoutCalls = 0;
    final network = NetworkStatusService(
      probe: () async => true,
      interval: const Duration(hours: 1),
    );
    final session = SessionTimeoutService(
      inactiveTimeout: const Duration(milliseconds: 80),
      warningBefore: const Duration(milliseconds: 20),
    );
    addTearDown(network.dispose);
    addTearDown(session.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AppGuardrailScope(
          authenticated: true,
          networkStatusService: network,
          sessionTimeoutService: session,
          onSessionTimeout: () async => timeoutCalls++,
          child: const Scaffold(
              body: TextButton(onPressed: null, child: Text('Tap'))),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 45));
    await tester.tap(find.text('Tap'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 45));

    expect(timeoutCalls, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
