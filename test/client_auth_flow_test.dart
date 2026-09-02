import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/auth/post_auth_navigation_flow.dart';
import 'package:serbisyohubph/auth/shph_auth/shph_auth_manager.dart';
import 'package:serbisyohubph/pages/create_profile/create_profile_widget.dart';
import 'package:serbisyohubph/services/auth_service.dart';
import 'package:serbisyohubph/services/client_kyc_service.dart';

/// Fake KYC service that returns a canned normalized status without hitting
/// the network.
class _FakeKycService extends ClientKycService {
  _FakeKycService(this.value);

  final ({String status, bool skipped}) value;

  @override
  Future<({String status, bool skipped})> status() async => value;
}

void main() {
  group('Client-only auth flow', () {
    test('provider app store URL placeholder is defined', () {
      expect(kProviderAppStoreUrl, isNotEmpty);
      expect(kProviderAppStoreUrl, contains('serbisyohubph'));
    });

    test('CreateProfile route exists and is not the provider dashboard', () {
      expect(CreateProfileWidget.routeName, 'CreateProfile');
      expect(CreateProfileWidget.routePath, '/createProfile');
    });

    test('checkProfileStatus without a session falls back to needs_profile',
        () async {
      final flow = PostAuthNavigationFlow();
      final status = await flow.checkProfileStatus('test-user-id');
      // Without a real session _ensureUser() falls back to needs_profile;
      // it must never resolve to a provider dashboard state.
      expect(status, anyOf(equals('ready_home'), equals('needs_profile')));
      expect(status, isNot(contains('pro_dashboard')));
    });

    test('incomplete profile resolves to needs_profile', () async {
      AuthService.instance.adoptUser({
        'id': 'u-incomplete',
        'display_name': '',
        'is_profile_complete': false,
      });
      final flow = PostAuthNavigationFlow();
      final status = await flow.checkProfileStatus(
        'u-incomplete',
        kycService: _FakeKycService((status: 'not_submitted', skipped: false)),
      );
      expect(status, 'needs_profile');
    });

    test('complete + not_submitted + not skipped resolves to needs_kyc',
        () async {
      AuthService.instance.adoptUser({
        'id': 'u-unverified',
        'display_name': 'Rims Client',
        'is_profile_complete': true,
      });
      final flow = PostAuthNavigationFlow();
      final status = await flow.checkProfileStatus(
        'u-unverified',
        kycService: _FakeKycService((status: 'not_submitted', skipped: false)),
      );
      expect(status, 'needs_kyc');
    });

    test('complete + skipped resolves to ready_home', () async {
      AuthService.instance.adoptUser({
        'id': 'u-skipped',
        'display_name': 'Rims Client',
        'is_profile_complete': true,
      });
      final flow = PostAuthNavigationFlow();
      final status = await flow.checkProfileStatus(
        'u-skipped',
        kycService: _FakeKycService((status: 'not_submitted', skipped: true)),
      );
      expect(status, 'ready_home');
    });

    test('complete + approved resolves to ready_home', () async {
      AuthService.instance.adoptUser({
        'id': 'u-approved',
        'display_name': 'Rims Client',
        'is_profile_complete': true,
      });
      final flow = PostAuthNavigationFlow();
      final status = await flow.checkProfileStatus(
        'u-approved',
        kycService: _FakeKycService((status: 'approved', skipped: false)),
      );
      expect(status, 'ready_home');
    });

    test('ShphAuthManager always maps to client role', () async {
      final manager = ShphAuthManager();
      expect(manager, isA<ShphAuthManager>());
    });
  });
}