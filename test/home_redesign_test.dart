import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/app_state.dart';
import 'package:serbisyohubph/main/home/home_redesign_widget.dart';

void main() {
  testWidgets('home hides empty bookings and keeps trending above help',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FFAppState>.value(
        value: FFAppState(),
        child: const MaterialApp(home: HomeRedesignWidget()),
      ),
    );
    await tester.pump();

    expect(find.text('YOUR BOOKINGS'), findsNothing);
    expect(find.text('Trending near you'), findsOneWidget);
    expect(find.text('Need help right now?'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Trending near you')).dy,
      lessThan(tester.getTopLeft(find.text('Need help right now?')).dy),
    );
  });

  testWidgets('home profile button opens a dismissible bottom sheet',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FFAppState>.value(
        value: FFAppState(),
        child: const MaterialApp(home: HomeRedesignWidget()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pump();

    expect(find.text('Manage addresses'), findsOneWidget);
    expect(find.text('Help & support'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);

    await tester.tapAt(const Offset(1, 1));
    await tester.pumpAndSettle();

    expect(find.text('Manage addresses'), findsNothing);
  });
}
