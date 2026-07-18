import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/index.dart';

Widget _wrapPage(Widget page) => MaterialApp(
      home: ScaffoldMessenger(child: page),
    );

void main() {
  group('Provider Suite pages', () {
    testWidgets('ProviderAnalyticsPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const ProviderAnalyticsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(ProviderAnalyticsPage.routeName, 'ProviderAnalytics');
      expect(ProviderAnalyticsPage.routePath, '/provider-analytics');
    });

    testWidgets('ProviderBidsPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const ProviderBidsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(ProviderBidsPage.routeName, 'ProviderBids');
      expect(ProviderBidsPage.routePath, '/provider-bids');
    });

    testWidgets('EarningsPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const EarningsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(EarningsPage.routeName, 'EarningsPage');
      expect(EarningsPage.routePath, '/earnings-page');
    });

    testWidgets('MyReviewsPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const MyReviewsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(MyReviewsPage.routeName, 'MyReviewsPage');
      expect(MyReviewsPage.routePath, '/my-reviews-page');
    });
  });

  group('Wallet & Payments pages', () {
    testWidgets('WalletPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const WalletPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(WalletPage.routeName, 'Wallet');
      expect(WalletPage.routePath, '/wallet');
    });
  });

  group('Admin Suite pages', () {
    testWidgets('AdminDashboardPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const AdminDashboardPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(AdminDashboardPage.routeName, 'AdminDashboard');
      expect(AdminDashboardPage.routePath, '/admin-dashboard');
    });

    testWidgets('AdminKycQueuePage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const AdminKycQueuePage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(AdminKycQueuePage.routeName, 'AdminKycQueue');
      expect(AdminKycQueuePage.routePath, '/admin-kyc-queue');
    });

    testWidgets('AdminDisputesPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const AdminDisputesPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(AdminDisputesPage.routeName, 'AdminDisputes');
      expect(AdminDisputesPage.routePath, '/admin-disputes');
    });

    testWidgets('AdminPayoutsPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const AdminPayoutsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(AdminPayoutsPage.routeName, 'AdminPayouts');
      expect(AdminPayoutsPage.routePath, '/admin-payouts');
    });

    testWidgets('AdminUsersPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const AdminUsersPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(AdminUsersPage.routeName, 'AdminUsers');
      expect(AdminUsersPage.routePath, '/admin-users');
    });

    testWidgets('AdminAuditLogsPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const AdminAuditLogsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(AdminAuditLogsPage.routeName, 'AdminAuditLogs');
      expect(AdminAuditLogsPage.routePath, '/admin-audit-logs');
    });
  });

  group('Client Gaps pages', () {
    testWidgets('OnDemandJobsPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const OnDemandJobsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(OnDemandJobsPage.routeName, 'OnDemandJobs');
      expect(OnDemandJobsPage.routePath, '/on-demand-jobs');
    });

    testWidgets('RecommendationsPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const RecommendationsPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(RecommendationsPage.routeName, 'Recommendations');
      expect(RecommendationsPage.routePath, '/recommendations');
    });

    testWidgets('DisputesPage renders with app bar and loading state',
        (tester) async {
      await tester.pumpWidget(_wrapPage(const DisputesPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(DisputesPage.routeName, 'DisputesPage');
      expect(DisputesPage.routePath, '/disputes-page');
    });
  });
}
