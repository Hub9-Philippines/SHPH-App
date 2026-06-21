import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProfileModel.new);
    _model.switchValue = AppTheme.themeMode == ThemeMode.dark;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return FutureBuilder<List<ProfilesRow>>(
      future: FFAppState().checkIfAccountExists(
        uniqueQueryKey:
            '$currentUserUid${dateTimeFormat("M/d h:mm a", getCurrentTimestamp)}',
        requestFn: () => ProfilesTable().querySingleRow(
          queryFn: (q) => q.or(
            'phone_number.eq.${FFAppState().phone}, email.eq.${FFAppState().email}, id.eq.$currentUserUid',
          ),
        ),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF5F7FA),
              automaticallyImplyLeading: false,
              title: Text(
                'Profile',
                style: AppTheme.of(context).titleLarge,
              ),
              centerTitle: true,
              elevation: 0,
            ),
            body: const SingleChildScrollView(
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
          );
        }

        final profile = snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
        if (profile == null) {
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF5F7FA),
              automaticallyImplyLeading: false,
              title: Text(
                'Profile',
                style: AppTheme.of(context).titleLarge,
              ),
              centerTitle: true,
              elevation: 0,
            ),
            body: Center(
              child: Text(
                'Profile not found',
                style: AppTheme.of(context).bodyMedium,
              ),
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
            backgroundColor: const Color(0xFFF5F7FA),
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(),
                            const SizedBox(height: 18),
                            _buildProfileHero(profile),
                            const SizedBox(height: 18),
                            _buildQuickActions(),
                            const SizedBox(height: 22),
                            _ProfileSection(
                              title: 'Account',
                              children: [
                                _ProfileMenuTile(
                                  icon: Icons.location_on_rounded,
                                  iconTint: const Color(0xFF129575),
                                  title: 'My addresses',
                                  subtitle:
                                      'Save, edit, and choose service locations',
                                  onTap: () => context
                                      .pushNamed(AddressesWidget.routeName),
                                ),
                                _ProfileMenuTile(
                                  icon: Icons.wallet_rounded,
                                  iconTint: const Color(0xFF1B74E4),
                                  title: 'Payment methods',
                                  subtitle:
                                      'Add cards and manage checkout options',
                                  onTap: () => context.pushNamed(
                                      PaymentMethodsWidget.routeName),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _ProfileSection(
                              title: 'Preferences',
                              children: [
                                _ProfileMenuTile(
                                  icon: Icons.favorite_rounded,
                                  iconTint: const Color(0xFFE2557B),
                                  title: 'Favorites',
                                  subtitle:
                                      'Jump back into the services you saved',
                                  onTap: () => context
                                      .pushNamed(FavoritesWidget.routeName),
                                ),
                                _ProfileMenuTile(
                                  icon: Icons.notifications_rounded,
                                  iconTint: const Color(0xFFF59E0B),
                                  title: 'My notifications',
                                  subtitle:
                                      'Review reminders and activity updates',
                                  onTap: () => context.pushNamed(
                                      MyNotificationsWidget.routeName),
                                ),
                                _ProfileMenuTile(
                                  icon: Icons.language_rounded,
                                  iconTint: const Color(0xFF7C5CFC),
                                  title: 'Language',
                                  subtitle:
                                      'Change the language used across the app',
                                  onTap: () => context.pushNamed(
                                    LanguageSettingsWidget.routeName,
                                  ),
                                ),
                                _ProfileToggleTile(
                                  icon: Icons.dark_mode_rounded,
                                  iconTint: const Color(0xFF17212B),
                                  title: 'Dark mode',
                                  subtitle:
                                      'Switch between light and dark appearance',
                                  value: _model.switchValue ?? false,
                                  onChanged: (newValue) async {
                                    safeSetState(
                                        () => _model.switchValue = newValue);
                                    if (newValue) {
                                      setDarkModeSetting(
                                        context,
                                        ThemeMode.dark,
                                      );
                                    } else {
                                      setDarkModeSetting(
                                        context,
                                        ThemeMode.light,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _ProfileSection(
                              title: 'Support',
                              children: [
                                _ProfileMenuTile(
                                  icon: Icons.rate_review_rounded,
                                  iconTint: const Color(0xFFEF6C57),
                                  title: 'My reviews',
                                  subtitle: 'See the feedback you have left',
                                  onTap: () => context
                                      .pushNamed(MyReviewsWidget.routeName),
                                ),
                                _ProfileMenuTile(
                                  icon: Icons.security_rounded,
                                  iconTint: const Color(0xFF00A8A8),
                                  title: 'Security',
                                  subtitle:
                                      'Password, login protection, and account safety',
                                  onTap: () => context.pushNamed(
                                    SecuritySettingsWidget.routeName,
                                  ),
                                ),
                                _ProfileMenuTile(
                                  icon: Icons.settings_rounded,
                                  iconTint: const Color(0xFF5F6B76),
                                  title: 'Settings',
                                  subtitle: 'Adjust your app preferences',
                                  onTap: () => context
                                      .pushNamed(SettingsWidget.routeName),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _buildLogoutTile(),
                            const SizedBox(height: 20),
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
    );
  }

  Widget _buildTopBar() => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: AppTheme.of(context).headlineSmall.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                        ),
                        color: const Color(0xFF16202A),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your profile, saved places, and preferences.',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.poppins(),
                        color: const Color(0xFF66727E),
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: AppTheme.of(context).primary,
            ),
          ),
        ],
      );

  Widget _buildProfileHero(ProfilesRow profile) {
    final displayName = valueOrDefault<String>(
      profile.displayName,
      'Firstname Lastname',
    );
    final email = valueOrDefault<String>(profile.email, currentUserEmail);
    final phone =
        valueOrDefault<String>(profile.phoneNumber, FFAppState().phone);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F8A6C),
            Color(0xFF17B890),
            Color(0xFF73D8B4),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F8A6C),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _model.showEdit = !_model.showEdit;
                  safeSetState(() {});
                },
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: (profile.faceScanUrl ?? '').trim().isNotEmpty
                              ? Image.network(
                                  profile.faceScanUrl!.trim(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTheme.of(context).headlineSmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email.isNotEmpty ? email : phone,
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () =>
                          context.pushNamed(EditProfileWidget.routeName),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit profile',
                              style: AppTheme.of(context).labelLarge.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ProfileMetric(
                    label: 'Profile',
                    value: 'Ready',
                    icon: Icons.verified_user_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 42,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                Expanded(
                  child: _ProfileMetric(
                    label: 'Location',
                    value: FFAppState().hasSelectedLocation ? 'Set' : 'Add',
                    icon: Icons.pin_drop_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 42,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                Expanded(
                  child: _ProfileMetric(
                    label: 'Theme',
                    value: (_model.switchValue ?? false) ? 'Dark' : 'Light',
                    icon: Icons.palette_outlined,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() => Row(
        children: [
          Expanded(
            child: _ProfileQuickAction(
              icon: Icons.location_city_rounded,
              label: 'Addresses',
              tint: const Color(0xFF129575),
              onTap: () => context.pushNamed(AddressesWidget.routeName),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ProfileQuickAction(
              icon: Icons.credit_card_rounded,
              label: 'Payments',
              tint: const Color(0xFF1B74E4),
              onTap: () => context.pushNamed(PaymentMethodsWidget.routeName),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ProfileQuickAction(
              icon: Icons.support_agent_rounded,
              label: 'Support',
              tint: const Color(0xFFEF6C57),
              onTap: () => context.pushNamed(SettingsWidget.routeName),
            ),
          ),
        ],
      );

  Widget _buildLogoutTile() => _ProfileMenuTile(
        icon: Icons.logout_rounded,
        iconTint: AppTheme.of(context).error,
        iconBackground: const Color(0xFFFFEEF0),
        title: 'Log out',
        subtitle: 'Sign out of your account on this device',
        titleColor: AppTheme.of(context).error,
        onTap: _handleLogout,
      );

  Future<void> _pickAndUploadPhoto() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      storageFolderPath: 'profiles',
      maxWidth: 720,
      maxHeight: 1280,
      imageQuality: 80,
      allowPhoto: true,
      backgroundColor: AppTheme.of(context).primaryBackground,
      textColor: AppTheme.of(context).primaryText,
      pickerFontFamily: 'Poppins',
    );
    if (selectedMedia == null ||
        !selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }

    safeSetState(() => _model.isDataUploading_uploadData2mv = true);
    var selectedUploadedFiles = <FFUploadedFile>[];
    var downloadUrls = <String>[];

    try {
      showUploadMessage(
        context,
        'Uploading file...',
        showLoading: true,
      );
      selectedUploadedFiles = selectedMedia
          .map(
            (m) => FFUploadedFile(
              name: m.storagePath.split('/').last,
              bytes: m.bytes,
              height: m.dimensions?.height,
              width: m.dimensions?.width,
              blurHash: m.blurHash,
              originalFilename: m.originalFilename,
            ),
          )
          .toList();

      downloadUrls = await uploadSupabaseStorageFiles(
        bucketName: 'SHPH',
        selectedFiles: selectedMedia,
      );
    } finally {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      _model.isDataUploading_uploadData2mv = false;
    }

    if (selectedUploadedFiles.length != selectedMedia.length ||
        downloadUrls.length != selectedMedia.length) {
      if (mounted) {
        showUploadMessage(context, 'Failed to upload data');
      }
      return;
    }

    if (!mounted) {
      return;
    }

    safeSetState(() {
      _model.uploadedLocalFile_uploadData2mv = selectedUploadedFiles.first;
      _model.uploadedFileUrl_uploadData2mv = downloadUrls.first;
    });

    await ProfilesTable().update(
      data: {'face_scan_url': downloadUrls.first},
      matchingRows: (rows) => rows.eq('id', currentUserUid),
    );

    if (mounted) {
      showUploadMessage(context, 'Success!');
    }
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

    if (!confirm) {
      return;
    }

    if (!mounted) {
      return;
    }

    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    if (!mounted) {
      return;
    }
    GoRouter.of(context).clearRedirectLocation();

    context.goNamedAuth(SplashWidget.routeName, context.mounted);
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: AppTheme.of(context).labelLarge.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                  ),
                  color: const Color(0xFF6A7681),
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileQuickAction extends StatelessWidget {
  const _ProfileQuickAction({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: tint),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                      color: const Color(0xFF16202A),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackground,
    this.titleColor,
  });

  final IconData icon;
  final Color iconTint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconBackground;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground ?? iconTint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconTint, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                            color: titleColor ?? const Color(0xFF16202A),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF6F7B86),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF8A97A4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileToggleTile extends StatelessWidget {
  const _ProfileToggleTile({
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconTint;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconTint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconTint, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                        color: const Color(0xFF16202A),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.poppins(),
                        color: const Color(0xFF6F7B86),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.of(context).primary,
            activeTrackColor: AppTheme.of(context).primary,
            inactiveTrackColor: AppTheme.of(context).alternate,
            inactiveThumbColor: AppTheme.of(context).secondaryBackground,
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.92), size: 18),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.of(context).bodySmall.override(
                font: GoogleFonts.poppins(),
                color: Colors.white.withValues(alpha: 0.78),
              ),
        ),
      ],
    );
  }
}
