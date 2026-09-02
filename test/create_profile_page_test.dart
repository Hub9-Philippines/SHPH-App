import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/backend/supabase/database/tables/profiles.dart';
import 'package:serbisyohubph/components/cupertino_ui/app_button.dart';
import 'package:serbisyohubph/l10n/app_localizations.dart';
import 'package:serbisyohubph/pages/create_profile/create_profile_widget.dart';
import 'package:serbisyohubph/services/profiles_service.dart';

/// A 1x1 transparent PNG so the avatar preview decodes cleanly in tests.
final _pixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

class _FakeProfilesService extends ProfilesService {
  _FakeProfilesService({this.prefill});

  final ProfilesRow? prefill;
  bool uploaded = false;
  Map<String, dynamic>? lastUpdate;
  double? progressSeen;

  @override
  Future<ProfilesRow?> getProfile() async => prefill;

  @override
  Future<String?> uploadProfilePhoto(
    List<int> bytes,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    uploaded = true;
    progressSeen = 0.5;
    onProgress?.call(progressSeen!);
    return 'https://cdn.example.com/avatar.jpg';
  }

  @override
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    lastUpdate = data;
    return true;
  }
}

AppButton _button(WidgetTester tester, String label) =>
    tester.widget<AppButton>(
      find.ancestor(of: find.text(label), matching: find.byType(AppButton)),
    );

Future<void> _pump(
  WidgetTester tester,
  CreateProfileWidget widget,
) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: widget,
  ));
  await tester.pump();
  await tester.pump();
}

void main() {
  group('CreateProfileWidget completion page', () {
    testWidgets('prefills first and last name from the profile',
        (tester) async {
      final fake = _FakeProfilesService(
        prefill: ProfilesRow({
          'id': '1',
          'role': 'client',
          'display_name': 'Juan Dela Cruz',
          'is_profile_complete': false,
        }),
      );

      await _pump(
        tester,
        CreateProfileWidget(
          profilesService: fake,
          onGoHome: (_) {},
        ),
      );

      expect(find.text('Juan'), findsOneWidget);
      expect(find.text('Dela Cruz'), findsOneWidget);
      expect(find.text('100% complete'), findsOneWidget);
      expect(find.text('Complete your profile'), findsOneWidget);
    });

    testWidgets('Finish is gated on both names and progress tracks them',
        (tester) async {
      final fake = _FakeProfilesService(
        prefill: ProfilesRow({
          'id': '1',
          'role': 'client',
          'is_profile_complete': false,
        }),
      );

      await _pump(
        tester,
        CreateProfileWidget(
          profilesService: fake,
          onGoHome: (_) {},
        ),
      );

      expect(find.text('0% complete'), findsOneWidget);
      expect(_button(tester, 'Finish').onPressed, isNull);

      await tester.enterText(find.byType(CupertinoTextField).first, 'Maria');
      await tester.pump();
      expect(find.text('50% complete'), findsOneWidget);
      expect(_button(tester, 'Finish').onPressed, isNull);

      await tester.enterText(find.byType(CupertinoTextField).at(1), 'Santos');
      await tester.pump();
      expect(find.text('100% complete'), findsOneWidget);
      expect(_button(tester, 'Finish').onPressed, isNotNull);
    });

    testWidgets(
        'Finish uploads avatar and submits web-parity payload with computed'
        ' display name', (tester) async {
      var navigated = false;
      final fake = _FakeProfilesService(
        prefill: ProfilesRow({
          'id': '1',
          'role': 'client',
          'is_profile_complete': false,
        }),
      );

      await _pump(
        tester,
        CreateProfileWidget(
          profilesService: fake,
          pickImage: () async => (bytes: _pixelPng, name: 'me.png'),
          onGoHome: (_) => navigated = true,
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField).first, 'Maria');
      await tester.enterText(find.byType(CupertinoTextField).at(1), 'Santos');
      await tester.pump();

      await tester.tap(find.text('Add Photo'));
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);

      await tester.ensureVisible(find.text('Finish'));
      await tester.pump();
      await tester.tap(find.text('Finish'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(fake.uploaded, isTrue);
      expect(fake.progressSeen, 0.5);
      expect(fake.lastUpdate, isNotNull);
      expect(fake.lastUpdate!['first_name'], 'Maria');
      expect(fake.lastUpdate!['last_name'], 'Santos');
      expect(fake.lastUpdate!['display_name'], 'Maria Santos');
      expect(fake.lastUpdate!['is_profile_complete'], isTrue);
      expect(
        fake.lastUpdate!['photo_url'],
        'https://cdn.example.com/avatar.jpg',
      );
      expect(navigated, isTrue);
    });

    testWidgets('Skip navigates home without marking the profile complete',
        (tester) async {
      var navigated = false;
      final fake = _FakeProfilesService();

      await _pump(
        tester,
        CreateProfileWidget(
          profilesService: fake,
          onGoHome: (_) => navigated = true,
        ),
      );

      await tester.ensureVisible(find.text('Skip for now'));
      await tester.pump();
      await tester.tap(find.text('Skip for now'));
      await tester.pump();

      expect(navigated, isTrue);
      expect(fake.uploaded, isFalse);
      expect(fake.lastUpdate, isNull);
    });
  });
}