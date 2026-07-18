import 'package:flutter/material.dart';

import '/api/resources/recommendations_api.dart';
import '/theme/app_theme.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  static String routeName = 'Recommendations';
  static String routePath = '/recommendations';

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _userRecs = [];
  List<Map<String, dynamic>> _trending = [];
  List<Map<String, dynamic>> _nearby = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ShphRecommendationsApi.instance.getUserRecommendations(),
        ShphRecommendationsApi.instance.getTrendingServices(),
        ShphRecommendationsApi.instance.getNearbyRecommendations(),
      ]);
      if (mounted) {
        setState(() {
          _userRecs = results[0];
          _trending = results[1];
          _nearby = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recommendations: $e')),
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
        title: Text('Recommendations',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primary,
          unselectedLabelColor: theme.secondaryText,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Trending'),
            Tab(text: 'Nearby'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                    theme, _userRecs, 'No personalized recommendations yet'),
                _buildList(theme, _trending, 'No trending services'),
                _buildList(theme, _nearby, 'No nearby recommendations'),
              ],
            ),
    );
  }

  Widget _buildList(
    AppThemeData theme,
    List<Map<String, dynamic>> items,
    String emptyMessage,
  ) =>
      items.isEmpty
          ? Center(
              child: Text(emptyMessage,
                  style: theme.bodyMedium.override(color: theme.secondaryText)),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _buildRecommendationCard(theme, items[index]),
              ),
            );

  Widget _buildRecommendationCard(
      AppThemeData theme, Map<String, dynamic> item) {
    final name =
        item['name'] as String? ?? item['title'] as String? ?? 'Service';
    final description =
        item['description'] as String? ?? item['bio'] as String? ?? '';
    final rating = double.tryParse(item['rating']?.toString() ?? '0') ?? 0;
    final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
    final categoryName = item['category_name'] as String?;

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
              Expanded(
                child: Text(name,
                    style:
                        theme.titleSmall.override(fontWeight: FontWeight.w700)),
              ),
              if (rating > 0)
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: theme.warning),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1),
                        style: theme.bodyMedium
                            .override(fontWeight: FontWeight.w700)),
                  ],
                ),
            ],
          ),
          if (categoryName != null) ...[
            const SizedBox(height: 4),
            Text(categoryName,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description,
                style: theme.bodyMedium.override(color: theme.secondaryText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          if (price > 0) ...[
            const SizedBox(height: 8),
            Text('PHP ${price.toStringAsFixed(2)}',
                style: theme.bodyMedium.override(
                  fontWeight: FontWeight.w700,
                  color: theme.primary,
                )),
          ],
        ],
      ),
    );
  }
}
