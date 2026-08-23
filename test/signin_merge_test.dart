import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:serbisyohubph/app_state.dart';
import 'package:serbisyohubph/pages/signin/signin_widget.dart';

void main() {
  group('merged sign-in welcome header', () {
    testWidgets('renders welcome artwork and SerbisyoHub headline',
        (tester) async {
      await tester.pumpWidget(ChangeNotifierProvider<FFAppState>.value(
        value: FFAppState(),
        child: const MaterialApp(home: Scaffold(body: SigninWidget())),
      ));
      await tester.pump();

      expect(find.text('Welcome to SerbisyoHub PH'), findsOneWidget);
      expect(find.text('Sign in to continue with your home services.'),
          findsOneWidget);
      // Compact artwork is present (asset image widget).
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/images/welcome-graphic.png'),
        findsOneWidget,
      );
      // Phone/Email tabs still present.
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });
  });
}
