import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/api/resources/auth_api.dart';
import '/api/resources/users_api.dart';
import '/auth/post_auth_navigation_flow.dart';
import '/flutter_flow/otp_rate_limiter.dart';
import '/theme/app_theme.dart';

class RegistrationOtpPage extends StatefulWidget {
  const RegistrationOtpPage({
    required this.phone,
    required this.email,
    super.key,
    this.deliveryMethod = 'sms',
  });

  final String phone;
  final String email;
  final String deliveryMethod;

  static const routeName = 'RegistrationOtp';
  static const routePath = '/register/verify';

  @override
  State<RegistrationOtpPage> createState() => _RegistrationOtpPageState();
}

class _RegistrationOtpPageState extends State<RegistrationOtpPage> {
  final _pin = TextEditingController();
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_pin.text.length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final data = await ShphAuthApi.instance.registerVerify(payload: {
        'phone_number': widget.phone,
        'pin': _pin.text,
      });
      var user = data;
      try {
        user = await ShphUsersApi.instance.getMe();
      } catch (_) {}
      final userId = user['id']?.toString() ?? data['user_id']?.toString();
      if (userId == null || userId.isEmpty) {
        throw StateError('Registration completed without a user identifier.');
      }
      OtpRateLimiter().clearPhoneNumber(widget.phone);
      if (!mounted) {
        return;
      }
      await PostAuthNavigationFlow().handlePostAuthNavigation(
        context: context,
        userId: userId,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Invalid or expired code.');
      }
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
      }
    }
  }

  Future<void> _resend() async {
    final limiter = OtpRateLimiter();
    final rateError = limiter.validateOtpRequest(widget.phone);
    if (rateError != null) {
      setState(() => _error = rateError);
      return;
    }
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await ShphAuthApi.instance.registerResend(payload: {
        'phone_number': widget.phone,
      });
      limiter.recordOtpRequest(widget.phone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new code was sent.')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not resend the code.');
      }
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final destination = widget.deliveryMethod == 'email'
        ? widget.email
        : _maskedPhone(widget.phone);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify registration')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.mark_email_read_outlined, size: 64, color: theme.primary),
          const SizedBox(height: 20),
          Text('Enter your verification code',
              textAlign: TextAlign.center, style: theme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'We sent a 6-digit code to $destination.',
            textAlign: TextAlign.center,
            style: theme.bodyMedium.copyWith(color: theme.secondaryText),
          ),
          const SizedBox(height: 28),
          TextField(
            key: const Key('registration_otp'),
            controller: _pin,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.headlineMedium,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Verification code',
              counterText: '',
            ),
            onSubmitted: (_) => _verifying ? null : _verify(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('registration_verify'),
            onPressed: _verifying ? null : _verify,
            child: Text(_verifying ? 'Verifying…' : 'Verify account'),
          ),
          TextButton(
            onPressed: _resending || _verifying ? null : _resend,
            child: Text(_resending ? 'Sending…' : 'Resend code'),
          ),
        ],
      ),
    );
  }

  String _maskedPhone(String phone) => phone.length < 6
      ? phone
      : '${phone.substring(0, 4)}••••${phone.substring(phone.length - 3)}';
}
