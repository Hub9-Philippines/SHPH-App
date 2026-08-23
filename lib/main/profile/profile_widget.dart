import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/auth/auth_util.dart';
import '/auth/post_auth_navigation_flow.dart'
    show kProviderAppStoreUrl;
import '/backend/supabase/supabase.dart';
import '/components/content_container.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
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

    // Strict light theme: the hub renders identically regardless of any
    // app-level dark preference.
    return Theme(
      data: AppTheme.lightTheme(),
      child: FutureBuilder<ProfilesRow?>(
        future: ProfilesService.instance.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
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
                  ],
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
                  color: Theme.of(context).colorScheme.primary,
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
                              _buildHeaderBlock(profile),
                              const SizedBox(height: 24),
                              _ProfileGroup(
                                label: 'ACCOUNT',
                                children: [
                                  _ProfileRow(
                                    icon: Icons.calendar_month_rounded,
                                    tint: themePrimary(context),
                                    title: 'My Bookings',
                                    subtitle:
                                        'View past and upcoming jobs',
                                    onTap: () => context
                                        .pushNamed(BookingsWidget.routeName),
                                  ),
                                  _divider(),
                                  _ProfileRow(
                                    icon: Icons.receipt_long_rounded,
                                    tint: themePrimary(context),
                                    title: 'Payment & Invoices',
                                    subtitle:
                                        'View history and download invoices',
                                    onTap: () => context.pushNamed(
                                        PaymentMethodsWidget.routeName),
                                  ),
                                  _divider(),
                                  _ProfileRow(
                                    icon: Icons.translate_rounded,
                                    tint: themePrimary(context),
                                    title: 'Language Preference',
                                    subtitle: 'English, Hindi, Marathi, etc.',
                                    onTap: () => context.pushNamed(
                                        LanguageSettingsWidget.routeName),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _ProfileGroup(
                                label: 'PREFERENCES & UTILITIES',
                                children: [
                                  _ProfileRow(
                                    icon: Icons.favorite_rounded,
                                    tint: themePrimary(context),
                                    title: 'Favorites',
                                    subtitle:
                                        'Jump back into the services you saved',
                                    onTap: () => context
                                        .pushNamed(FavoritesWidget.routeName),
                                  ),
                                  _divider(),
                                  _ProfileRow(
                                    icon: Icons.star_rounded,
                                    tint: themePrimary(context),
                                    title: 'My Reviews',
                                    subtitle: 'See the feedback you have left',
                                    onTap: () => context
                                        .pushNamed(MyReviewsWidget.routeName),
                                  ),
                                  _divider(),
                                  _ProfileRow(
                                    icon: Icons.card_giftcard_rounded,
                                    tint: themePrimary(context),
                                    title: 'Referral Program',
                                    subtitle: 'Share and earn rewards',
                                    onTap: _showReferralSheet,
                                  ),
                                  _divider(),
                                  _ProfileRow(
                                    icon: Icons.notifications_active_rounded,
                                    tint: themePrimary(context),
                                    title: 'Notification Settings',
                                    subtitle: 'Control alerts and reminders',
                                    onTap: () => context.pushNamed(
                                        MyNotificationsWidget.routeName),
                                  ),
                                  _divider(),
                                  _ProfileRow(
                                    icon: Icons.help_outline_rounded,
                                    tint: themePrimary(context),
                                    title: 'Help Center',
                                    subtitle:
                                        'FAQs and chat with our support team',
                                    onTap: () =>
                                        context.pushNamed(HelpPage.routeName),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _ProfileGroup(
                                label: 'SYSTEM ACCESS',
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: themePrimary(context)
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.swap_horiz_rounded,
                                            size: 22,
                                            color: themePrimary(context),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Are you a service provider?',
                                                style: AppTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                    ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                'Switch to Provider Account',
                                                style: AppTheme.of(context)
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch.adaptive(
                                          value: _providerSwitch,
                                          onChanged: (value) =>
                                              _handleProviderSwitch(value),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _divider(),
                                  _ProfileRow(
                                    icon: Icons.logout_rounded,
                                    tint: AppThemeData.destructiveCrimson,
                                    title: 'Log out',
                                    titleColor:
                                        AppThemeData.destructiveCrimson,
                                    subtitle:
                                        'Sign out of your account on this device',
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

  Color themePrimary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  Divider _divider() => Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
      );

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
                    size: 22, color: themePrimary(context)),
                const SizedBox(width: 10),
                Text(
                  'Provider account detected',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
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
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
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
  Widget _buildHeaderBlock(ProfilesRow profile) {
    final theme = Theme.of(context);
    final displayName = valueOrDefault<String>(
      profile.displayName,
      'Rims Client',
    );
    final email = valueOrDefault<String>(profile.email, currentUserEmail);
    final phone = valueOrDefault<String>(
      profile.phoneNumber,
      FFAppState().phone,
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppThemeData.spaceLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular photo with a subtle 2px royal-blue ring.
          GestureDetector(
            onTap: () {
              _model.showEdit = !_model.showEdit;
              safeSetState(() {});
            },
            child: SizedBox(
              width: 78,
              height: 78,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: (profile.faceScanUrl ?? '').trim().isNotEmpty
                          ? Image.network(
                              profile.faceScanUrl!.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
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
                  if (_model.showEdit)
                    Positioned.fill(
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.34),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _pickAndUploadPhoto,
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.camera,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppThemeData.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                    ),
                    color: theme.textTheme.headlineSmall?.color,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: theme.textTheme.bodyMedium?.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: theme.dividerColor,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                _EditProfilePill(
                  onTap: () =>
                      context.pushNamed(EditProfileWidget.routeName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      storageFolderPath: 'profiles',
      maxWidth: 720,
      maxHeight: 1280,
      imageQuality: 80,
      allowPhoto: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      textColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
      pickerFontFamily: 'Plus Jakarta Sans',
    );
    if (selectedMedia == null ||
        !selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }
    if (!mounted) return;

    safeSetState(() => _model.isDataUploading_uploadData2mv = true);
    var downloadUrls = <String>[];
    try {
      showUploadMessage(context, 'Uploading file...', showLoading: true);
      for (final m in selectedMedia) {
        final url = await ProfilesService.instance
            .uploadProfilePhoto(m.bytes, m.storagePath.split('/').last);
        if (url != null) downloadUrls.add(url);
      }
    } finally {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _model.isDataUploading_uploadData2mv = false;
    }

    if (downloadUrls.length != selectedMedia.length) {
      if (mounted) showUploadMessage(context, 'Failed to upload data');
      return;
    }
    if (!mounted) return;

    safeSetState(() {
      _model.uploadedFileUrl_uploadData2mv = downloadUrls.first;
    });
    await ProfilesService.instance.updateProfile({
      'face_scan_url': downloadUrls.first,
    });
    if (mounted) showUploadMessage(context, 'Success!');
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

class _EditProfilePill extends StatelessWidget {
  const _EditProfilePill({required this.onTap});

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
          border: Border.all(color: theme.colorScheme.primary, width: 1.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, size: 13, color: theme.colorScheme.primary),
            const SizedBox(width: 5),
            Text(
              'Edit Profile',
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

class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              letterSpacing: 0.6,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: tint),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: titleColor ?? theme.textTheme.titleSmall?.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  size: 22, color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}
