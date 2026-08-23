import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'subcategory_model.dart';

export 'subcategory_model.dart';

class SubcategoryWidget extends StatefulWidget {
  const SubcategoryWidget({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  static String routeName = 'Subcategory';
  static String routePath = '/category/:categoryId/subcategories';

  @override
  State<SubcategoryWidget> createState() => _SubcategoryWidgetState();
}

class _SubcategoryWidgetState extends State<SubcategoryWidget> {
  late SubcategoryModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SubcategoryModel.new);
    _model.loadSubcategories(widget.categoryId).then((_) => safeSetState(() {}));
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
        title: Text(widget.categoryName, style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.subcategories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category,
                          size: 64, color: theme.secondaryText),
                      const SizedBox(height: 16),
                      Text('No services available in this category',
                          style: theme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _model
                      .loadSubcategories(widget.categoryId)
                      .then((_) => safeSetState(() {})),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _model.subcategories.length,
                    itemBuilder: (context, index) {
                      final sub = _model.subcategories[index];
                      return InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: theme.border, width: 0.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.build,
                                  color: theme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                sub['name']?.toString() ?? '',
                                style: theme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (sub['description'] != null &&
                                  sub['description']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  sub['description'].toString(),
                                  style: theme.bodySmall.copyWith(
                                      color: theme.secondaryText),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
