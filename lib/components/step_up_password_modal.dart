import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class StepUpPasswordModal extends StatefulWidget {
  const StepUpPasswordModal({
    super.key,
    required this.title,
    this.onConfirm,
    this.errorMessage,
  });

  final String title;
  final Future<bool> Function(String password)? onConfirm;
  final String? errorMessage;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    Future<bool> Function(String password)? onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StepUpPasswordModal(
        title: title,
        onConfirm: onConfirm,
      ),
    ).then((v) => v ?? false);
  }

  @override
  State<StepUpPasswordModal> createState() => _StepUpPasswordModalState();
}

class _StepUpPasswordModalState extends State<StepUpPasswordModal> {
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Please enter your password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await widget.onConfirm?.call(password) ?? true;
      if (mounted) {
        if (ok) {
          Navigator.of(context).pop(true);
        } else {
          setState(() => _error = widget.errorMessage ?? 'Incorrect password.');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Icon(Icons.lock_rounded, size: 40, color: theme.primary),
          const SizedBox(height: 16),
          Text(widget.title, style: theme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'For your security, please confirm your password to continue.',
            style: TextStyle(color: theme.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            focusNode: _focusNode,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.secondaryBackground,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _confirm(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.onPrimary))
                : const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
