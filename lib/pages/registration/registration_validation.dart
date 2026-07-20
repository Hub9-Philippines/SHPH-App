class RegistrationValidation {
  RegistrationValidation._();

  static String? requiredName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Required';
    }
    if (text.length < 2) {
      return 'Enter at least 2 characters';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) =>
      RegExp(r'^\+639\d{9}$').hasMatch(value?.trim() ?? '')
          ? null
          : 'Use +639XXXXXXXXX';

  static String? password(String? value) {
    final text = value ?? '';
    if (text.length < 8) {
      return 'Use at least 8 characters';
    }
    if (!RegExp('[A-Z]').hasMatch(text) ||
        !RegExp('[a-z]').hasMatch(text) ||
        !RegExp(r'\d').hasMatch(text)) {
      return 'Include upper, lower, and numeric characters';
    }
    return null;
  }
}
