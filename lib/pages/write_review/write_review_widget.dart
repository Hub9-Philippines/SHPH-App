import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'write_review_model.dart';

export 'write_review_model.dart';

class WriteReviewWidget extends StatefulWidget {
  const WriteReviewWidget({
    required this.bookingId, super.key,
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.wrTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (widget.serviceName != null) ...[
            Text(widget.serviceName!,
                style: theme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
          ],
          Text(_l10n.wrExperience,
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
          Text(_l10n.wrTellMore,
              style: theme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          AppTextField(
            maxLines: 5,
            placeholder: _l10n.wrPlaceholder,
            radius: 12,
            fillColor: theme.secondaryBackground,
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
            child: AppButton(
              loading: _model.submitting,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: () async {
                final ok = await _model.submitReview(widget.bookingId, _l10n);
                if (mounted) {
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_l10n.wrSubmitted)),
                    );
                    context.pop();
                  } else {
                    setState(() {});
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(_l10n.wrSubmit),
                ],
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
    required this.rating, required this.size, required this.onChanged, super.key,
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
