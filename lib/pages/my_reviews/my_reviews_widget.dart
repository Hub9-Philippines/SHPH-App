import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/shph_api.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'my_reviews_model.dart';

export 'my_reviews_model.dart';

class MyReviewsWidget extends StatefulWidget {
  const MyReviewsWidget({super.key});

  static String routeName = 'MyReviews';
  static String routePath = '/my-reviews';

  @override
  State<MyReviewsWidget> createState() => _MyReviewsWidgetState();
}

class _MyReviewsWidgetState extends State<MyReviewsWidget> {
  late MyReviewsModel _model;
  late Future<List<_UserReviewItem>> _reviewsFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, MyReviewsModel.new);
    _loadReviews();
  }

  void _loadReviews() {
    _reviewsFuture = _fetchReviews();
  }

  Future<List<_UserReviewItem>> _fetchReviews() async {
    try {
      final reviews = await ShphServicesApi.instance.listMyReviews();
      return reviews.map((review) {
        final listing = review['service_listing'] as Map<String, dynamic>?;
        return _UserReviewItem(review: review, service: listing);
      }).toList();
    } catch (e, stackTrace) {
      LoggingService.error('Failed to load user reviews', tag: 'MyReviews', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _refreshReviews() async {
    _loadReviews();
    if (mounted) {
      safeSetState(() {});
      await _reviewsFuture;
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
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: wrapWithModel(
                          model: _model.backButtonModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const BackButtonWidget(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Reviews',
                              style: AppTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: const Color(0xFF14213D),
                                  ),
                            ),
                            Text(
                              'Track every service you rated and revisit your feedback.',
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.poppins(),
                                    color: const Color(0xFF64748B),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<_UserReviewItem>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState();
                      }

                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return _buildEmptyState();
                      }

                      final stats = _ReviewStats.fromReviews(reviews);
                      return RefreshIndicator(
                        color: AppTheme.of(context).primary,
                        onRefresh: _refreshReviews,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                          children: [
                            _buildHeroCard(stats),
                            const SizedBox(height: 18),
                            ...reviews.map(
                              (review) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildReviewCard(review),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeroCard(_ReviewStats stats) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1D3557),
              Color(0xFF2A5F8F),
              Color(0xFF4FB0C6),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.rate_review_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your feedback footprint',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Useful for tracking what services delivered the best experience.',
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.poppins(),
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildHeroMetric(
                    label: 'Reviews',
                    value: '${stats.count}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHeroMetric(
                    label: 'Average',
                    value: stats.average.toStringAsFixed(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHeroMetric(
                    label: '5 stars',
                    value: '${stats.fiveStarCount}',
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildHeroMetric({
    required String label,
    required String value,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(),
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.rate_review_outlined,
                    size: 34,
                    color: AppTheme.of(context).primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'No reviews yet',
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                        color: const Color(0xFF14213D),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Once you rate completed services, they will appear here with the service details and your score.',
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(),
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildErrorState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.of(context).error,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load your reviews',
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull to refresh or try again now.',
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(),
                      color: const Color(0xFF64748B),
                    ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  _loadReviews();
                  safeSetState(() {});
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );

  Widget _buildReviewCard(_UserReviewItem item) {
    final review = item.review;
    final createdAt = review['created_at'] as String? ?? '';
    final date = DateTime.tryParse(createdAt) ?? DateTime.now();
    final rating = (review['rating'] as num?)?.toInt() ?? 0;

    final serviceTitle = item.service?['title'] as String? ?? 'Service #${review['service_listing_id']}';
    final category = item.service?['category_name'] as String? ?? 'Service';
    final providerName = item.service?['provider_name'] as String? ?? 'Service Provider';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _categoryIcon(category),
                  color: AppTheme.of(context).primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceTitle,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                            color: const Color(0xFF14213D),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$category • $providerName',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(date),
                style: AppTheme.of(context).labelSmall.override(
                      font: GoogleFonts.poppins(),
                      color: const Color(0xFF94A3B8),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: FaIcon(
                    index < rating
                        ? FontAwesomeIcons.solidStar
                        : FontAwesomeIcons.star,
                    color: const Color(0xFFFFB703),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$rating/5',
                style: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      color: const Color(0xFF14213D),
                    ),
              ),
            ],
          ),
          if ((review['comment'] as String? ?? review['review'] as String? ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              (review['comment'] as String? ?? review['review'] as String? ?? '').trim(),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(),
                    color: const Color(0xFF475569),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('clean')) {
      return Icons.cleaning_services_rounded;
    }
    if (normalized.contains('plumb')) {
      return Icons.plumbing_rounded;
    }
    if (normalized.contains('electric')) {
      return Icons.electrical_services_rounded;
    }
    if (normalized.contains('paint')) {
      return Icons.format_paint_rounded;
    }
    if (normalized.contains('lock')) {
      return Icons.lock_open_rounded;
    }
    return Icons.home_repair_service_rounded;
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _UserReviewItem {
  const _UserReviewItem({
    required this.review,
    required this.service,
  });

  final Map<String, dynamic> review;
  final Map<String, dynamic>? service;
}

class _ReviewStats {
  const _ReviewStats({
    required this.count,
    required this.average,
    required this.fiveStarCount,
  });

  factory _ReviewStats.fromReviews(List<_UserReviewItem> reviews) {
    final count = reviews.length;
    final total = reviews.fold<int>(
      0,
      (sum, item) => sum + ((item.review['rating'] as num?)?.toInt() ?? 0),
    );
    final fiveStarCount =
        reviews.where((item) => (item.review['rating'] as num?)?.toInt() == 5).length;

    return _ReviewStats(
      count: count,
      average: count == 0 ? 0 : total / count,
      fiveStarCount: fiveStarCount,
    );
  }

  final int count;
  final double average;
  final int fiveStarCount;
}
