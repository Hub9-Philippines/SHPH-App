import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/services/provider_bookings_service.dart';
import 'write_review_widget.dart' show WriteReviewWidget;

class WriteReviewModel extends FlutterFlowModel<WriteReviewWidget> {
  int rating = 0;
  String comment = '';
  bool submitting = false;
  String? error;

  @override
  void initState(BuildContext context) {}

  Future<bool> submitReview(String bookingId, AppLocalizations l10n) async {
    if (rating == 0) {
      error = l10n.wrSelectRating;
      return false;
    }
    submitting = true;
    error = null;
    try {
      final ok = await ProviderBookingsService.instance
          .createReview(bookingId, rating: rating, comment: comment.trim());
      return ok;
    } catch (e) {
      error = l10n.wrFailed;
      return false;
    } finally {
      submitting = false;
    }
  }

  @override
  void dispose() {}
}
