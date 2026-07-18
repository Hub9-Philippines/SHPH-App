import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/services/gemini_models.dart';
import '/services/gemini_service.dart';
import '/theme/app_theme.dart';

/// Photo diagnosis widget — lets user pick/capture a photo and get an AI
/// diagnosis of the problem. Mirrors `useDiagnosePhoto` composable from Vue.
///
/// When Gemini AI is disabled, the widget degrades to a simple photo picker
/// with a message that AI diagnosis is unavailable.
class PhotoDiagnosisWidget extends StatefulWidget {
  const PhotoDiagnosisWidget({
    super.key,
    this.categoryName,
    this.suggestedMin,
    this.suggestedMax,
    this.onDiagnosis,
  });

  final String? categoryName;
  final double? suggestedMin;
  final double? suggestedMax;
  final ValueChanged<PhotoDiagnosis>? onDiagnosis;

  @override
  State<PhotoDiagnosisWidget> createState() => _PhotoDiagnosisWidgetState();
}

class _PhotoDiagnosisWidgetState extends State<PhotoDiagnosisWidget> {
  final _picker = ImagePicker();
  File? _selectedImage;
  GeminiImage? _geminiImage;
  PhotoDiagnosis? _diagnosis;
  bool _loading = false;
  String? _error;

  bool get _aiEnabled => GeminiService.instance.isEnabled;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final bytes = await file.readAsBytes();

      setState(() {
        _selectedImage = file;
        _geminiImage = GeminiImage(bytes: bytes, mimeType: 'image/jpeg');
        _diagnosis = null;
        _error = null;
      });

      if (_aiEnabled) {
        unawaited(_runDiagnosis());
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick image: $e');
    }
  }

  Future<void> _runDiagnosis() async {
    if (_geminiImage == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await GeminiService.instance.diagnosePhoto(
      image: _geminiImage!,
      categoryName: widget.categoryName,
      suggestedMin: widget.suggestedMin,
      suggestedMax: widget.suggestedMax,
    );

    if (mounted) {
      setState(() {
        _diagnosis = result;
        _loading = false;
        if (result != null && result.isValid) {
          widget.onDiagnosis?.call(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo Diagnosis',
            style: theme.titleSmall.override(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_selectedImage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Retake'),
              ),
              const Spacer(),
              if (_aiEnabled && _diagnosis == null && !_loading)
                TextButton.icon(
                  onPressed: _runDiagnosis,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Diagnose'),
                ),
            ],
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take Photo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
        if (!_aiEnabled && _selectedImage != null) ...[
          const SizedBox(height: 8),
          Text(
            'AI diagnosis is currently unavailable. The photo will be shared with your booking.',
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        ],
        if (_loading) ...[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: theme.bodySmall.override(color: theme.error)),
        ],
        if (_diagnosis != null && _diagnosis!.isValid) ...[
          const SizedBox(height: 12),
          _DiagnosisCard(diagnosis: _diagnosis!),
        ],
      ],
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard({required this.diagnosis});
  final PhotoDiagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: theme.primary),
              const SizedBox(width: 6),
              Text('AI Diagnosis',
                  style:
                      theme.titleSmall.override(fontWeight: FontWeight.w600)),
              const Spacer(),
              _ConfidenceBadge(confidence: diagnosis.confidence),
            ],
          ),
          const SizedBox(height: 8),
          Text(diagnosis.refinedDescription, style: theme.bodyMedium),
          if (diagnosis.parts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Likely parts needed:',
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: diagnosis.parts
                  .map((p) => Chip(
                        label: Text(p, style: theme.bodySmall),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          if (diagnosis.priceRangeHint != null) ...[
            const SizedBox(height: 8),
            Text(
              'Estimated cost: \u20b1${diagnosis.priceRangeHint!.min.toStringAsFixed(0)}\u2013\u20b1${diagnosis.priceRangeHint!.max.toStringAsFixed(0)}',
              style: theme.bodyMedium.override(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});
  final DiagnosisConfidence confidence;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (confidence) {
      DiagnosisConfidence.high => ('High', Colors.green),
      DiagnosisConfidence.medium => ('Medium', Colors.orange),
      DiagnosisConfidence.low => ('Low', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
