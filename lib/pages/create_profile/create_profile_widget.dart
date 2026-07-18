import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '/api/resources/users_api.dart';
import '/auth/shph_auth/auth_util.dart';
import '/components/password_validation_item/password_validation_item_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/error_handler.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'create_profile_model.dart';

export 'create_profile_model.dart';

class CreateProfileWidget extends StatefulWidget {
  const CreateProfileWidget({super.key});

  static String routeName = 'CreateProfile';
  static String routePath = '/createProfile';

  @override
  State<CreateProfileWidget> createState() => _CreateProfileWidgetState();
}

class _CreateProfileWidgetState extends State<CreateProfileWidget>
    with TickerProviderStateMixin {
  late CreateProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late ScrollController _scrollController;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CreateProfileModel.new);
    _scrollController = ScrollController();

    // Log auth state for debugging
    LoggingService.info(
      'CreateProfile page loaded - currentUserUid: $currentUserUid, loggedIn: $loggedIn',
      tag: 'CreateProfile',
    );

    // Log initial validation state
    LoggingService.debug(
      'Initial validation state - isPasswordValid: ${_model.isPasswordValid}, isEmailvalid: ${_model.isEmailvalid}, checkbox: ${_model.checkboxValue}',
      tag: 'CreateProfile',
    );

    _model.firstNameTextFieldTextController ??= TextEditingController();
    _model.firstNameTextFieldFocusNode ??= FocusNode();

    _model.lastNameTextFieldTextController ??= TextEditingController();
    _model.lastNameTextFieldFocusNode ??= FocusNode();

    _model.emailTextFieldTextController ??= TextEditingController();
    _model.emailTextFieldFocusNode ??= FocusNode();

    _model.passwordTextFieldTextController ??= TextEditingController();
    _model.passwordTextFieldFocusNode ??= FocusNode();
    _model.passwordTextFieldFocusNode?.addListener(_scrollToPassword);

    // Pre-populate fields from existing profile data
    _loadExistingProfileData();
    animationsMap.addAll({
      'columnOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: 0,
            end: 1,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0, -20),
            end: Offset.zero,
          ),
        ],
      ),
    });
  }

  void _scrollToPassword() {
    if (_model.passwordTextFieldFocusNode?.hasFocus ?? false) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Load existing profile data from the SHPH API and pre-populate fields
  Future<void> _loadExistingProfileData() async {
    try {
      final userId = currentUserUid;
      if (userId.isEmpty) {
        LoggingService.debug(
          'Cannot load profile: User not authenticated',
          tag: 'CreateProfile',
        );
        return;
      }

      LoggingService.info(
        'Loading existing profile data for user: $userId',
        tag: 'CreateProfile',
      );

      final response = await ShphUsersApi.instance.getMe();

      if (response.isEmpty) {
        LoggingService.debug(
          'No existing profile found, showing empty form',
          tag: 'CreateProfile',
        );
        return;
      }

      LoggingService.info(
        'Profile data loaded: $response',
        tag: 'CreateProfile',
      );

      // Pre-populate fields with existing data
      if (mounted) {
        setState(() {
          // First name
          final firstName = response['first_name'] as String?;
          if (firstName != null && firstName.isNotEmpty) {
            _model.firstNameTextFieldTextController?.text = firstName;
            _model.firsthasValue = true;
          }

          // Last name
          final lastName = response['last_name'] as String?;
          if (lastName != null && lastName.isNotEmpty) {
            _model.lastNameTextFieldTextController?.text = lastName;
            _model.lasthasValue = true;
          }

          // Email
          final email = response['email'] as String?;
          if (email != null && email.isNotEmpty) {
            _model.emailTextFieldTextController?.text = email;
            _model.isEmailvalid = functions.checkEmailRegex(email);
          }

          // Phone (from FFAppState or SHPH API)
          final phone = response['phone_number'] as String?;
          if (phone != null && phone.isNotEmpty) {
            FFAppState().phone = phone;
          }
        });

        LoggingService.info(
          'Profile fields pre-populated successfully',
          tag: 'CreateProfile',
        );
      }
    } catch (e) {
      LoggingService.error(
        'Error loading existing profile data: $e',
        tag: 'CreateProfile',
      );
      // Continue with empty form, don't block user
    }
  }

  @override
  void dispose() {
    _model.passwordTextFieldFocusNode?.removeListener(_scrollToPassword);
    _scrollController.dispose();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Complete your account',
                        textAlign: TextAlign.center,
                        style: AppTheme.of(context).displaySmall.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontStyle:
                                    AppTheme.of(context).displaySmall.fontStyle,
                              ),
                              fontSize: 28,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
                              fontStyle:
                                  AppTheme.of(context).displaySmall.fontStyle,
                            ),
                      ),
                      Text(
                        'We need to verify that it\'s you',
                        textAlign: TextAlign.center,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight:
                                    AppTheme.of(context).bodyMedium.fontWeight,
                                fontStyle:
                                    AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0,
                              fontWeight:
                                  AppTheme.of(context).bodyMedium.fontWeight,
                              fontStyle:
                                  AppTheme.of(context).bodyMedium.fontStyle,
                            ),
                      ),
                    ].divide(const SizedBox(height: 8)),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'First name',
                                            style: AppTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight:
                                                        AppTheme.of(context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: AppTheme.of(context)
                                                      .secondaryText,
                                                  letterSpacing: 0,
                                                  fontWeight:
                                                      AppTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          TextFormField(
                                            controller: _model
                                                .firstNameTextFieldTextController,
                                            focusNode: _model
                                                .firstNameTextFieldFocusNode,
                                            onChanged: (_) =>
                                                EasyDebounce.debounce(
                                              '_model.firstNameTextFieldTextController',
                                              Duration.zero,
                                              () => safeSetState(() {}),
                                            ),
                                            autofocus: false,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintStyle: AppTheme.of(context)
                                                  .bodyLarge
                                                  .override(
                                                    font: GoogleFonts.poppins(
                                                      fontWeight:
                                                          AppTheme.of(context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          AppTheme.of(context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                    color: AppTheme.of(context)
                                                        .secondaryText,
                                                    letterSpacing: 0,
                                                    fontWeight:
                                                        AppTheme.of(context)
                                                            .bodyLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(context)
                                                            .bodyLarge
                                                            .fontStyle,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(context)
                                                      .alternate,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(context)
                                                      .alternate,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: AppTheme.of(context)
                                                  .primaryBackground,
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(16, 20, 16, 20),
                                              hoverColor: AppTheme.of(context)
                                                  .primaryBackground,
                                            ),
                                            style: AppTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight:
                                                        AppTheme.of(context)
                                                            .bodyLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(context)
                                                            .bodyLarge
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0,
                                                  fontWeight:
                                                      AppTheme.of(context)
                                                          .bodyLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(context)
                                                          .bodyLarge
                                                          .fontStyle,
                                                ),
                                            cursorColor: AppTheme.of(context)
                                                .primaryText,
                                            validator: _model
                                                .firstNameTextFieldTextControllerValidator
                                                .asValidator(context),
                                          ),
                                        ].divide(const SizedBox(height: 4)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Last Name',
                                            style: AppTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight:
                                                        AppTheme.of(context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: AppTheme.of(context)
                                                      .secondaryText,
                                                  letterSpacing: 0,
                                                  fontWeight:
                                                      AppTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          TextFormField(
                                            controller: _model
                                                .lastNameTextFieldTextController,
                                            focusNode: _model
                                                .lastNameTextFieldFocusNode,
                                            onChanged: (_) =>
                                                EasyDebounce.debounce(
                                              '_model.lastNameTextFieldTextController',
                                              Duration.zero,
                                              () => safeSetState(() {}),
                                            ),
                                            autofocus: false,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintStyle: AppTheme.of(context)
                                                  .bodyLarge
                                                  .override(
                                                    font: GoogleFonts.poppins(
                                                      fontWeight:
                                                          AppTheme.of(context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          AppTheme.of(context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                                    color: AppTheme.of(context)
                                                        .secondaryText,
                                                    letterSpacing: 0,
                                                    fontWeight:
                                                        AppTheme.of(context)
                                                            .bodyLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(context)
                                                            .bodyLarge
                                                            .fontStyle,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(context)
                                                      .alternate,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(context)
                                                      .alternate,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppTheme.of(context)
                                                      .error,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: AppTheme.of(context)
                                                  .primaryBackground,
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(16, 20, 16, 20),
                                              hoverColor: AppTheme.of(context)
                                                  .primaryBackground,
                                            ),
                                            style: AppTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight:
                                                        AppTheme.of(context)
                                                            .bodyLarge
                                                            .fontWeight,
                                                    fontStyle:
                                                        AppTheme.of(context)
                                                            .bodyLarge
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0,
                                                  fontWeight:
                                                      AppTheme.of(context)
                                                          .bodyLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(context)
                                                          .bodyLarge
                                                          .fontStyle,
                                                ),
                                            cursorColor: AppTheme.of(context)
                                                .primaryText,
                                            validator: _model
                                                .lastNameTextFieldTextControllerValidator
                                                .asValidator(context),
                                          ),
                                        ].divide(const SizedBox(height: 4)),
                                      ),
                                    ),
                                  ].divide(const SizedBox(width: 16)),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0,
                                            fontWeight: AppTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller:
                                            _model.emailTextFieldTextController,
                                        focusNode:
                                            _model.emailTextFieldFocusNode,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.emailTextFieldTextController',
                                          Duration.zero,
                                          () async {
                                            _model.isEmailvalid =
                                                functions.checkEmailRegex(_model
                                                    .emailTextFieldTextController
                                                    .text);
                                            safeSetState(() {});
                                          },
                                        ),
                                        autofocus: false,
                                        textInputAction: TextInputAction.next,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintStyle: AppTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      AppTheme.of(context)
                                                          .bodyLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(context)
                                                          .bodyLarge
                                                          .fontStyle,
                                                ),
                                                color: AppTheme.of(context)
                                                    .secondaryText,
                                                letterSpacing: 0,
                                                fontWeight: AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: valueOrDefault<Color>(
                                                !_model.isEmailvalid
                                                    ? AppTheme.of(context).error
                                                    : AppTheme.of(context)
                                                        .alternate,
                                                AppTheme.of(context).alternate,
                                              ),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: valueOrDefault<Color>(
                                                !_model.isEmailvalid
                                                    ? AppTheme.of(context).error
                                                    : AppTheme.of(context)
                                                        .alternate,
                                                AppTheme.of(context).accent4,
                                              ),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppTheme.of(context).error,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppTheme.of(context).error,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: AppTheme.of(context)
                                              .primaryBackground,
                                          contentPadding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(16, 20, 16, 20),
                                          hoverColor: AppTheme.of(context)
                                              .primaryBackground,
                                        ),
                                        style: AppTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0,
                                              fontWeight: AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                            ),
                                        cursorColor:
                                            AppTheme.of(context).primaryText,
                                        validator: _model
                                            .emailTextFieldTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                    if (!_model.isEmailvalid)
                                      Text(
                                        'Invalid email',
                                        style: AppTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: AppTheme.of(context)
                                                    .bodySmall
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .bodySmall
                                                    .fontStyle,
                                              ),
                                              color: AppTheme.of(context).error,
                                              letterSpacing: 0,
                                              fontWeight: AppTheme.of(context)
                                                  .bodySmall
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodySmall
                                                  .fontStyle,
                                            ),
                                      ),
                                  ].divide(const SizedBox(height: 4)),
                                ),
                              ].divide(const SizedBox(height: 12)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password',
                                  style: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: AppTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                        color:
                                            AppTheme.of(context).secondaryText,
                                        letterSpacing: 0,
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller:
                                        _model.passwordTextFieldTextController,
                                    focusNode:
                                        _model.passwordTextFieldFocusNode,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.passwordTextFieldTextController',
                                      Duration.zero,
                                      () async {
                                        _model.isPasswordValid = _model
                                                    .passwordTextFieldTextController
                                                    .text
                                                    .length >=
                                                8 &&
                                            _model.passwordTextFieldTextController
                                                    .text.length <=
                                                32 &&
                                            RegExp('[a-z]').hasMatch(_model
                                                .passwordTextFieldTextController
                                                .text) &&
                                            RegExp('[A-Z]').hasMatch(_model
                                                .passwordTextFieldTextController
                                                .text) &&
                                            RegExp(r'\d').hasMatch(
                                                _model.passwordTextFieldTextController.text) &&
                                            RegExp('[^a-zA-Z0-9]').hasMatch(_model.passwordTextFieldTextController.text);
                                        safeSetState(() {});
                                      },
                                    ),
                                    autofocus: false,
                                    textInputAction: TextInputAction.done,
                                    obscureText:
                                        !_model.passwordTextFieldVisibility,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintStyle: AppTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0,
                                            fontWeight: AppTheme.of(context)
                                                .bodyLarge
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodyLarge
                                                .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context).alternate,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context).alternate,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context).error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context).error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.of(context)
                                          .primaryBackground,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16, 20, 16, 20),
                                      hoverColor: AppTheme.of(context)
                                          .primaryBackground,
                                      suffixIcon: InkWell(
                                        onTap: () async {
                                          safeSetState(() => _model
                                                  .passwordTextFieldVisibility =
                                              !_model
                                                  .passwordTextFieldVisibility);
                                        },
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.passwordTextFieldVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppTheme.of(context).alternate,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    style:
                                        AppTheme.of(context).bodyLarge.override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0,
                                              fontWeight: AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                            ),
                                    cursorColor:
                                        AppTheme.of(context).primaryText,
                                    validator: _model
                                        .passwordTextFieldTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                                LinearPercentIndicator(
                                  percent: functions.passCheckupProgress(_model
                                      .passwordTextFieldTextController.text),
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.89,
                                  lineHeight: 8,
                                  animation: true,
                                  animateFromLastPercent: true,
                                  progressColor:
                                      functions.passCheckupProgress('') == 1.0
                                          ? AppTheme.of(context).success
                                          : AppTheme.of(context).primary,
                                  backgroundColor:
                                      AppTheme.of(context).secondaryBackground,
                                  barRadius: const Radius.circular(50),
                                  padding: EdgeInsets.zero,
                                ),
                              ].divide(const SizedBox(height: 4)),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                    child: Text(
                                      'Your password must contain:',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: AppTheme.of(context)
                                                  .bodySmall
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodySmall
                                                  .fontStyle,
                                            ),
                                            letterSpacing: 0,
                                            fontWeight: AppTheme.of(context)
                                                .bodySmall
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodySmall
                                                .fontStyle,
                                          ),
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.passwordValidationItemModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PasswordValidationItemWidget(
                                      isValid: (_model
                                                  .passwordTextFieldTextController
                                                  .text
                                                  .length >=
                                              8) &&
                                          (_model.passwordTextFieldTextController
                                                  .text.length <=
                                              32),
                                      label: '8-32 character long',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.passwordValidationItemModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PasswordValidationItemWidget(
                                      isValid: RegExp('[a-z]').hasMatch(_model
                                          .passwordTextFieldTextController
                                          .text),
                                      label: '1 lowercase character (a-z)',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.passwordValidationItemModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PasswordValidationItemWidget(
                                      isValid: RegExp('[A-Z]').hasMatch(_model
                                          .passwordTextFieldTextController
                                          .text),
                                      label: '1 uppercase character (A-Z)',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.passwordValidationItemModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PasswordValidationItemWidget(
                                      isValid: RegExp(r'\d').hasMatch(_model
                                          .passwordTextFieldTextController
                                          .text),
                                      label: '1 number',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.passwordValidationItemModel5,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PasswordValidationItemWidget(
                                      isValid: RegExp('[^a-zA-Z0-9]').hasMatch(
                                          _model.passwordTextFieldTextController
                                              .text),
                                      label:
                                          r'1 special character e.g. ! @ # $ %',
                                    ),
                                  ),
                                ].divide(const SizedBox(height: 8)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 10, 0, 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Theme(
                                    data: ThemeData(
                                      checkboxTheme: CheckboxThemeData(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      unselectedWidgetColor:
                                          AppTheme.of(context).secondaryText,
                                    ),
                                    child: Checkbox(
                                      value: _model.checkboxValue ??= false,
                                      onChanged: (newValue) async {
                                        safeSetState(() =>
                                            _model.checkboxValue = newValue!);
                                        if (newValue!) {
                                          FFAppState().toggleAgree = true;
                                          safeSetState(() {});
                                        } else {
                                          FFAppState().toggleAgree = false;
                                          safeSetState(() {});
                                        }
                                      },
                                      side: BorderSide(
                                        width: 2,
                                        color:
                                            AppTheme.of(context).secondaryText,
                                      ),
                                      activeColor: AppTheme.of(context).primary,
                                      checkColor: AppTheme.of(context).info,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'I agree to the Terms of Service and Privacy Policy',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: AppTheme.of(context)
                                                  .bodySmall
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodySmall
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0,
                                            fontWeight: AppTheme.of(context)
                                                .bodySmall
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodySmall
                                                .fontStyle,
                                          ),
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 8)),
                              ),
                            ),
                          ].divide(const SizedBox(height: 12)),
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FFButtonWidget(
                                onPressed:
                                    ((_model.firstNameTextFieldTextController
                                                    .text ==
                                                '') ||
                                            (_model.lastNameTextFieldTextController
                                                    .text ==
                                                '') ||
                                            (_model.emailTextFieldTextController
                                                    .text ==
                                                '') ||
                                            (_model.passwordTextFieldTextController
                                                    .text ==
                                                '') ||
                                            !_model.isPasswordValid ||
                                            !_model.isEmailvalid ||
                                            (_model.checkboxValue == false))
                                        ? null
                                        : () async {
                                            LoggingService.info(
                                              'Submit button clicked',
                                              tag: 'CreateProfile',
                                            );
                                            LoggingService.debug(
                                              'Form data - First: ${_model.firstNameTextFieldTextController.text}, Last: ${_model.lastNameTextFieldTextController.text}',
                                              tag: 'CreateProfile',
                                            );
                                            LoggingService.debug(
                                              'Validations - isPasswordValid: ${_model.isPasswordValid}, isEmailvalid: ${_model.isEmailvalid}, checkbox: ${_model.checkboxValue}',
                                              tag: 'CreateProfile',
                                            );
                                            LoggingService.debug(
                                              'Auth - currentUserUid: $currentUserUid, phone: ${FFAppState().phone}, role: ${FFAppState().tempsignuprole}',
                                              tag: 'CreateProfile',
                                            );

                                            if (currentUserUid.isEmpty) {
                                              LoggingService.error(
                                                'Cannot create profile: User not authenticated (currentUserUid is empty)',
                                                tag: 'CreateProfile',
                                              );
                                              ErrorHandler.showError(
                                                'Authentication error. Please sign in again.',
                                              );
                                              return;
                                            }

                                            _model.register = await actions
                                                .insertProfileWithDebug(
                                              currentUserUid,
                                              _model
                                                  .firstNameTextFieldTextController
                                                  .text
                                                  .trim(),
                                              _model
                                                  .lastNameTextFieldTextController
                                                  .text
                                                  .trim(),
                                              _model
                                                  .emailTextFieldTextController
                                                  .text
                                                  .trim(),
                                              FFAppState().phone,
                                              FFAppState().tempsignuprole,
                                            );

                                            if (_model.register == 'success') {
                                              if (!context.mounted) {
                                                return;
                                              }
                                              LoggingService.info(
                                                'Profile created successfully',
                                                tag: 'CreateProfile',
                                              );
                                              LoggingService.info(
                                                'Role: ${FFAppState().tempsignuprole}, navigating...',
                                                tag: 'CreateProfile',
                                              );

                                              if (FFAppState().tempsignuprole !=
                                                  'client') {
                                                LoggingService.info(
                                                  'Navigating to EKYCBegin',
                                                  tag: 'CreateProfile',
                                                );
                                                await context.pushNamed(
                                                    EKYCBeginWidget.routeName);
                                              } else {
                                                LoggingService.info(
                                                  'Navigating to Home',
                                                  tag: 'CreateProfile',
                                                );
                                                await context.pushNamed(
                                                    HomeWidget.routeName);
                                              }
                                            } else {
                                              LoggingService.error(
                                                'Registration failed: ${_model.register}',
                                                tag: 'CreateProfile',
                                              );
                                              ErrorHandler.showError(
                                                _model.register ??
                                                    'An error occurred',
                                              );
                                            }

                                            safeSetState(() {});
                                          },
                                text: 'Submit',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56,
                                  padding: const EdgeInsets.all(8),
                                  iconPadding: EdgeInsetsDirectional.zero,
                                  color: AppTheme.of(context).primary,
                                  textStyle:
                                      AppTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: AppTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context).info,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: AppTheme.of(context)
                                                .titleMedium
                                                .fontStyle,
                                          ),
                                  elevation: 0,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  disabledColor: AppTheme.of(context).alternate,
                                  disabledTextColor:
                                      AppTheme.of(context).secondaryBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ].divide(const SizedBox(height: 15)),
                    ).animateOnPageLoad(
                        animationsMap['columnOnPageLoadAnimation']!),
                  ),
                ].divide(const SizedBox(height: 32)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
