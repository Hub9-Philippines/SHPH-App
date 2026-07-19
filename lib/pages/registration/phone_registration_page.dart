import 'package:flutter/material.dart';

import '/api/resources/auth_api.dart';
import '/auth/test_phone_accounts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'registration_otp_page.dart';
import 'registration_validation.dart';

class PhoneRegistrationPage extends StatefulWidget {
  const PhoneRegistrationPage({super.key, this.initialPhone = ''});

  final String initialPhone;

  static const routeName = 'PhoneRegistration';
  static const routePath = '/register/phone';

  @override
  State<PhoneRegistrationPage> createState() => _PhoneRegistrationPageState();
}

class _PhoneRegistrationPageState extends State<PhoneRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phone.text = widget.initialPhone.trim();
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _email,
      _phone,
      _password,
      _confirmPassword,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final role = TestPhoneAccounts.apiRole(FFAppState().tempsignuprole);
    try {
      final response = await ShphAuthApi.instance.registerInitiate(payload: {
        'first_name': _firstName.text.trim(),
        'last_name': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phone_number': _phone.text.trim(),
        'password': _password.text,
        'role': role,
      });
      if (!mounted) {
        return;
      }
      context.pushReplacementNamed(
        RegistrationOtpPage.routeName,
        extra: {
          'phone': _phone.text.trim(),
          'email': _email.text.trim(),
          'delivery_method': response['delivery_method']?.toString() ?? 'sms',
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Registration could not be started. Check the details and retry.');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              TestPhoneAccounts.apiRole(FFAppState().tempsignuprole) ==
                      'provider'
                  ? 'Professional registration'
                  : 'Client registration',
              style: theme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'We will send a verification code after validating your details.',
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _nameField(_firstName, 'First name')),
                const SizedBox(width: 12),
                Expanded(child: _nameField(_lastName, 'Last name')),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('registration_email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: RegistrationValidation.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('registration_phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '+639123456789',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: RegistrationValidation.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('registration_password'),
              controller: _password,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
              validator: RegistrationValidation.password,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('registration_confirm_password'),
              controller: _confirmPassword,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) => value != _password.text
                  ? 'Passwords do not match'
                  : RegistrationValidation.password(value),
              onFieldSubmitted: (_) => _submitting ? null : _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('registration_submit'),
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(_submitting ? 'Sending code…' : 'Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nameField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label),
        validator: RegistrationValidation.requiredName,
      );
}
