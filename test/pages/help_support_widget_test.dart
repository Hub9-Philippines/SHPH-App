import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/pages/help_support/help_support_widget.dart';

void main() {
  testWidgets('ClientHelpSupportWidget renders title and FAQs', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ClientHelpSupportWidget(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Need help?'), findsOneWidget);
    expect(find.text('How do I book a service?'), findsOneWidget);
    expect(find.text('support@serbisyohubph.com'), findsOneWidget);
  });
}
