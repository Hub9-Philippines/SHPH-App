import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/api/resources/kyc_api.dart';
import '/theme/app_theme.dart';

/// Review a scanned ID document before submitting for KYC.
///
/// Mirrors `shph-app/src/views/provider/ReviewScanPage.vue`. This is a
/// client-side step — there is no dedicated backend endpoint. The picked
/// image is previewed and then uploaded via `ShphKycApi.submitKyc()`.
class ReviewScanPage extends StatefulWidget {
  const ReviewScanPage({super.key});

  static String routeName = 'ReviewScan';
  static String routePath = '/provider/review-scan';

  @override
  State<ReviewScanPage> createState() => _ReviewScanPageState();
}

class _ReviewScanPageState extends State<ReviewScanPage> {
  File? _front;
  File? _back;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _pick(FileSide side) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() {
      if (side == FileSide.front) {
        _front = File(picked.path);
      } else {
        _back = File(picked.path);
      }
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final file = _front ?? _back;
    if (file == null) {
      setState(() => _errorMessage = 'Please capture at least one side');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final bytes = await file.readAsBytes();
      await ShphKycApi.instance.submitKyc(
        documentBytes: bytes,
        fileName: file.path.split('/').last,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC submitted for review')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Submission failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Review ID Scan',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            'Review your captured ID images before submitting for KYC verification.',
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
          const SizedBox(height: 16),
          _ScanTile(
            label: 'Front of ID',
            file: _front,
            onCapture: () => _pick(FileSide.front),
          ),
          const SizedBox(height: 12),
          _ScanTile(
            label: 'Back of ID (optional)',
            file: _back,
            onCapture: () => _pick(FileSide.back),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: theme.bodyMedium.override(color: theme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_isSubmitting ? 'Submitting…' : 'Submit for KYC'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }
}

enum FileSide { front, back }

class _ScanTile extends StatelessWidget {
  const _ScanTile({
    required this.label,
    required this.file,
    required this.onCapture,
  });

  final String label;
  final File? file;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.bodyMedium.override(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onCapture,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(14),
              image: file != null
                  ? DecorationImage(image: FileImage(file!), fit: BoxFit.cover)
                  : null,
            ),
            child: file == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 40, color: theme.secondaryText),
                        const SizedBox(height: 6),
                        Text('Tap to capture',
                            style: theme.bodyMedium
                                .override(color: theme.secondaryText)),
                      ],
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black54,
                        child: const Icon(Icons.refresh,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
