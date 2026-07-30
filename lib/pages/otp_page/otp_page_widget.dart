import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
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
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: const Text('Phone Verification'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Icon(Icons.phone_android, size: 64, color: theme.primary),
          const SizedBox(height: 16),
          Text(
            'Verify your phone',
            style: theme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            !_model.codeSent
                ? 'Enter your phone number to receive a one-time code.'
                : 'Enter the 6-digit code sent to your phone.',
            style: theme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!_model.codeSent) ...[
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+63xxxxxxxxxx',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.secondaryBackground,
              ),
              keyboardType: TextInputType.phone,
              onChanged: (v) => _model.phone = v,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _model.sendCode();
                  setState(() {});
                },
                child: _model.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send Code'),
              ),
            ),
          ] else ...[
            TextField(
              decoration: InputDecoration(
                labelText: 'OTP Code',
                hintText: '000000',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.secondaryBackground,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (v) => _model.code = v,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final ok = await _model.verify();
                  if (mounted) {
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verified!')),
                      );
                      context.pop();
                    } else {
                      setState(() {});
                    }
                  }
                },
                child: _model.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify'),
              ),
            ),
            TextButton(
              onPressed:
                  _model.cooldown > 0 || _model.loading ? null : () async {
                    await _model.sendCode();
                    setState(() {});
                  },
              child: Text(
                _model.cooldown > 0
                    ? 'Resend OTP (${_model.cooldown}s)'
                    : 'Resend OTP',
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
