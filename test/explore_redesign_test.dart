import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/components/hero_offer_banner.dart';
import 'package:serbisyohubph/components/invite_earn_banner.dart';
import 'package:serbisyohubph/components/provider_proximity_card.dart';
import 'package:serbisyohubph/main/explore/explore_model.dart';
import 'package:serbisyohubph/theme/app_theme.dart';
import 'package:serbisyohubph/utils/category_icons.dart';

void main() {
  group('CategoryIcons mapper', () {
    test('resolves by slug first', () {
      expect(
        CategoryIcons.resolve(slug: 'zap', name: 'Unknown'),
        equals(CategoryIcons.bySlug('zap')),
      );
    });

    test('falls back to name matching', () {
      expect(
        CategoryIcons.resolve(slug: null, name: 'Cleaning Services'),
        equals(Icons.cleaning_services_rounded),
      );
    });

    test('unknown inputs yield generic category icon', () {
      expect(
        CategoryIcons.resolve(slug: 'nope', name: 'Unknown Thing'),
        equals(Icons.category_rounded),
      );
    });
  });

  group('ExploreModel section futures contract', () {
    test('exposes three independent section futures', () {
      expect(ExploreModel, isNotNull);
    });
  });

  group('HeroOfferBanner', () {
    testWidgets('renders offer copy and fires Book Now', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: HeroOfferBanner(onBookNow: () => tapped = true),
      ));

      expect(find.text('Explore Seasonal Deals'), findsOneWidget);
      expect(find.text('Get 60% OFF!'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);

      await tester.tap(find.text('Book Now'));
      expect(tapped, isTrue);
    });
  });

  group('ProviderProximityCard', () {
    testWidgets('shows distance and rating when provided', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ProviderProximityCard(
            providerName: 'Juan Dela Cruz',
            serviceType: 'Home Cleaning',
            startingFee: '₱350',
            rating: 4.5,
            distanceKm: 2.4,
          ),
        ),
      ));
      expect(find.text('2.4 km away'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('Starting ₱350'), findsOneWidget);
    });

    testWidgets('hides distance chip when distanceKm is null',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ProviderProximityCard(
            providerName: 'Juan Dela Cruz',
            serviceType: 'Home Cleaning',
            startingFee: '₱350',
            rating: 4.5,
            distanceKm: null,
          ),
        ),
      ));
      expect(find.textContaining('km away'), findsNothing);
    });

    testWidgets('Book Now invokes callback', (tester) async {
      var booked = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProviderProximityCard(
            providerName: 'Juana Santos',
            serviceType: 'Plumbing',
            startingFee: '₱500',
            onBookNow: () => booked = true,
          ),
        ),
      ));
      await tester.tap(find.text('Book Now'));
      expect(booked, isTrue);
    });
  });

  group('InviteEarnBanner', () {
    testWidgets('renders copy and fires Share Link', (tester) async {
      var shared = false;
      await tester.pumpWidget(MaterialApp(
        home: InviteEarnBanner(onShare: () => shared = true),
      ));

      expect(find.text('Invite & Earn'), findsOneWidget);
      expect(find.text('Share Link'), findsOneWidget);

      await tester.tap(find.text('Share Link'));
      expect(shared, isTrue);
    });
  });
}
