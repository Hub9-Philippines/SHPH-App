import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/auth/auth_util.dart';
import '/auth/post_auth_navigation_flow.dart'
    show kProviderAppStoreUrl;
import '/backend/supabase/supabase.dart';
import '/components/content_container.dart';
import '/components/refreshable_page.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/components/tinted_menu_tile.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/services/auth_service.dart';
import '/services/client_kyc_service.dart';
import '/api/models/address.dart';
import '/services/addresses_service.dart';
import '/services/profiles_service.dart';
import '/theme/app_theme.dart';
import 'profile_model.dart';

export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'Profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with RefreshablePage<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _providerSwitch = false;
  bool _isUploading = false;

  late Future<ProfilesRow?> _profileFuture;
  late Future<({String status, bool skipped})> _kycStatusFuture;
  late Future<List<ShphAddress>> _addressesFuture;

  // Royal-blue hero gradient — merges the previous card look with the
  // current brand primary.
  static const List<Color> _heroGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF274FB5),
    Color(0xFF3B62D9),
  ];

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProfileModel.new);
    _profileFuture = ProfilesService.instance.getProfile();
    _kycStatusFuture = ClientKycService().status();
    _addressesFuture = AddressesService.instance.getAddresses();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Future<void> onRefresh() async {
    _reloadData();
  }

  /// Re-fetch profile + KYC status after returning from a pushed workflow
  /// (e.g. Edit Profile, KYC) so the hero and readiness section stay fresh.
  void _reloadData() {
    safeSetState(() {
      _profileFuture = ProfilesService.instance.getProfile();
      _kycStatusFuture = ClientKycService().status();
      _addressesFuture = AddressesService.instance.getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Strict light theme for this screen.
    return Theme(
      data: AppTheme.lightTheme(),
      child: FutureBuilder<ProfilesRow?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      ProfileHeaderSkeleton(),
                      ProfileMenuItemSkeleton(),
                      ProfileMenuItemSkeleton(),
                      ProfileMenuItemSkeleton(),
                      ProfileMenuItemSkeleton(),
                      ProfileMenuItemSkeleton(),
                    ],
                  ),
                ),
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(child: Text(_l10n.pfNotFound)),
              ),
            );
          }

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              body: SafeArea(
                child: wrapWithRefresh(
                  slivers: [
                    SliverToBoxAdapter(
                        child: ContentContainer(
                          variant: ContentVariant.wide,
                          padded: true,
                          center: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppThemeData.spaceLg),
                              _buildHeroCard(profile),
                              const SizedBox(height: 24),
                              _buildVerificationSection(profile),
                              const SizedBox(height: 24),
                              _buildGroup(
                                label: _l10n.pfAccountGroup,
                                tiles: [
                                  _tile(
                                    context,
                                    icon: Icons.calendar_month_rounded,
                                    tint: AppThemeData.accentNavy,
                                    title: _l10n.pfMyBookings,
                                    subtitle: _l10n.pfMyBookingsSub,
                                    onTap: () => context
                                        .pushNamed(BookingsWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.receipt_long_rounded,
                                    tint: AppThemeData.accentSky,
                                    title: _l10n.pfPaymentInvoices,
                                    subtitle: _l10n.pfPaymentInvoicesSub,
                                    onTap: () => context.pushNamed(
                                        PaymentMethodsWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.translate_rounded,
                                    tint: AppThemeData.accentPurple,
                                    title: _l10n.pfLanguage,
                                    subtitle: 'English, Filipino',
                                    onTap: () => context.pushNamed(
                                        LanguageSettingsWidget.routeName),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildGroup(
                                label: _l10n.pfPrefsGroup,
                                tiles: [
                                  _tile(
                                    context,
                                    icon: Icons.favorite_rounded,
                                    tint: AppThemeData.accentPink,
                                    title: _l10n.pfFavorites,
                                    subtitle: _l10n.pfFavoritesSub,
                                    onTap: () => context
                                        .pushNamed(FavoritesWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.star_rounded,
                                    tint: AppThemeData.accentOrange,
                                    title: _l10n.pfMyReviews,
                                    subtitle: _l10n.pfMyReviewsSub,
                                    onTap: () => context
                                        .pushNamed(MyReviewsWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.card_giftcard_rounded,
                                    tint: AppThemeData.accentIndigo,
                                    title: _l10n.pfReferral,
                                    subtitle: _l10n.pfReferralSub,
                                    onTap: _showReferralSheet,
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.notifications_active_rounded,
                                    tint: AppThemeData.accentYellow,
                                    title: _l10n.pfNotificationSettings,
                                    subtitle: _l10n.pfNotificationSettingsSub,
                                    onTap: () => context.pushNamed(
                                        MyNotificationsWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.help_outline_rounded,
                                    tint: AppThemeData.accentBlue,
                                    title: _l10n.pfHelpCenter,
                                    subtitle: _l10n.pfHelpCenterSub,
                                    onTap: () =>
                                        context.pushNamed(HelpPage.routeName),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildGroup(
                                label: _l10n.pfSystemAccessGroup,
                                tiles: [
                                  _tile(
                                    context,
                                    icon: Icons.shield_rounded,
                                    tint: AppThemeData.accentNavy,
                                    title: _l10n.seSecurity,
                                    subtitle: _l10n.pfSecuritySub,
                                    onTap: () => context.pushNamed(
                                        SecuritySettingsWidget.routeName),
                                  ),
                                  _providerSwitchTile(context),
                                  _tile(
                                    context,
                                    icon: Icons.logout_rounded,
                                    tint: AppThemeData.destructiveCrimson,
                                    title: _l10n.logOut,
                                    subtitle: _l10n.pfLogOutSub,
                                    titleColor:
                                        AppThemeData.destructiveCrimson,
                                    onTap: _handleLogout,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // Hero card — previous design language on the royal-blue brand gradient
  // -------------------------------------------------------------------
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeroCard(ProfilesRow profile) {
    final displayName =
        valueOrDefault<String>(profile.displayName, 'Rims Client');
    final hasFullName = (profile.firstName ?? '').trim().isNotEmpty &&
        (profile.lastName ?? '').trim().isNotEmpty;
    final hasDisplayName = (profile.displayName ?? '').trim().isNotEmpty &&
        profile.displayName != 'Rims Client' &&
        profile.displayName != 'Serbisyo User';
    final isComplete = profile.isProfileComplete == true ||
        hasFullName ||
        hasDisplayName ||
        AuthService.instance.isProfileComplete;
    final needsCompletion = !isComplete;
    final email = valueOrDefault<String>(profile.email, currentUserEmail);
    final phone = valueOrDefault<String>(
      profile.phoneNumber,
      FFAppState().phone,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _heroGradient,
        ),
        borderRadius: BorderRadius.circular(AppThemeData.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E1E3A8A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Crisp circular photo with a subtle ring + camera affordance.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: (profile.faceScanUrl ?? '')
                              .trim()
                              .isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: profile.faceScanUrl!.trim(),
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              errorWidget: (_, __, ___) =>
                                  _buildAvatarPlaceholder(),
                            )
                          : _buildAvatarPlaceholder(),
                    ),
                  ),
                  // Add / edit photo affordance.
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: Colors.black26,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isUploading
                            ? null
                            : _showAvatarSourceSheet,
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: _isUploading
                              ? Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                )
                              : Icon(
                                  Icons.photo_camera_rounded,
                                  size: 15,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppThemeData.spaceLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large bold username with inline verification badge —
                    // high contrast on the gradient.
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTheme.of(context).headlineSmall.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                      ),
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _VerificationBadge(
                          isVerified: profile.isVerified == true ||
                              (profile.verificationStatus ?? '')
                                      .toLowerCase() ==
                                  'verified',
                        ),
                      ],
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        phone,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                      ),
                    ],
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // Brighter than the old muted gray — readable on
                        // the gradient.
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Two-state action pills: incomplete → complete CTA.
                    // Verification lives in its own account-readiness
                    // section below; Edit Profile stays reachable always.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (needsCompletion)
                          _CompleteProfilePill(
                            onTap: () => context.pushNamed(
                                CreateProfileWidget.routeName),
                          ),
                        _EditPill(
                          onTap: () async {
                            await context.pushNamed(
                                EditProfileWidget.routeName);
                            if (mounted) _reloadData();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Saved places — tappable rectangle that opens the addresses page.
          FutureBuilder<List<ShphAddress>>(
            future: _addressesFuture,
            builder: (context, addressSnapshot) {
              final addresses = addressSnapshot.data ?? [];
              final defaultAddress = addresses.where((a) => a.isDefault).isNotEmpty
                  ? addresses.firstWhere((a) => a.isDefault)
                  : null;
              final hasDefaultAddress = defaultAddress != null;
              final defaultName = defaultAddress?.label?.isNotEmpty == true
                  ? defaultAddress!.label
                  : defaultAddress?.street ?? '';

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
                  onTap: () => context.pushNamed(AddressesWidget.routeName),
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pin_drop_outlined,
                          color: Colors.white.withValues(alpha: 0.92),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _l10n.pfSavedPlaces,
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: Colors.white,
                                    ),
                              ),
                              if (hasDefaultAddress && defaultName != null && defaultName!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 12,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        defaultName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.plusJakartaSans(),
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!hasDefaultAddress) ...[
                          Text(
                            _l10n.pfAdd,
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.92),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ],
        ),
      ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Account readiness — KYC verification tile (web ProfilePage parity:
  // hidden once verified, "Not started" / "In progress" / "Action required"
  // otherwise, with a Verify CTA for actionable states).
  // -------------------------------------------------------------------
  Widget _buildVerificationSection(ProfilesRow profile) {
    final theme = AppTheme.of(context);
    final rowVerified = profile.isVerified == true ||
        (profile.verificationStatus ?? '').toLowerCase() == 'verified';

    return FutureBuilder<({String status, bool skipped})>(
      future: _kycStatusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final status = snapshot.data?.status ?? 'not_submitted';
        final approved = rowVerified || status == 'approved';
        if (approved) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context)!;
        final String label;
        final Color badgeText;
        final Color badgeBg;
        final IconData icon;
        final bool showCta;
        switch (status) {
          case 'rejected':
            label = l10n.verificationActionRequired;
            badgeText = AppThemeData.destructiveCrimson;
            badgeBg = AppThemeData.statusCancelledBg;
            icon = Icons.gpp_bad_rounded;
            showCta = true;
          case 'pending':
            label = l10n.verificationInProgress;
            badgeText = AppThemeData.statusPending;
            badgeBg = AppThemeData.statusPendingBg;
            icon = Icons.hourglass_top_rounded;
            showCta = false;
          default:
            label = l10n.verificationNotStarted;
            badgeText = theme.primary;
            badgeBg = theme.primary.withValues(alpha: 0.10);
            icon = Icons.gpp_maybe_rounded;
            showCta = true;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                _l10n.pfVerificationGroup,
                style: theme.labelMedium.override(
                  font:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  letterSpacing: 0.6,
                  color: theme.secondaryText,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
                border: Border.all(color: theme.border),
                boxShadow: AppThemeData.shadowSoft,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: badgeText.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, size: 22, color: badgeText),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.kycVerification,
                                style: theme.titleSmall.override(
                                  font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700),
                                  color: theme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodySmall.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius:
                                BorderRadius.circular(AppThemeData.radiusPill),
                          ),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.labelSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700),
                              color: badgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showCta) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: InkWell(
                        onTap: () async {
                          await context
                              .pushNamed(KycOnboardingWidget.routeName);
                          if (mounted) _reloadData();
                        },
                        borderRadius:
                            BorderRadius.circular(AppThemeData.radiusLg),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(
                                AppThemeData.radiusLg),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.verifyNow,
                            style: theme.labelMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700),
                              color: theme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroup({
    required String label,
    required List<Widget> tiles,
  }) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: theme.labelMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              letterSpacing: 0.6,
              color: theme.secondaryText,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            border: Border.all(color: theme.border),
            boxShadow: AppThemeData.shadowSoft,
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color tint,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) =>
      TintedMenuTile(
        icon: icon,
        tint: tint,
        title: title,
        subtitle: subtitle,
        titleColor: titleColor,
        onTap: onTap,
      );

  Widget _providerSwitchTile(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(Icons.swap_horiz_rounded, size: 22, color: theme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _l10n.pfAreYouProvider,
                  style: theme.titleSmall.override(
                    font:
                        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _l10n.pfSwitchToProvider,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _providerSwitch,
            onChanged: (value) => _handleProviderSwitch(value),
          ),
        ],
      ),
    );
  }

  void _handleProviderSwitch(bool value) {
    if (!value) {
      safeSetState(() => _providerSwitch = false);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storefront_rounded,
                    size: 22, color: AppTheme.of(sheetContext).primary),
                const SizedBox(width: 10),
                Text(
                  _l10n.pfProviderDetected,
                  style: AppTheme.of(sheetContext).titleMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _l10n.pfProviderAppBody,
              style: AppTheme.of(sheetContext).bodyMedium.override(
                    color: AppTheme.of(sheetContext).secondaryText,
                  ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  launchUrl(
                    Uri.parse(kProviderAppStoreUrl),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(_l10n.pfOpenProviderAppStore),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) safeSetState(() => _providerSwitch = false);
    });
  }

  void _showReferralSheet() {
    const inviteUrl = 'https://serbisyohubph.com/invite';
    Clipboard.setData(const ClipboardData(text: inviteUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_l10n.pfInviteCopied),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(XFile file) async {
    if (!mounted) return;
    safeSetState(() => _isUploading = true);

    // Blocking progress dialog so the user can't double-tap.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 14),
                Text(_l10n.pfUploadingPhoto),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.')
          ? file.name.split('.').last.toLowerCase()
          : 'jpg';
      final name =
          'profile_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final url = await ProfilesService.instance
          .uploadProfilePhoto(bytes, name);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close dialog

      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.pfUploadFailed)),
        );
        return;
      }

      await ProfilesService.instance.updateProfile({
        'face_scan_url': url,
      });
      if (mounted) {
        safeSetState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.pfPhotoUpdated)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.pfUploadError(e))),
      );
    } finally {
      if (mounted) safeSetState(() => _isUploading = false);
    }
  }

  void _showAvatarSourceSheet() {
    final picker = ImagePicker();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(_l10n.pfChooseGallery),
              onTap: () async {
                Navigator.pop(sheetContext);
                final file = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (file != null) await _pickAndUploadPhoto(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(_l10n.pfTakePhoto),
              onTap: () async {
                Navigator.pop(sheetContext);
                final file = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (file != null) await _pickAndUploadPhoto(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) => AlertDialog(
            title: Text(_l10n.logOutTitle),
            content: Text(
              _l10n.logOutConfirm,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext, false),
                child: Text(_l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext, true),
                child: Text(_l10n.logOutAction),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm || !mounted) return;

    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    if (!mounted) return;
    GoRouter.of(context).clearRedirectLocation();
    context.goNamedAuth(SplashWidget.routeName, context.mounted);
  }
}

class _CompleteProfilePill extends StatelessWidget {
  const _CompleteProfilePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 5),
            Text(
              AppLocalizations.of(context)!.completeYourProfile,
              style: theme.textTheme.labelSmall?.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditPill extends StatelessWidget {
  const _EditPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.65),
            width: 1.3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_rounded,
                size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              _l10n.seEditProfile,
              style: theme.textTheme.labelSmall?.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        isVerified ? Icons.verified_rounded : Icons.gpp_maybe_rounded,
        size: 17,
        color:
            isVerified ? theme.colorScheme.primary : AppThemeData.accentYellow,
      ),
    );
  }
}
