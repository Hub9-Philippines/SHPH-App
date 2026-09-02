import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/database/tables/reviews.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/services/logging_service.dart';
import '/services/reviews_service.dart';
import '/theme/app_theme.dart';
import 'reviews_model.dart';

export 'reviews_model.dart';

class ReviewsWidget extends StatefulWidget {
  const ReviewsWidget({
    required this.serviceId, required this.serviceName, super.key,
  });

  static String routeName = 'Reviews';
  static String routePath = '/reviews';

  final int serviceId;
  final String serviceName;

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  late ReviewsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<ReviewsRow> _reviews = [];
  bool _isLoading = false;
  bool _hasError = false;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ReviewsModel.new);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response =
          await ReviewsService.instance.getServiceReviews(widget.serviceId);
      if (mounted) {
        setState(() {
          _reviews = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error(
        'Failed to load reviews',
        tag: 'Reviews',
        error: e,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return _l10n.rvMinAgo(difference.inMinutes);
      }
      return _l10n.rvHoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return _l10n.rvDayAgo;
    } else if (difference.inDays < 7) {
      return _l10n.rvDaysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      return _l10n.rvWeeksAgo((difference.inDays / 7).floor());
    } else {
      return _l10n.rvMonthsAgo((difference.inDays / 30).floor());
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: CupertinoPageHeader(
              backgroundColor: AppTheme.of(context).primaryBackground,
              leading: wrapWithModel(
                model: _model.backButtonModel,
                updateCallback: () => safeSetState(() {}),
                child: const BackButtonWidget(),
              ),
              title: _l10n.rvTitle,
              titleStyle: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
            ),
          ),
          body: SafeArea(
            top: true,
            child: _isLoading
                ? const Center(child: AppActivityIndicator())
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              _l10n.rvError,
                              style: AppTheme.of(context).bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              onPressed: _loadReviews,
                              child: Text(_l10n.rvRetry),
                            ),
                          ],
                        ),
                      )
                    : _reviews.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 64,
                                  color: AppTheme.of(context).secondaryText,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _l10n.rvNoReviews,
                                  style: AppTheme.of(context).titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _l10n.rvBeFirst(widget.serviceName),
                                  style: AppTheme.of(context).bodySmall.override(
                                        color: AppTheme.of(context).secondaryText,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _reviews.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final review = _reviews[index];
                              return _buildReviewCard(context, review);
                            },
                          ),
          ),
        ),
      );

  Widget _buildReviewCard(BuildContext context, ReviewsRow review) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).accent2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userId.substring(0, 2).toUpperCase(),
                    style: AppTheme.of(context)
                        .bodyMedium
                        .override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _l10n.rvUser,
                      style: AppTheme.of(context)
                          .bodyMedium
                          .override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                    Row(
                      children: List.generate(
                        review.rating,
                        (index) => const FaIcon(
                          FontAwesomeIcons.solidStar,
                          color: Colors.orange,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ],
      ),
    );
}
