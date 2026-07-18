import 'package:flutter/material.dart';

import '/services/logging_service.dart';

class StepUpAuthService {
  StepUpAuthService._();
  static final StepUpAuthService instance = StepUpAuthService._();

  Future<String?> requireStepUp(BuildContext context) async {
    // Try biometric first if available
    try {
      final biometricResult = await _tryBiometric();
      if (biometricResult != null) return biometricResult;
    } catch (e) {
      LoggingService.info('Biometric step-up failed: $e', tag: 'StepUpAuth');
    }

    // Fall back to password re-entry
    return _showPasswordModal(context);
  }

  Future<String?> _tryBiometric() async {
    // Check if local_auth is available and user has biometrics
    // For now, return null — biometric step-up requires platform integration
    return null;
  }

  Future<String?> _showPasswordModal(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'For your security, please re-enter your password to continue.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final password = controller.text.trim();
              if (password.isEmpty) return;
              Navigator.of(context).pop(password);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
