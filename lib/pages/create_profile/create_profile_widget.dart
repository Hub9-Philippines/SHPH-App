import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/services/auth_service.dart';
import '/services/logging_service.dart';
import '/services/profiles_service.dart';
import '/theme/app_theme.dart';
import 'create_profile_model.dart';

export 'create_profile_model.dart';

/// A picked photo: raw bytes plus the original file name for upload.
typedef CreateProfilePhoto = ({List<int> bytes, String name});

/// The redesigned profile-completion step reached after phone verification or
/// from the Profile hub. Collects only the details we actually need — first and
/// last name (matching the web signup form), optional avatar photo, optional
/// bio — then marks the profile complete via `ShphUsersApi.updateMe`. Skipping
/// leaves the profile incomplete so the hub keeps showing the completion prompt.
class CreateProfileWidget extends StatefulWidget {
  const CreateProfileWidget({
    super.key,
    this.profilesService,
    this.pickImage,
    this.onGoHome,
  });

  static String routeName = 'CreateProfile';
  static String routePath = '/createProfile';

  /// Injectable service seam for tests.
  final ProfilesService? profilesService;

  /// Injectable photo picker for tests (defaults to the device gallery).
  final Future<CreateProfilePhoto?> Function()? pickImage;

  /// Injectable navigation seam for tests (defaults to the Home tab).
  final void Function(BuildContext context)? onGoHome;

  @override
  State<CreateProfileWidget> createState() => _CreateProfileWidgetState();
}

class _CreateProfileWidgetState extends State<CreateProfileWidget> {
  late CreateProfileModel _model;

