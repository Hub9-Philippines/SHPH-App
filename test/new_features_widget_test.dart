import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/index.dart';

Widget _wrapPage(Widget page) => MaterialApp(
      home: ScaffoldMessenger(child: page),
    );

void main() {
  group('Rooms pages', () {
    testWidgets('RoomListPage renders with app bar and FAB', (tester) async {
      await tester.pumpWidget(_wrapPage(const RoomListPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(RoomListPage.routeName, 'RoomList');
      expect(RoomListPage.routePath, '/rooms');
    });

    testWidgets('RoomCreatePage renders with form fields', (tester) async {
      await tester.pumpWidget(_wrapPage(const RoomCreatePage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(RoomCreatePage.routeName, 'RoomCreate');
      expect(RoomCreatePage.routePath, '/rooms/new');
    });

    testWidgets('RoomJoinPage renders with text field', (tester) async {
      await tester.pumpWidget(_wrapPage(const RoomJoinPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(RoomJoinPage.routeName, 'RoomJoin');
      expect(RoomJoinPage.routePath, '/rooms/join');
    });

    testWidgets('RoomDetailPage renders with roomId param', (tester) async {
      await tester.pumpWidget(_wrapPage(const RoomDetailPage(roomId: '1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(RoomDetailPage.routeName, 'RoomDetail');
      expect(RoomDetailPage.routePath, '/rooms/detail/:roomId');
    });
  });

  group('Provider Suite pages', () {
    testWidgets('ProviderDashboardPage renders with app bar', (tester) async {
      await tester.pumpWidget(_wrapPage(const ProviderDashboardPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(ProviderDashboardPage.routeName, 'ProviderDashboard');
      expect(ProviderDashboardPage.routePath, '/provider-dashboard');
    });

    testWidgets('ProviderHomePage renders with app bar', (tester) async {
      await tester.pumpWidget(_wrapPage(const ProviderHomePage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(ProviderHomePage.routeName, 'ProviderHome');
      expect(ProviderHomePage.routePath, '/provider-home');
    });

    testWidgets('MyServicesPage renders with FAB', (tester) async {
      await tester.pumpWidget(_wrapPage(const MyServicesPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(MyServicesPage.routeName, 'MyServices');
      expect(MyServicesPage.routePath, '/provider/my-services');
    });

    testWidgets('PostServicePage renders with form (create mode)',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const PostServicePage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(PostServicePage.routeName, 'PostService');
      expect(PostServicePage.routePath, '/provider/post-service');
    });

    testWidgets('ProviderAvailabilityPage renders with FAB', (tester) async {
      await tester.pumpWidget(_wrapPage(const ProviderAvailabilityPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(ProviderAvailabilityPage.routeName, 'ProviderAvailability');
      expect(ProviderAvailabilityPage.routePath, '/provider/availability');
    });

    testWidgets('ProviderProfilePage renders with providerId', (tester) async {
      await tester.pumpWidget(
        _wrapPage(const ProviderProfilePage(providerId: 1)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(ProviderProfilePage.routeName, 'ProviderProfile');
      expect(ProviderProfilePage.routePath, '/provider/profile/:providerId');
    });

    testWidgets('ReviewScanPage renders with submit button', (tester) async {
      await tester.pumpWidget(_wrapPage(const ReviewScanPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(ReviewScanPage.routeName, 'ReviewScan');
      expect(ReviewScanPage.routePath, '/provider/review-scan');
    });
  });

  group('Security & Preferences pages', () {
    testWidgets('SessionsPage renders with app bar', (tester) async {
      await tester.pumpWidget(_wrapPage(const SessionsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(SessionsPage.routeName, 'Sessions');
      expect(SessionsPage.routePath, '/sessions');
    });

    testWidgets('BiometricSetupPage renders with app bar', (tester) async {
      await tester.pumpWidget(_wrapPage(const BiometricSetupPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(BiometricSetupPage.routeName, 'BiometricSetup');
      expect(BiometricSetupPage.routePath, '/biometric-setup');
    });

    testWidgets('NotificationPreferencesPage renders with app bar',
        (tester) async {
      await tester.pumpWidget(
        _wrapPage(const NotificationPreferencesPage()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(NotificationPreferencesPage.routeName, 'NotificationPreferences');
      expect(
          NotificationPreferencesPage.routePath, '/notification-preferences');
    });
  });

  group('Discovery & Support pages', () {
    testWidgets('CategoryDetailPage renders with categoryId', (tester) async {
      await tester.pumpWidget(
        _wrapPage(const CategoryDetailPage(categoryId: 1)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(CategoryDetailPage.routeName, 'CategoryDetail');
      expect(CategoryDetailPage.routePath, '/category/:categoryId');
    });

    testWidgets('SubcategoryPage renders with parentId', (tester) async {
      await tester.pumpWidget(
        _wrapPage(const SubcategoryPage(parentId: 1)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(SubcategoryPage.routeName, 'Subcategory');
      expect(SubcategoryPage.routePath, '/subcategory/:parentId');
    });

    testWidgets('EtaTrackingPage renders with token', (tester) async {
      await tester.pumpWidget(
        _wrapPage(const EtaTrackingPage(token: 'test-token')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(EtaTrackingPage.routeName, 'EtaTracking');
      expect(EtaTrackingPage.routePath, '/eta/:token');
    });

    testWidgets('HelpAssistantPage renders with FAQ and ticket form',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const HelpAssistantPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
      expect(HelpAssistantPage.routeName, 'HelpAssistant');
      expect(HelpAssistantPage.routePath, '/help-assistant');
    });
  });
}
