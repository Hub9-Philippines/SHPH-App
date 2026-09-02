import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'otp_page_model.dart';

export 'otp_page_model.dart';

class OtpPageWidget extends StatefulWidget {
  const OtpPageWidget({super.key, this.initialPhone});

  final String? initialPhone;

  static String routeName = 'OtpPage';
  static String routePath = '/otp';

  @override
  State<OtpPageWidget> createState() => _OtpPageWidgetState();
}

class _OtpPageWidgetState extends State<OtpPageWidget> {
  late OtpPageModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, OtpPageModel.new);
    if (widget.initialPhone != null) {
      _model.phone = widget.initialPhone!;
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.otpTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Icon(Icons.phone_android, size: 64, color: theme.primary),
          const SizedBox(height: 16),
          Text(
            _l10n.otpVerifyPhone,
            style: theme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            !_model.codeSent
                ? _l10n.otpEnterPhone
                : _l10n.otpEnterCode,
            style: theme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!_model.codeSent) ...[
            AppTextField(
              label: _l10n.otpPhoneNumber,
              placeholder: _l10n.otpPhonePlaceholder,
              radius: 12,
              fillColor: theme.secondaryBackground,
              keyboardType: TextInputType.phone,
              onChanged: (v) => _model.phone = v,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: () async {
                  await _model.sendCode(_l10n);
                  setState(() {});
                },
                loading: _model.loading,
                child: Text(_l10n.otpSendCode),
              ),
            ),
          ] else ...[
            AppTextField(
              label: _l10n.otpCodeLabel,
              placeholder: _l10n.otpCodePlaceholder,
              radius: 12,
              fillColor: theme.secondaryBackground,
              keyboardType: TextInputType.number,
              maxLength: 6,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              onChanged: (v) => _model.code = v,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: () async {
                  final ok = await _model.verify(_l10n);
                  if (mounted) {
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_l10n.otpVerified)),
                      );
                      context.pop();
                    } else {
                      setState(() {});
                    }
                  }
                },
                loading: _model.loading,
                child: Text(_l10n.otpVerify),
              ),
            ),
            AppButton(
              onPressed:
                  _model.cooldown > 0 || _model.loading ? null : () async {
                    await _model.sendCode(_l10n);
                    setState(() {});
                  },
              variant: AppButtonVariant.text,
              child: Text(
                _model.cooldown > 0
                    ? _l10n.otpResendCooldown(_model.cooldown)
                    : _l10n.otpResend,
              ),
            ),
          ],
          if (_model.error != null) ...[
            const SizedBox(height: 8),
            Text(_model.error!,
                style: TextStyle(color: theme.error),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