  ProfilesService get _service => widget.profilesService ?? ProfilesService.instance;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CreateProfileModel.new);
    _loadExistingProfile();
  }

  /// Prefills first name, last name, and bio from the server profile when
  /// present. Falls back to splitting the existing display name on the first
  /// space for legacy accounts that only stored a combined name.
  Future<void> _loadExistingProfile() async {
    try {
      final profile = await _service.getProfile();
      if (!mounted || profile == null) return;

      var firstName = profile.firstName?.trim() ?? '';
      var lastName = profile.lastName?.trim() ?? '';
      if (firstName.isEmpty && lastName.isEmpty) {
        final combined = profile.displayName?.trim() ?? '';
        final space = combined.indexOf(' ');
        if (space > 0) {
          firstName = combined.substring(0, space).trim();
          lastName = combined.substring(space + 1).trim();
        } else if (combined.isNotEmpty) {
          firstName = combined;
        }
      }
      if (profile.isProfileComplete == true ||
          (firstName.isNotEmpty && lastName.isNotEmpty) ||
          AuthService.instance.isProfileComplete) {
        _goHome();
        return;
      }
      safeSetState(() {
        if (firstName.isNotEmpty && _model.firstNameController.text.isEmpty) {
          _model.firstNameController.text = firstName;
        }
        if (lastName.isNotEmpty && _model.lastNameController.text.isEmpty) {
          _model.lastNameController.text = lastName;
        }
        if ((profile.bioDetails?.trim().isNotEmpty ?? false) &&
            _model.bioController.text.isEmpty) {
          _model.bioController.text = profile.bioDetails!.trim();
        }
      });
    } catch (e) {
      LoggingService.error('CreateProfile prefill failed: $e', tag: 'CreateProfile');
      // Continue with the empty form rather than blocking the user.
    }
  }

  Future<CreateProfilePhoto?> _defaultPickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      return (bytes: bytes, name: file.name);
    } catch (e) {
      LoggingService.error('Image pick failed: $e', tag: 'CreateProfile');
      return null;
    }
  }

  Future<void> _pickPhoto() async {
    if (_model.isSubmitting || _model.isUploading) return;
    final pick = widget.pickImage ?? _defaultPickImage;
    final photo = await pick();
    if (!mounted || photo == null) return;
    safeSetState(() {
      _model.pickedPhotoBytes = photo.bytes;
      _model.pickedPhotoName = photo.name;
      _model.uploadedPhotoUrl = null;
    });
  }

  Future<String?> _uploadPhoto() async {
    final bytes = _model.pickedPhotoBytes;
    if (bytes == null) return _model.uploadedPhotoUrl;
    safeSetState(() {
      _model.isUploading = true;
      _model.uploadProgress = 0;
    });
    final url = await _service.uploadProfilePhoto(
      bytes,
      _model.pickedPhotoName ?? 'profile_photo.jpg',
      onProgress: (progress) {
        if (mounted) safeSetState(() => _model.uploadProgress = progress);
      },
    );
    if (mounted) {
      safeSetState(() {
        _model.isUploading = false;
        _model.uploadedPhotoUrl = url;
      });
    }
    return url;
  }

  Future<void> _finish() async {
    final first = _model.firstNameController.text.trim();
    final last = _model.lastNameController.text.trim();
    final displayName = '$first $last'.trim();
    if (first.isEmpty || last.isEmpty || _model.isSubmitting || _model.isUploading) {
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final photoUrl = await _uploadPhoto();
      if (!mounted) return;
      final updates = <String, dynamic>{
        'first_name': first,
        'last_name': last,
        'display_name': displayName,
        'bio_details': _model.bioController.text.trim(),
        'is_profile_complete': true,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
      };
      final ok = await _service.updateProfile(updates);
      if (!mounted) return;
      if (ok) {
        LoggingService.info('Profile completed by user: $displayName', tag: 'CreateProfile');
        _goHome();
      } else {
        AppFeedback.showBanner(
          context,
          _l10n.saveProfileFailed,
          severity: AppBannerSeverity.error,
        );
      }
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  void _goHome() {
    final custom = widget.onGoHome;
    if (custom != null) {
      custom(context);
      return;
    }
    context.goNamedAuth(HomeWidget.routeName, context.mounted);
  }

  void _skip() {
    if (_model.isSubmitting || _model.isUploading) return;
    _goHome();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final canFinish = _model.firstNameController.text.trim().isNotEmpty &&
        _model.lastNameController.text.trim().isNotEmpty &&
        !_model.isSubmitting &&
        !_model.isUploading;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: CupertinoPageHeader(
          title: _l10n.completeYourProfile,
          actions: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _skip,
              child: Text(
                _l10n.skipForNow,
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.completionTitle,
                style: theme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: AppThemeData.spaceSm),
              Text(
                _l10n.completionSubtitle,
                style: theme.bodyMedium.copyWith(
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: AppThemeData.spaceXl),
              Center(child: _buildAvatar(context)),
              const SizedBox(height: AppThemeData.spaceXl),
              AppTextField(
                label: _l10n.firstNameLabel,
                placeholder: _l10n.firstNamePlaceholder,
                controller: _model.firstNameController,
                radius: AppThemeData.radiusMd,
                fillColor: theme.secondaryBackground,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) => safeSetState(() {}),
              ),
              const SizedBox(height: AppThemeData.spaceLg),
              AppTextField(
                label: _l10n.lastNameLabel,
                placeholder: _l10n.lastNamePlaceholder,
                controller: _model.lastNameController,
                radius: AppThemeData.radiusMd,
                fillColor: theme.secondaryBackground,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) => safeSetState(() {}),
              ),
              const SizedBox(height: AppThemeData.spaceLg),
              _buildProgress(context, _model.progress),
              const SizedBox(height: AppThemeData.spaceLg),
              AppTextField(
                label: _l10n.bioOptionalLabel,
                placeholder: _l10n.bioPlaceholder,
                controller: _model.bioController,
                radius: AppThemeData.radiusMd,
                fillColor: theme.secondaryBackground,
                maxLines: 3,
                maxLength: 200,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              const SizedBox(height: AppThemeData.spaceXl),
              AppButton(
                onPressed: canFinish ? _finish : null,
                loading: _model.isSubmitting,
                width: double.infinity,
                height: 52,
                child: Text(_l10n.finish),
              ),
              const SizedBox(height: AppThemeData.spaceSm),
              AppButton(
                variant: AppButtonVariant.text,
                onPressed: _skip,
                width: double.infinity,
                height: 48,
                child: Text(_l10n.skipForNow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context, double progress) {
    final theme = AppTheme.of(context);
    final percent = (progress * 100).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: theme.primary,
              backgroundColor: theme.secondaryBackground,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _l10n.progressComplete(percent),
            style: theme.bodySmall.copyWith(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = AppTheme.of(context);
    final model = _model;
    final localBytes = model.pickedPhotoBytes;
    final remoteUrl = model.uploadedPhotoUrl;
    final hasPhoto = localBytes != null || (remoteUrl?.trim().isNotEmpty ?? false);

    return Column(
      children: [
        SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.border,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: localBytes != null
                          ? Image.memory(
                              Uint8List.fromList(localBytes),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            )
                          : remoteUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: remoteUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => _avatarPlaceholder(),
                                  errorWidget: (_, __, ___) =>
                                      _avatarPlaceholder(),
                                )
                              : _avatarPlaceholder(),
                    ),
                  ),
                ),
              ),
              if (model.isUploading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: AppActivityIndicator(
                        radius: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          variant: AppButtonVariant.primary,
          onPressed: (model.isSubmitting || model.isUploading) ? null : _pickPhoto,
          child: Text(hasPhoto ? _l10n.changePhoto : _l10n.addPhoto),
        ),
        if (model.isUploading) ...[
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: model.uploadProgress,
            minHeight: 4,
            color: theme.primary,
            backgroundColor: theme.secondaryBackground,
          ),
          const SizedBox(height: 6),
          Text(
            _l10n.crUploadProgress((model.uploadProgress * 100).round()),
            style: theme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _avatarPlaceholder() => Container(
        color: AppTheme.of(context).secondaryBackground,
        alignment: Alignment.center,
        child: Icon(
          Icons.person_rounded,
          size: 44,
          color: AppTheme.of(context).secondaryText,
        ),
      );
}
