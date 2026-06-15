import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/supabase.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/categories_service.dart';
import '/theme/app_theme.dart';
import 'categories_widget_model.dart';

export 'categories_widget_model.dart';

class CategoriesWidgetWidget extends StatefulWidget {
  const CategoriesWidgetWidget({super.key});

  @override
  State<CategoriesWidgetWidget> createState() => _CategoriesWidgetWidgetState();
}

class _CategoriesWidgetWidgetState extends State<CategoriesWidgetWidget> {
  late CategoriesWidgetModel _model;
  late Future<List<CategoriesRow>> _categoriesFuture;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CategoriesWidgetModel.new);
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = CategoriesService.instance.getCategories();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<CategoriesRow>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const CategoryCardSkeleton(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Error loading categories',
                  style: AppTheme.of(context).bodyMedium,
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No categories available'),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(15),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) =>
                  _buildCategoryCard(categories[index]),
            ),
          );
        },
      );

  Widget _buildCategoryCard(CategoriesRow category) => GestureDetector(
        onTap: () => context.push('/services?category=${category.name}'),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: category.imageUrl != null &&
                            category.imageUrl!.isNotEmpty
                        ? (category.imageUrl!.startsWith('http')
                            ? Image.network(
                                category.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color:
                                      AppTheme.of(context).secondaryBackground,
                                  child: Icon(
                                    Icons.category,
                                    color: AppTheme.of(context).secondaryText,
                                    size: 40,
                                  ),
                                ),
                              )
                            : Image.asset(
                                category.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color:
                                      AppTheme.of(context).secondaryBackground,
                                  child: Icon(
                                    Icons.category,
                                    color: AppTheme.of(context).secondaryText,
                                    size: 40,
                                  ),
                                ),
                              ))
                        : Icon(
                            Icons.category,
                            color: AppTheme.of(context).secondaryText,
                            size: 40,
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '5+ Services',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight:
                                  AppTheme.of(context).bodySmall.fontWeight,
                            ),
                            letterSpacing: 0,
                            fontWeight:
                                AppTheme.of(context).bodySmall.fontWeight,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
