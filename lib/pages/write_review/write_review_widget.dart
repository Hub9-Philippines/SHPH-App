import 'package:flutter/material.dart';

import '/components/star_rating.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'write_review_model.dart';

export 'write_review_model.dart';

class WriteReviewWidget extends StatefulWidget {
  const WriteReviewWidget({
    super.key,
    required this.bookingId,
    this.serviceName,
  });

  final String bookingId;
  final String? serviceName;

  static String routeName = 'WriteReview';
  static String routePath = '/write-review/:bookingId';

  @override
  State<WriteReviewWidget> createState() => _WriteReviewWidgetState();
}

class _WriteReviewWidgetState extends State<WriteReviewWidget> {
  late WriteReviewModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, WriteReviewModel.new);
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
        title: const Text('Write a Review'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (widget.serviceName != null) ...[
            Text(widget.serviceName!,
                style: theme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
          ],
          Text('How was your experience?',
              style: theme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Center(
            child: StarRatingInput(
              rating: _model.rating,
              size: 40,
              onChanged: (v) => setState(() => _model.rating = v),
            ),
          ),
          const SizedBox(height: 24),
          Text('Tell us more (optional)',
              style: theme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextField(
            maxLines: 5,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: 'Share details about your experience...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.secondaryBackground,
            ),
            onChanged: (v) => _model.comment = v,
          ),
          if (_model.error != null) ...[
            const SizedBox(height: 8),
            Text(_model.error!,
                style: TextStyle(color: theme.error), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final ok = await _model.submitReview(widget.bookingId);
                if (mounted) {
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review submitted!')),
                    );
                    context.pop();
                  } else {
                    setState(() {});
                  }
                }
              },
              icon: _model.submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.star, size: 18),
              label: const Text('Submit Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.rating,
    required this.size,
    required this.onChanged,
  });

  final int rating;
  final double size;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => onChanged(star),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              star <= rating ? Icons.star : Icons.star_border,
              size: size,
              color: star <= rating ? theme.warning : theme.textTertiary,
            ),
          ),
        );
      }),
    );
  }
}
