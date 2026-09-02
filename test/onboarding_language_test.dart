import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:serbisyohubph/app_state.dart';
import 'package:serbisyohubph/l10n/app_localizations.dart';
import 'package:serbisyohubph/pages/onboarding/onboarding_widget.dart';

Future<void> _pumpOnboarding(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const OnboardingWidget(),
  ));
  // Let the page-load + post-frame permission microtasks settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await FFAppState().initializePersistedState();
  });

  group('OnboardingWidget language step', () {
    testWidgets('first slide offers exactly English and Filipino',
        (tester) async {
      await _pumpOnboarding(tester);

      expect(find.text('Choose your language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Filipino'), findsOneWidget);
      expect(find.text('Spanish'), findsNothing);
      expect(find.text('French'), findsNothing);
    });

    testWidgets('selecting Filipino applies the locale immediately',
        (tester) async {
      expect(FFAppState().locale, 'en');

      await _pumpOnboarding(tester);

      await tester.tap(find.text('Filipino'));
      await tester.pump();

      expect(FFAppState().locale, 'fil');

      // The persisted value survives re-init (real-time switching storage).
      expect(FFAppState().prefs.getString('ff_locale'), 'fil');
    });

    testWidgets('selecting English keeps the locale as English',
        (tester) async {
      await _pumpOnboarding(tester);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(FFAppState().locale, 'en');
      expect(FFAppState().prefs.getString('ff_locale'), 'en');
    });
  });
}