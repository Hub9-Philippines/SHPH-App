import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'category_detail_model.dart';

export 'category_detail_model.dart';

class CategoryDetailWidget extends StatefulWidget {
  const CategoryDetailWidget({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  static String routeName = 'CategoryDetail';
  static String routePath = '/category/:categoryId';

  @override
  State<CategoryDetailWidget> createState() => _CategoryDetailWidgetState();
}

class _CategoryDetailWidgetState extends State<CategoryDetailWidget> {
  late CategoryDetailModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CategoryDetailModel.new);
    _model
        .loadCategory(widget.categoryId, widget.categoryName)
        .then((_) => safeSetState(() {}));
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
        title: Text(_model.categoryName ?? widget.categoryName,
            style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.listings.isEmpty
              ? _buildEmpty(theme)
              : _buildList(context, theme),
    );
  }

  Widget _buildEmpty(AppThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: theme.textTertiary),
            const SizedBox(height: 16),
            Text('No services found in this category',
                style: GoogleFonts.poppins(
                    color: theme.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Check back later or browse other categories.',
                style: GoogleFonts.poppins(
                    color: theme.secondaryText, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, AppThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _model.listings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final l = _model.listings[index];
        return _buildServiceCard(context, l, theme);
      },
    );
  }

  Widget _buildServiceCard(
      BuildContext context, Map<String, dynamic> l, AppThemeData theme) {
    final thumb = l['thumbnail'] as String?;
    final title = l['title'] as String? ?? '';
    final price = l['basePrice'] as double?;
    final rating = l['rating'] as String?;
    final providerName = l['providerName'] as String?;

    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12)),
              child: thumb != null
                  ? Image.network(thumb,
                      width: 100, height: 100, fit: BoxFit.cover)
                  : Container(
                      width: 100,
                      height: 100,
                      color: theme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.image_rounded,
                          color: theme.primary)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            color: theme.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    if (providerName != null)
                      Text(providerName,
                          style: GoogleFonts.poppins(
                              color: theme.secondaryText, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (rating != null) ...[
                          Icon(Icons.star_rounded,
                              size: 14, color: theme.warning),
                          const SizedBox(width: 2),
                          Text(rating,
                              style: GoogleFonts.poppins(
                                  color: theme.secondaryText,
                                  fontSize: 12)),
                          const SizedBox(width: 8),
                        ],
                        Text(
                            price != null
                                ? '₱${price.toStringAsFixed(0)}'
                                : '',
                            style: GoogleFonts.poppins(
                                color: theme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
