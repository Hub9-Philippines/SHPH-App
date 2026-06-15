import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/services/logging_service.dart';

class ReviewsRatingsWidget extends StatefulWidget {
  const ReviewsRatingsWidget({super.key});

  static const String routeName = 'ReviewsRatings';
  static const String routePath = '/pro/reviews-ratings';

  @override
  State<ReviewsRatingsWidget> createState() => _ReviewsRatingsWidgetState();
}

class _ReviewsRatingsWidgetState extends State<ReviewsRatingsWidget> {
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  Map<String, dynamic> ratingStats = {
    'average': 0.0,
    'total': 0,
    'fiveStar': 0,
    'fourStar': 0,
    'threeStar': 0,
    'twoStar': 0,
    'oneStar': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      // Fetch reviews from bookings with ratings
      final response = await Supabase.instance.client
          .from('bookings')
          .select('''
            *,
            service_listings(*),
            profiles!bookings_user_id_fkey(*)
          ''')
          .eq('provider_id', userId)
          .not('rating', 'is', 'null')
          .order('rating_created_at', ascending: false);

      // Calculate stats
      double totalRating = 0;
      int fiveStar = 0, fourStar = 0, threeStar = 0, twoStar = 0, oneStar = 0;

      for (final review in response) {
        final rating = review['rating'] as int? ?? 0;
        totalRating += rating;

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

      final totalReviews = response.length;
      final averageRating = totalReviews > 0 ? totalRating / totalReviews : 0.0;

      setState(() {
        reviews = List<Map<String, dynamic>>.from(response);
        ratingStats = {
          'average': averageRating,
          'total': totalReviews,
          'fiveStar': fiveStar,
          'fourStar': fourStar,
          'threeStar': threeStar,
          'twoStar': twoStar,
          'oneStar': oneStar,
        };
        isLoading = false;
      });
    } catch (e) {
      LoggingService.error('Error loading reviews: $e', tag: 'ReviewsRatings');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reviews: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews & Ratings',
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
        ),
        backgroundColor: AppTheme.of(context).primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReviews,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Rating Overview
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.of(context).primary,
                            AppTheme.of(context).primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ratingStats['average'].toStringAsFixed(1),
                                style:
                                    AppTheme.of(context).displayMedium.override(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < ratingStats['average'].round()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  Text(
                                    '${ratingStats['total']} reviews',
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          color: Colors.white70,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Rating Distribution
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating Distribution',
                            style: AppTheme.of(context).titleMedium.override(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildRatingBar(
                              5, ratingStats['fiveStar'], ratingStats['total']),
                          _buildRatingBar(
                              4, ratingStats['fourStar'], ratingStats['total']),
                          _buildRatingBar(3, ratingStats['threeStar'],
                              ratingStats['total']),
                          _buildRatingBar(
                              2, ratingStats['twoStar'], ratingStats['total']),
                          _buildRatingBar(
                              1, ratingStats['oneStar'], ratingStats['total']),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Reviews List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Recent Reviews',
                            style: AppTheme.of(context).titleMedium.override(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${reviews.length} reviews',
                            style: AppTheme.of(context).bodyMedium.override(
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.star_outline,
                              size: 64,
                              color: AppTheme.of(context).secondaryText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reviews yet',
                              style: AppTheme.of(context).bodyLarge.override(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete jobs to get reviews from clients',
                              style: AppTheme.of(context).bodySmall.override(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildReviewCard(reviews[index]);
                        },
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$stars ★',
              style: AppTheme.of(context).bodySmall,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: AppTheme.of(context).primaryBackground,
                valueColor: AlwaysStoppedAnimation<Color>(
                  stars >= 4
                      ? AppTheme.of(context).success
                      : stars >= 3
                          ? AppTheme.of(context).warning
                          : AppTheme.of(context).error,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '$count',
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final profile = review['profiles'] as Map<String, dynamic>?;
    final serviceListing = review['service_listings'] as Map<String, dynamic>?;

    final clientName =
        profile?['display_name'] ?? profile?['first_name'] ?? 'Unknown Client';
    final clientPhoto = profile?['photo_url'];
    final serviceName = serviceListing?['name'] ?? 'Unknown Service';
    final rating = review['rating'] as int? ?? 0;
    final reviewText = review['review'] as String?;
    final createdAt = review['rating_created_at'] != null
        ? DateTime.parse(review['rating_created_at'])
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary,
                  shape: BoxShape.circle,
                  image: clientPhoto != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(clientPhoto),
                        )
                      : null,
                ),
                child: clientPhoto == null
                    ? const Icon(Icons.person, color: Colors.white, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: AppTheme.of(context).bodyLarge.override(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      serviceName,
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          if (reviewText != null && reviewText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              reviewText,
              style: AppTheme.of(context).bodyMedium,
            ),
          ],
          if (createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatDate(createdAt),
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
