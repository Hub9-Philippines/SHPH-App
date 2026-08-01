import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/models/review.dart';
import '/api/resources/providers_api.dart';
import '/auth/base_auth_user_provider.dart';
import '/components/screen_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';

class ReviewsRatingsWidget extends StatefulWidget {
  const ReviewsRatingsWidget({super.key});

  static const String routeName = 'ReviewsRatings';
  static const String routePath = '/pro/reviews-ratings';

  @override
  State<ReviewsRatingsWidget> createState() => _ReviewsRatingsWidgetState();
}

class _ReviewsRatingsWidgetState extends State<ReviewsRatingsWidget> {
  List<Map<String, dynamic>> _reviews = const [];
  bool _isLoading = true;
  String? _errorMessage;
  _ReviewStats _stats = const _ReviewStats();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        safeSetState(() {
          _reviews = const [];
          _stats = const _ReviewStats();
          _isLoading = false;
        });
        return;
      }

      final page = await ShphProvidersApi.instance
          .listProviderReviews(userId);
      final reviews = page.results
          .map((review) => _reviewToMap(review))
          .where((item) => _readRating(item) > 0)
          .toList();

      safeSetState(() {
        _reviews = reviews;
        _stats = _buildStats(reviews);
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading provider reviews',
        tag: 'ReviewsRatings',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      safeSetState(() {
        _isLoading = false;
        _errorMessage = 'We could not load your reviews right now.';
      });
    }
  }

  Map<String, dynamic> _reviewToMap(ShphReview review) {
    return {
      'rating': review.rating,
      'review': review.comment,
      'created_at': review.createdAt,
      'reviewer_name': review.reviewerName,
      'reviewer_photo': review.reviewerPhoto,
      'service_listings': {
        'title': 'Completed service',
        'category_name': null,
      },
    };
  }

  int _readRating(Map<String, dynamic> review) {
    final value = review['rating'];
    if (value is int) {
      return value.clamp(0, 5);
    }
    if (value is num) {
      return value.round().clamp(0, 5);
    }
    return 0;
  }

  String? _reviewText(Map<String, dynamic> review) {
    final text = (review['review'] ?? review['comment'])?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  DateTime? _reviewDate(Map<String, dynamic> review) {
    final raw = review['rating_created_at'] ??
        review['completed_at'] ??
        review['updated_at'] ??
        review['created_at'];
    final value = raw?.toString();
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  String _clientName(Map<String, dynamic> review) {
    final profile = review['profiles'] as Map<String, dynamic>?;
    final directName = review['reviewer_name'] as String?;
    return (profile?['display_name'] ??
            profile?['full_name'] ??
            profile?['first_name'] ??
            directName ??
            'Client')
        .toString();
  }

  String? _clientPhoto(Map<String, dynamic> review) {
    final profile = review['profiles'] as Map<String, dynamic>?;
    final value = (profile?['photo_url'] ??
            profile?['avatar_url'] ??
            review['reviewer_photo'])
        ?.toString()
        .trim();
    return value == null || value.isEmpty ? null : value;
  }

  String _serviceName(Map<String, dynamic> review) {
    final listing = review['service_listings'] as Map<String, dynamic>?;
    return (listing?['title'] ?? listing?['name'] ?? 'Unknown Service')
        .toString();
  }

  String _serviceCategory(Map<String, dynamic> review) {
    final listing = review['service_listings'] as Map<String, dynamic>?;
    final value = (listing?['category_name'] ??
            listing?['category'] ??
            listing?['service_category'])
        ?.toString()
        .trim();
    return value == null || value.isEmpty ? 'Completed service' : value;
  }

  _ReviewStats _buildStats(List<Map<String, dynamic>> reviews) {
    var totalRating = 0.0;
    var fiveStar = 0;
    var fourStar = 0;
    var threeStar = 0;
    var twoStar = 0;
    var oneStar = 0;
    var withComment = 0;

    for (final review in reviews) {
      final rating = _readRating(review);
      totalRating += rating;
      if (_reviewText(review) != null) {
        withComment++;
      }
      switch (rating) {
        case 5:
          fiveStar++;
          break;
        case 4:
          fourStar++;
          break;
        case 3:
          threeStar++;
          break;
        case 2:
          twoStar++;
          break;
        case 1:
          oneStar++;
          break;
      }
    }

    final total = reviews.length;
    final average = total == 0 ? 0.0 : totalRating / total;

    return _ReviewStats(
      average: average,
      total: total,
      fiveStar: fiveStar,
      fourStar: fourStar,
      threeStar: threeStar,
      twoStar: twoStar,
      oneStar: oneStar,
      withComment: withComment,
    );
  }

  double _ratio(int count) => _stats.total == 0 ? 0 : count / _stats.total;

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays < 1) {
      return 'Today';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: AppTheme.of(context).primaryBackground,
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: 'Reviews & Ratings',
                  subtitle:
                      'Track client sentiment and the quality signals behind your profile.',
                  action: IconButton(
                    onPressed: _loadReviews,
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppTheme.of(context).primary,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.of(context).primary,
                          ),
                        )
                      : _errorMessage != null
                          ? _buildMessageState(
                              context,
                              icon: Icons.rate_review_outlined,
                              title: 'Could not load reviews',
                              subtitle: _errorMessage!,
                              actionLabel: 'Try again',
                              onPressed: _loadReviews,
                              accent: AppTheme.of(context).error,
                            )
                          : RefreshIndicator(
                              color: AppTheme.of(context).primary,
                              onRefresh: _loadReviews,
                              child: ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 28),
                                children: [
                                  const SizedBox(height: 18),
                                  _buildHeroCard(context),
                                  const SizedBox(height: 18),
                                  _buildHighlights(context),
                                  const SizedBox(height: 18),
                                  _buildDistributionCard(context),
                                  const SizedBox(height: 20),
                                  _buildSectionHeader(context),
                                  const SizedBox(height: 12),
                                  if (_reviews.isEmpty)
                                    _buildMessageState(
                                      context,
                                      icon: Icons.star_outline_rounded,
                                      title: 'No reviews yet',
                                      subtitle:
                                          'Complete more jobs and invite feedback to start building social proof here.',
                                      actionLabel: 'Refresh',
                                      onPressed: _loadReviews,
                                      accent: AppTheme.of(context).primary,
                                      compact: true,
                                    )
                                  else
                                    ..._reviews.map(
                                      (review) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildReviewCard(
                                            context, review),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeroCard(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1D3557),
              Color(0xFF2B4D73),
              Color(0xFF4F7DA8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A1D3557),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppTheme.of(context).secondaryBackground.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  _stats.average.toStringAsFixed(1),
                  style: AppTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: AppTheme.of(context).secondaryBackground,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < _stats.average.round()
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFFFC857),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_stats.total} total reviews',
                    style: AppTheme.of(context).titleMedium.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          color: AppTheme.of(context).secondaryBackground,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stats.total == 0
                        ? 'Your rating will appear here as clients leave feedback.'
                        : '${_stats.withComment} reviews include written comments.',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: AppTheme.of(context).secondaryBackground.withValues(alpha: 0.82),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildHighlights(BuildContext context) => Row(
        children: [
          Expanded(
            child: _HighlightCard(
              title: '5-Star',
              value: '${_stats.fiveStar}',
              subtitle: '${(_ratio(_stats.fiveStar) * 100).round()}% share',
              icon: Icons.workspace_premium_rounded,
              color: const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HighlightCard(
              title: 'With Comment',
              value: '${_stats.withComment}',
              subtitle: 'Written feedback received',
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      );

  Widget _buildDistributionCard(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Distribution',
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'See how client ratings are spread across completed jobs.',
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 16),
            _DistributionRow(
              stars: 5,
              count: _stats.fiveStar,
              total: _stats.total,
              color: const Color(0xFF16A34A),
            ),
            const SizedBox(height: 10),
            _DistributionRow(
              stars: 4,
              count: _stats.fourStar,
              total: _stats.total,
              color: const Color(0xFF65A30D),
            ),
            const SizedBox(height: 10),
            _DistributionRow(
              stars: 3,
              count: _stats.threeStar,
              total: _stats.total,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 10),
            _DistributionRow(
              stars: 2,
              count: _stats.twoStar,
              total: _stats.total,
              color: const Color(0xFFF97316),
            ),
            const SizedBox(height: 10),
            _DistributionRow(
              stars: 1,
              count: _stats.oneStar,
              total: _stats.total,
              color: const Color(0xFFEF4444),
            ),
          ],
        ),
      );

  Widget _buildSectionHeader(BuildContext context) => Row(
        children: [
          Text(
            'Recent Reviews',
            style: AppTheme.of(context).titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: AppTheme.of(context).primaryText,
                ),
          ),
          const Spacer(),
          Text(
            '${_reviews.length} total',
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
        ],
      );

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    final clientName = _clientName(review);
    final clientPhoto = _clientPhoto(review);
    final serviceName = _serviceName(review);
    final serviceCategory = _serviceCategory(review);
    final rating = _readRating(review);
    final text = _reviewText(review);
    final date = _reviewDate(review);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  image: clientPhoto == null
                      ? null
                      : DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(clientPhoto),
                        ),
                ),
                child: clientPhoto == null
                    ? Icon(
                        Icons.person_rounded,
                        color: AppTheme.of(context).primary,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                            color: AppTheme.of(context).primaryText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$serviceName • $serviceCategory',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rating/5',
                      style: AppTheme.of(context).labelMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: AppTheme.of(context).warning,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (text != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            date == null ? 'Date unavailable' : _dateLabel(date),
            style: AppTheme.of(context).labelSmall.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: AppTheme.of(context).textTertiary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onPressed,
    required Color accent,
    bool compact = false,
  }) =>
      Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: EdgeInsets.all(compact ? 24 : 28),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppThemeData.shadowCard,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 30, color: accent),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: compact ? 140 : double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: AppTheme.of(context).labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ReviewStats {
  const _ReviewStats({
    this.average = 0,
    this.total = 0,
    this.fiveStar = 0,
    this.fourStar = 0,
    this.threeStar = 0,
    this.twoStar = 0,
    this.oneStar = 0,
    this.withComment = 0,
  });

  final double average;
  final int total;
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;
  final int withComment;
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.of(context).labelSmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: AppTheme.of(context).textTertiary,
                  ),
            ),
          ],
        ),
      );
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.stars,
    required this.count,
    required this.total,
    required this.color,
  });

  final int stars;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            '$stars stars',
            style: AppTheme.of(context).bodySmall.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppTheme.of(context).border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 44,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: AppTheme.of(context).bodySmall.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  color: AppTheme.of(context).primaryText,
                ),
          ),
        ),
      ],
    );
  }
}
