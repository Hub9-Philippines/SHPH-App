import '/services/auth_service.dart';
import '/services/kyc_hub_service.dart';

/// Shared provider verification logic — port of web `useProviderVerification`
/// (`E:\Dev\shph-web\src\composables\useProviderVerification.ts`).
///
/// Used by both `PostAuthNavigationFlow` and the router redirect guard so the
/// provider lifecycle is decided in exactly one place:
///
///   no display_name                     → incomplete_profile → /createProfile
///   kyc not_submitted && !kyc_skipped   → kyc_required      → /eKYCBegin
///   kyc not_submitted && kyc_skipped    → kyc_skipped       → /pro-dashboard
///   kyc rejected                        → kyc_required      → /eKYCBegin
///   kyc pending                         → kyc_pending       → /pro-verification-progress
///   kyc approved                        → verified          → /pro-dashboard
class ProviderVerificationService {
  ProviderVerificationService._();
  static final ProviderVerificationService instance =
      ProviderVerificationService._();

  bool hasProfileName([Map<String, dynamic>? user]) {
    final u = user ?? AuthService.instance.currentUser;
    if (u == null) return false;
    final displayName = u['display_name'];
    return displayName is String && displayName.trim().isNotEmpty;
  }

  /// Ensure KYC status is loaded (60s TTL handled inside [KycHubService]).
  /// Silently tolerates API failures so verification never blocks navigation.
  Future<void> ensureKycStatus() async {
    await KycHubService.instance.getStatus();
  }

  /// Web vocabulary state for the given user (defaults to the session user).
  /// Does NOT fetch KYC status — call [ensureKycStatus] first when needed.
  String getVerificationState([Map<String, dynamic>? user]) {
    final u = user ?? AuthService.instance.currentUser;
    if (!hasProfileName(u)) return 'incomplete_profile';

    final kycStatus = KycHubService.instance.statusValue;
    if (kycStatus == 'not_submitted') {
      // Honor a deliberate "I'll do this later" skip (server-persisted). A
      // rejection is NOT skippable — the provider already engaged and failed.
      final kycSkipped = u?['kyc_skipped'] == true;
      return kycSkipped ? 'kyc_skipped' : 'kyc_required';
    }
    if (kycStatus == 'rejected') return 'kyc_required';
    if (kycStatus == 'pending') return 'kyc_pending';
    return 'verified';
  }

  /// Full check — ensures KYC status is loaded, then returns the redirect path.
  Future<String> resolveProviderRedirect([Map<String, dynamic>? user]) async {
    if (!hasProfileName(user)) return '/createProfile';
    await ensureKycStatus();
    switch (getVerificationState(user)) {
      case 'incomplete_profile':
        return '/createProfile';
      case 'kyc_required':
        return '/eKYCBegin';
      case 'kyc_skipped':
        return '/pro-dashboard';
      case 'kyc_pending':
        return '/pro-verification-progress';
      case 'verified':
        return '/pro-dashboard';
    }
    return '/pro-dashboard';
  }
}
