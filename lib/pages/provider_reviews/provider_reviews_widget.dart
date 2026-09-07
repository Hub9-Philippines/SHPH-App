import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

import 'provider_reviews_model.dart';
export 'provider_reviews_model.dart';

class ProviderReviewsWidget extends StatefulWidget {
  const ProviderReviewsWidget({
    super.key,
    required this.providerId,
  });

  final String providerId;

  static String routeName = 'ProviderReviews';
  static String routePath = '/provider/:providerId/reviews';

  @override
  State<ProviderReviewsWidget> createState() => _ProviderReviewsWidgetState();
}

class _ProviderReviewsWidgetState extends State<ProviderReviewsWidget> {
  late final ProviderReviewsModel _model;
  bool _loadMoreInFlight = false;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProviderReviewsModel.new);
    _model.loadInitialChunk(widget.providerId).then((chunk) {
      if (mounted) {
        safeSetState(() {
          _model.reviews.addAll(chunk);
        });
      }
    });
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
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.ppfReviews,
          titleStyle: theme.titleMedium,
        ),
      ),
      body: _model.isLoading
          ? const Center(child: AppActivityIndicator())
          : _model.provider == null
              ? _buildError(theme)
              : _buildContent(context, theme),
    );
  }

  Widget _buildError(AppThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_rounded, size: 64, color: theme.textTertiary),
            const SizedBox(height: 16),
            Text(
              _l10n.ppfNotFound,
              style: GoogleFonts.plusJakartaSans(
                color: theme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_model.topListings.isEmpty)
            _buildEmpty(theme, _l10n.ppfNoReviews)
          else
            _buildReviewsList(theme),
          const SizedBox(height: 12),
          if (_model.hasMore)
            _buildLoadMore(theme)
          else
            const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewsList(AppThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _model.reviews.length,
      separatorBuilder: (_, __) => const Divider(height: 1),

      itemBuilder: (context, index) {
        final r = _model.reviews[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.primary,
                backgroundImage: r['reviewerPhoto'] != null && (r['reviewerPhoto'] as String).isNotEmpty
                    ? NetworkImage(r['reviewerPhoto'] as String)
                    : null,
                child: r['reviewerPhoto'] == null || (r['reviewerPhoto'] as String).isEmpty
                    ? Icon(Icons.person, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['reviewerName']?.toString() ?? _l10n.ppfAnonymous,
                      style: GoogleFonts.plusJakartaSans(
                        color: theme.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (r['serviceTitle'] != null && (r['serviceTitle'] as String).isNotEmpty) ...[
                      Text(
                        r['serviceTitle'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: theme.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: theme.warning),
                        const SizedBox(width: 4),
                        Text(
                          _starsText(r['rating']),
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (r['comment'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        r['comment'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          color: theme.primaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(r['createdAt']?.toString()),
                      style: GoogleFonts.plusJakartaSans(
                        color: theme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadMore(AppThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Center(
        child: _loadMoreInFlight
            ? const AppActivityIndicator()
            : TextButton(
                onPressed: _loadMoreReviews,
                style: TextButton.styleFrom(
                  foregroundColor: theme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppThemeData.radiusSm)),
                  ),
                ),
                child: Text(
                  _l10n.ppfLoadMoreReviews,
                  style: GoogleFonts.plusJakartaSans(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _loadMoreReviews() async {
    if (_loadMoreInFlight || !_model.hasMore) {
      return;
    }
    _loadMoreInFlight = true;
    try {
      final next = await _model.loadNextChunk();
      if (mounted) {
        safeSetState(() {
          _model.reviews.addAll(next);
        });
      }
    } finally {
      if (mounted) {
        safeSetState(() {
          _loadMoreInFlight = false;
        });
      }
    }
  }

  Widget _buildEmpty(AppThemeData theme, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          Icon(Icons.forum_outlined, color: theme.textTertiary, size: 28),
          const SizedBox(height: 8),
          Text(message, style: theme.bodySmall),
        ],
      ),
    );
  }

  String _starsText(dynamic rating) {
    final value = _asDouble(rating);
    if (value <= 0) {
      return '';
    }
    return value.toStringAsFixed(1);
  }

  String _timeAgo(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    try {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) {
        return value;
      }
      final now = DateTime.now();
      final diff = now.difference(parsed);

      if (diff.inDays > 365) {
        return '${(diff.inDays / 365).floor()} mo ago';
      }
      if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()} mo ago';
      }
      if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      }
      if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      }
      if (diff.inMinutes > 0) {
        return 'just now';
      }
      return 'just now';
    } catch (_) {
      return value;
    }
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
