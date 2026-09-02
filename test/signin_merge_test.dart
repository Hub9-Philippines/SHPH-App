import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:serbisyohubph/app_state.dart';
import 'package:serbisyohubph/pages/signin/signin_widget.dart';

void main() {
  group('merged sign-in welcome header', () {
    testWidgets('renders welcome headline and sign-in tabs',
        (tester) async {
      await tester.pumpWidget(ChangeNotifierProvider<FFAppState>.value(
        value: FFAppState(),
        child: const MaterialApp(home: Scaffold(body: SigninWidget())),
      ));
      await tester.pump();

      expect(find.text('Welcome to Serbisyo'), findsOneWidget);
      expect(find.text('Sign in to continue with your home services.'),
          findsOneWidget);
      // Phone/Email tabs still present.
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });
  });
}
