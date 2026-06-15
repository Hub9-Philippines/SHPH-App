import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'signup_model.dart';

export 'signup_model.dart';

class SignupWidget extends StatefulWidget {
  const SignupWidget({super.key});

  static String routeName = 'Signup';
  static String routePath = '/signup';

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  late SignupModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SignupModel.new);

    _model.phoneFieldTextController ??= TextEditingController();
    _model.phoneFieldFocusNode ??= FocusNode();

    _model.phoneFieldMask = MaskTextInputFormatter(mask: '+63##########');
    handlePhoneAuthStateChanges(context);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          Navigator.of(context).pop();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            actions: const [],
            centerTitle: true,
            elevation: 0,
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to SerbisyoHub PH!',
                            textAlign: TextAlign.start,
                            style: AppTheme.of(context)
                                .headlineLarge
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: AppTheme.of(context)
                                        .headlineLarge
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: AppTheme.of(context)
                                      .headlineLarge
                                      .fontStyle,
                                ),
                          ),
                          Text(
                            'Create your account and manage your home services effortlessly.',
                            textAlign: TextAlign.start,
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
                                  color: const Color(0xFF889096),
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: AppTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(const SizedBox(height: 10)),
                      ),
                      Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.phoneFieldTextController,
                          focusNode: _model.phoneFieldFocusNode,
                          onChanged: (_) => EasyDebounce.debounce(
                            '_model.phoneFieldTextController',
                            const Duration(milliseconds: 100),
                            () async {
                              _model.isPhoneValid =
                                  (_model.phoneFieldTextController.text.length ==
                                          13);
                              safeSetState(() {});
                              FFAppState().phone =
                                  _model.phoneFieldTextController.text;
                              safeSetState(() {});
                            },
                          ),
                          autofocus: true,
                          enabled: true,
                          textInputAction: TextInputAction.go,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: false,
                            labelText: 'Mobile number',
                            labelStyle: AppTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: AppTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  fontWeight: AppTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            hintText: '+63',
                            hintStyle: AppTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: AppTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  fontWeight: AppTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: valueOrDefault<Color>(
                                  _model.isPhoneValid
                                      ? AppTheme.of(context)
                                          .secondaryBackground
                                      : AppTheme.of(context).error,
                                  AppTheme.of(context)
                                      .secondaryBackground,
                                ),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: valueOrDefault<Color>(
                                  _model.isPhoneValid
                                      ? AppTheme.of(context)
                                          .secondaryBackground
                                      : AppTheme.of(context).error,
                                  AppTheme.of(context)
                                      .secondaryBackground,
                                ),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.of(context).error,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.of(context).error,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppTheme.of(context)
                                .secondaryBackground,
                          ),
                          style:
                              AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: AppTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16,
                                    letterSpacing: 0,
                                    fontWeight: AppTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          textAlign: TextAlign.start,
                          maxLength: 13,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                          keyboardType: TextInputType.phone,
                          cursorColor: AppTheme.of(context).primaryText,
                          enableInteractiveSelection: true,
                          validator: _model.phoneFieldTextControllerValidator
                              .asValidator(context),
                          inputFormatters: [_model.phoneFieldMask],
                        ),
                      ),
                      if (_model.errorMessage != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                          child: Text(
                            _model.errorMessage!,
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
                        ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FFButtonWidget(
                            onPressed: _model.isLoading
                                ? null
                                : () async {
                                    _model.errorMessage = null;
                                    _model.isLoading = true;
                                    safeSetState(() {});

                                    if (_model.phoneFieldTextController.text !=
                                        '') {
                                      try {
                                        _model.isPhoneExists =
                                            await ProfilesTable().queryRows(
                                          queryFn: (q) => q.eqOrNull(
                                            'phone_number',
                                            FFAppState().phone,
                                          ),
                                        );
                                        if (_model.isPhoneExists?.firstOrNull
                                                ?.phoneNumber ==
                                            FFAppState().phone) {
                                          _model.isLoading = false;
                                          _model.errorMessage =
                                              'This phone number is already associated with an account. Please login instead.';
                                          safeSetState(() {});
                                          if (!context.mounted) return;
                                          await showDialog(
                                            context: context,
                                            builder: (alertDialogContext) =>
                                                AlertDialog(
                                              title: const Text(
                                                  'Account Already Exists'),
                                              content: const Text(
                                                  'This phone number is already associated with an account. Please login instead.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          alertDialogContext),
                                                  child: const Text('Ok'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          final phoneNumberVal =
                                              _model.phoneFieldTextController
                                                  .text;
                                          if (phoneNumberVal.isEmpty ||
                                              !phoneNumberVal
                                                  .startsWith('+')) {
                                            _model.isLoading = false;
                                            _model.errorMessage =
                                                'Phone Number is required and has to start with +.';
                                            safeSetState(() {});
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Phone Number is required and has to start with +.'),
                                              ),
                                            );
                                            return;
                                          }
                                          await beginPhoneAuth(
                                            context: context,
                                            phoneNumber: phoneNumberVal,
                                            onCodeSent: (context) async {
                                              if (!context.mounted) return;
                                              context.pushNamed(
                                                PhoneVerifyUserWidget
                                                    .routeName,
                                              );
                                            },
                                          );

                                          _model.isLoading = false;
                                          safeSetState(() {});
                                        }
                                      } catch (e) {
                                        _model.isLoading = false;
                                        _model.errorMessage =
                                            'An error occurred. Please try again.';
                                        safeSetState(() {});
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error: ${e.toString()}'),
                                          ),
                                        );
                                      }
                                    } else {
                                      _model.isLoading = false;
                                      _model.errorMessage =
                                          'Please input your phone number to continue';
                                      safeSetState(() {});
                                      if (!context.mounted) return;
                                      await showDialog(
                                        context: context,
                                        builder: (alertDialogContext) =>
                                            AlertDialog(
                                          title: const Text(
                                              'Phone number is empty'),
                                          content: const Text(
                                              'Please input your phone number to continue'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      alertDialogContext),
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    safeSetState(() {});
                                  },
                            text: _model.isLoading ? 'Signing Up...' : 'Sign Up',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: MediaQuery.sizeOf(context).width * 0.13,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 0, 16, 0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 0),
                              color: _model.isLoading
                                  ? AppTheme.of(context).alternate
                                  : AppTheme.of(context).primary,
                              textStyle: AppTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: AppTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: AppTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                              elevation: 0,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ].divide(const SizedBox(height: 16)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
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
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(SigninWidget.routeName);
                            },
                            child: Text(
                              'Sign In',
                              style: AppTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: AppTheme.of(context).primary,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ].divide(const SizedBox(height: 24)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
