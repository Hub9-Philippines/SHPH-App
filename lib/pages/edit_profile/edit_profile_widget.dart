import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/auth/auth_util.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/l10n/app_localizations.dart';
import '/services/profiles_service.dart';
import '/theme/app_theme.dart';
import 'edit_profile_model.dart';

export 'edit_profile_model.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/edit-profile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late EditProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _verificationStatus;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EditProfileModel.new);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profile = await ProfilesService.instance.getProfile();
      if (profile != null) {
        _verificationStatus = profile.verificationStatus;

        if (_verificationStatus == 'pending') {
          final prefs = await SharedPreferences.getInstance();
          final pendingKey = 'pending_profile_edits_$currentUserUid';
          final pendingJson = prefs.getString(pendingKey);

          if (pendingJson != null) {
            final Map<String, dynamic> stagedData = jsonDecode(pendingJson);
            _displayNameController.text =
                stagedData['display_name'] ?? profile.displayName ?? '';
            _emailController.text = stagedData['email'] ?? profile.email ?? '';
            _phoneController.text =
                stagedData['phone_number'] ?? profile.phoneNumber ?? '';
            return;
          }
        }

        _displayNameController.text = profile.displayName ?? '';
        _emailController.text = profile.email ?? '';
        _phoneController.text = profile.phoneNumber ?? '';
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_verificationStatus == 'pending') {
        // Save locally to SharedPreferences instead of remote Supabase profiles table
        final prefs = await SharedPreferences.getInstance();
        final stagedData = {
          'display_name': _displayNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone_number': _phoneController.text.trim(),
        };
        await prefs.setString(
            'pending_profile_edits_$currentUserUid', jsonEncode(stagedData));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_l10n.epStagedLocally)),
          );
          context.pop();
        }
      } else {
        // Save via ProfilesService (will use SHPH API if enabled, otherwise Supabase)
        await ProfilesService.instance.updateProfile({
          'display_name': _displayNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone_number': _phoneController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_l10n.epUpdated)),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.epUpdateError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: CupertinoPageHeader(
              title: _l10n.epTitle,
              backgroundColor: AppTheme.of(context).primaryBackground,
              leading: wrapWithModel(
                model: _model.backButtonModel,
                updateCallback: () => safeSetState(() {}),
                child: const BackButtonWidget(),
              ),
              titleStyle: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold),
                  ),
            ),
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        _l10n.epPersonalInfo,
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _displayNameController,
                        label: _l10n.epDisplayName,
                        placeholder: _l10n.epDisplayNameHint,
                        placeholderStyle: AppTheme.of(context).bodyMedium,
                        fillColor: AppTheme.of(context).secondaryBackground,
                        radius: 8,
                        style: AppTheme.of(context).bodyMedium,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _l10n.epDisplayNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: _l10n.epEmail,
                        placeholder: _l10n.epEmailHint,
                        placeholderStyle: AppTheme.of(context).bodyMedium,
                        fillColor: AppTheme.of(context).secondaryBackground,
                        radius: 8,
                        style: AppTheme.of(context).bodyMedium,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _l10n.epEmailRequired;
                          }
                          if (!value.contains('@')) {
                            return _l10n.epEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        label: _l10n.epPhoneNumber,
                        placeholder: _l10n.epPhoneHint,
                        placeholderStyle: AppTheme.of(context).bodyMedium,
                        fillColor: AppTheme.of(context).secondaryBackground,
                        radius: 8,
                        style: AppTheme.of(context).bodyMedium,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                      FFButtonWidget(
                        onPressed: _saveProfile,
                        text: _l10n.epSave,
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          color: AppTheme.of(context).primary,
                          textStyle: AppTheme.of(context).titleSmall.override(
                                color: AppTheme.of(context).onPrimary,
                                font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600),
                              ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
