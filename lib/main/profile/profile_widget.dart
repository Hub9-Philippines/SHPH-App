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
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/components/tinted_menu_tile.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
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

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _providerSwitch = false;
  bool _isUploading = false;

  // Royal-blue hero gradient — merges the previous card look with the
  // current brand primary.
  static const List<Color> _heroGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF274FB5),
    Color(0xFF3B62D9),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProfileModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Strict light theme for this screen.
    return Theme(
      data: AppTheme.lightTheme(),
      child: FutureBuilder<ProfilesRow?>(
        future: ProfilesService.instance.getProfile(),
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
              body: const SafeArea(
                child: Center(child: Text('Profile not found')),
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
                child: RefreshIndicator(
                  color: AppTheme.of(context).primary,
                  onRefresh: () async => safeSetState(() {}),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: ContentContainer(
                          variant: ContentVariant.wide,
                          padded: true,
                          center: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroCard(profile),
                              const SizedBox(height: 24),
                              _buildGroup(
                                label: 'ACCOUNT',
                                tiles: [
                                  _tile(
                                    context,
                                    icon: Icons.calendar_month_rounded,
                                    tint: AppThemeData.accentNavy,
                                    title: 'My Bookings',
                                    subtitle: 'View past and upcoming jobs',
                                    onTap: () => context
                                        .pushNamed(BookingsWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.receipt_long_rounded,
                                    tint: AppThemeData.accentSky,
                                    title: 'Payment & Invoices',
                                    subtitle:
                                        'View history and download invoices',
                                    onTap: () => context.pushNamed(
                                        PaymentMethodsWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.translate_rounded,
                                    tint: AppThemeData.accentPurple,
                                    title: 'Language Preference',
                                    subtitle: 'English, Hindi, Marathi, etc.',
                                    onTap: () => context.pushNamed(
                                        LanguageSettingsWidget.routeName),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildGroup(
                                label: 'PREFERENCES & UTILITIES',
                                tiles: [
                                  _tile(
                                    context,
                                    icon: Icons.favorite_rounded,
                                    tint: AppThemeData.accentPink,
                                    title: 'Favorites',
                                    subtitle:
                                        'Jump back into the services you saved',
                                    onTap: () => context
                                        .pushNamed(FavoritesWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.star_rounded,
                                    tint: AppThemeData.accentOrange,
                                    title: 'My Reviews',
                                    subtitle: 'See the feedback you have left',
                                    onTap: () => context
                                        .pushNamed(MyReviewsWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.card_giftcard_rounded,
                                    tint: AppThemeData.accentTeal,
                                    title: 'Referral Program',
                                    subtitle: 'Share and earn rewards',
                                    onTap: _showReferralSheet,
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.notifications_active_rounded,
                                    tint: AppThemeData.accentYellow,
                                    title: 'Notification Settings',
                                    subtitle: 'Control alerts and reminders',
                                    onTap: () => context.pushNamed(
                                        MyNotificationsWidget.routeName),
                                  ),
                                  _tile(
                                    context,
                                    icon: Icons.help_outline_rounded,
                                    tint: AppThemeData.accentBlue,
                                    title: 'Help Center',
                                    subtitle:
                                        'FAQs and chat with our support team',
                                    onTap: () =>
                                        context.pushNamed(HelpPage.routeName),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildGroup(
                                label: 'SYSTEM ACCESS',
                                tiles: [
                                  _tile(
                                    context,
                                    icon: Icons.shield_rounded,
                                    tint: AppThemeData.accentNavy,
                                    title: 'Security',
                                    subtitle:
                                        'Password, login protection, and app security',
                                    onTap: () => context.pushNamed(
                                        SecuritySettingsWidget.routeName),
                                  ),
                                  _providerSwitchTile(context),
                                  _tile(
                                    context,
                                    icon: Icons.logout_rounded,
                                    tint: AppThemeData.destructiveCrimson,
                                    title: 'Log out',
                                    subtitle:
                                        'Sign out of your account on this device',
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
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // Hero card — previous design language on the royal-blue brand gradient
  // -------------------------------------------------------------------
  Widget _buildHeroCard(ProfilesRow profile) {
    final displayName =
        valueOrDefault<String>(profile.displayName, 'Rims Client');
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
                              errorWidget: (_, __, ___) => Image.asset(
                                'assets/images/error_image.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/error_image.png',
                              fit: BoxFit.cover,
                            ),
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
                    // Large bold username — high contrast on the gradient.
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.of(context).headlineSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                            ),
                            color: Colors.white,
                          ),
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
                    // Previous-design outlined pill button.
                    _EditPill(
                      onTap: () =>
                          context.pushNamed(EditProfileWidget.routeName),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Metric footer strip from the previous hero.
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.verified_user_outlined,
                    label: 'Account Status',
                    value: 'Active',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.pin_drop_outlined,
                    label: 'Saved Places',
                    value: FFAppState().hasSelectedLocation ? 'Set' : 'Add',
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
        // Verification badge — top-right of the hero card.
        Positioned(
          top: 14,
          right: 14,
          child: _VerificationBadge(
            isVerified: profile.isVerified == true ||
                (profile.verificationStatus ?? '').toLowerCase() ==
                    'verified',
          ),
        ),
      ],
      ),
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
                  'Are you a service provider?',
                  style: theme.titleSmall.override(
                    font:
                        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Switch to Provider Account',
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
                  'Provider account detected',
                  style: AppTheme.of(sheetContext).titleMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Service providers use the dedicated SerbisyoHub PH Provider '
              'app. Open the store to install it, then sign in with the same '
              'account.',
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
                label: const Text('Open Provider App Store'),
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
      const SnackBar(
        content: Text('Invite link copied — share it to earn rewards!'),
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
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 14),
                Text('Uploading photo…'),
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
          const SnackBar(
              content: Text('Could not upload photo. Please try again.')),
        );
        return;
      }

      await ProfilesService.instance.updateProfile({
        'face_scan_url': url,
      });
      if (mounted) {
        safeSetState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
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
              title: const Text('Choose from gallery'),
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
              title: const Text('Take a photo'),
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
            title: const Text('Logout confirmation'),
            content: const Text(
              'Are you sure you want to log out of your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext, true),
                child: const Text('Logout'),
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

class _EditPill extends StatelessWidget {
  const _EditPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              'Edit Profile',
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

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.92), size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
        ],
      );
}
class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified
                ? Icons.verified_rounded
                : Icons.gpp_maybe_rounded,
            size: 15,
            color:
                isVerified ? theme.colorScheme.primary : AppThemeData.accentYellow,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: theme.textTheme.labelSmall?.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              color: theme.textTheme.labelSmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
