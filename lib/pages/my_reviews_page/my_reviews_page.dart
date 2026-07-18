import 'package:flutter/material.dart';

import '/api/resources/reviews_api.dart';
import '/theme/app_theme.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  static String routeName = 'MyReviewsPage';
  static String routePath = '/my-reviews-page';

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final data = await ShphReviewsApi.instance.getMine();
      if (mounted) {
        setState(() {
          _reviews = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reviews: $e')),
        );
      }
    }
  }

  Future<void> _replyToReview(int reviewId) async {
    final reply = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reply to Review'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Write your reply...',
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Post Reply'),
            ),
          ],
        );
      },
    );
    if (reply == null || reply.isEmpty) {
      return;
    }

    try {
      await ShphReviewsApi.instance.replyReview(reviewId, reply);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply posted')),
        );
        await _loadReviews();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post reply: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('My Reviews',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) =>
                        _buildReviewCard(theme, _reviews[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined,
                size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No reviews yet',
                style: theme.bodyMedium.override(color: theme.secondaryText)),
          ],
        ),
      );

  Widget _buildReviewCard(AppThemeData theme, Map<String, dynamic> review) {
    final id = int.tryParse(review['id']?.toString() ?? '') ?? 0;
    final clientName = review['client_name'] as String? ?? 'Anonymous';
    final rating = review['rating'] as int? ?? 0;
    final comment = review['comment'] as String? ?? '';
    final serviceName = review['service_name'] as String?;
    final providerReply = review['provider_reply'] as String?;
    final createdAt = review['created_at'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(clientName,
                  style:
                      theme.titleSmall.override(fontWeight: FontWeight.w700)),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: theme.warning,
                  ),
                ),
              ),
            ],
          ),
          if (serviceName != null) ...[
            const SizedBox(height: 4),
            Text(serviceName,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
          const SizedBox(height: 8),
          Text(comment, style: theme.bodyMedium),
          if (createdAt != null) ...[
            const SizedBox(height: 4),
            Text(createdAt,
                style: theme.labelSmall.override(color: theme.secondaryText)),
          ],
          if (providerReply != null && providerReply.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Reply',
                      style: theme.labelSmall
                          .override(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(providerReply, style: theme.bodySmall),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _replyToReview(id),
                child: const Text('Reply'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
