import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'recommendations_model.dart';

export 'recommendations_model.dart';

class RecommendationsWidget extends StatefulWidget {
  const RecommendationsWidget({super.key});

  static String routeName = 'Recommendations';
  static String routePath = '/recommendations';

  @override
  State<RecommendationsWidget> createState() => _RecommendationsWidgetState();
}

class _RecommendationsWidgetState extends State<RecommendationsWidget> {
  late RecommendationsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, RecommendationsModel.new);
    _model.loadRecommendations().then((_) => safeSetState(() {}));
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
        title: Text('Recommendations', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _model.loadRecommendations();
                safeSetState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_model.trending.isNotEmpty)
                      _buildSection(context, theme, 'Trending Now',
                          _model.trending, true),
                    if (_model.nearYou.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSection(context, theme, 'Near You',
                          _model.nearYou, false),
                    ],
                    if (_model.categoryPicks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildCategoryPicks(context, theme),
                    ],
                    if (_model.trending.isEmpty &&
                        _model.nearYou.isEmpty &&
                        _model.categoryPicks.isEmpty)
                      _buildEmpty(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context, AppThemeData theme, String title,
      List<Map<String, dynamic>> items, bool grid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.plusJakartaSans(
                color: theme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (grid)
          _buildGrid(context, items, theme)
        else
          _buildHorizontalList(context, items, theme),
      ],
    );
  }

  Widget _buildHorizontalList(
      BuildContext context, List<Map<String, dynamic>> items, AppThemeData theme) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _buildCard(context, items[index], theme, 160),
      ),
    );
  }

  Widget _buildGrid(
      BuildContext context, List<Map<String, dynamic>> items, AppThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((s) => SizedBox(
                width: (MediaQuery.of(context).size.width - 44) / 2,
                child: _buildCard(context, s, theme, 200),
              ))
          .toList(),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> s,
      AppThemeData theme, double height) {
    final thumb = s['thumbnail'] as String?;
    final title = s['title'] as String? ?? '';
    final price = s['basePrice'] as double?;
    final rating = s['rating'] as String?;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: thumb != null
                  ? Image.network(thumb,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover)
                  : Container(
                      height: 100,
                      color: theme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.image_rounded,
                          color: theme.primary)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                          color: theme.primaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (rating != null) ...[
                        Icon(Icons.star_rounded,
                            size: 12, color: theme.warning),
                        const SizedBox(width: 2),
                        Text(rating,
                            style: GoogleFonts.plusJakartaSans(
                                color: theme.secondaryText, fontSize: 10)),
                        const SizedBox(width: 4),
                      ],
                      Text(
                          price != null
                              ? 'â‚±${price.toStringAsFixed(0)}'
                              : '',
                          style: GoogleFonts.plusJakartaSans(
                              color: theme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPicks(
      BuildContext context, AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Picked for You',
            style: GoogleFonts.plusJakartaSans(
                color: theme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._model.categoryPicks.map((s) {
          final cat = s['categoryName'] as String?;
          final title = s['title'] as String? ?? '';
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              children: [
                Icon(Icons.category_rounded,
                    color: theme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cat != null)
                        Text(cat,
                            style: GoogleFonts.plusJakartaSans(
                                color: theme.secondaryText, fontSize: 11)),
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                              color: theme.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: theme.textTertiary, size: 20),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmpty(AppThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_rounded,
                size: 64, color: theme.textTertiary),
            const SizedBox(height: 16),
            Text('No recommendations yet',
                style: GoogleFonts.plusJakartaSans(
                    color: theme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Browse services to get personalized picks.',
                style: GoogleFonts.plusJakartaSans(
                    color: theme.secondaryText, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
