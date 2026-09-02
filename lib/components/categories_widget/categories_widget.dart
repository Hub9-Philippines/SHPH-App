import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/supabase.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/services/categories_service.dart';
import '/theme/app_theme.dart';
import '/utils/category_icons.dart';
import '/utils/emergency_categories.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
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
                  _l10n.catgError,
                  style: AppTheme.of(context).bodyMedium,
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _l10n.catgNoCategories,
                  style: AppTheme.of(context).bodyMedium,
                ),
              ),
            );
          }

          final screenWidth = MediaQuery.sizeOf(context).width;
          final crossAxisCount = screenWidth < 340 ? 2 : 3;
          final childAspectRatio = screenWidth < 340 ? 1.05 : 0.88;

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) =>
                _buildCategoryCard(categories[index], index),
          );
        },
      );

  Widget _buildCategoryCard(CategoriesRow category, int index) {
    final palette = _paletteForIndex(index);
    final isEmergency = isEmergencyCategory(category.name);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/services?category=${category.name}'),
        borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette,
            ),
            borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
            border: isEmergency
                ? Border.all(
                    color: AppTheme.of(context).primaryBackground,
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: palette.first.withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: _buildCategoryArt(category),
                      ),
                    ),
                    if (isEmergency)
                      Flexible(
                        child: _EmergencyBadge(),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEmergency
                          ? _l10n.catgInstantDispatch
                          : _l10n.catgOpenServices,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                            ),
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _EmergencyBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary,
          borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, size: 10, color: Colors.white),
            const SizedBox(width: 1),
            Flexible(
              child: Text(
                _l10n.catg247,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).labelSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 8,
                      ),
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      );

  Widget _buildCategoryArt(CategoriesRow category) => Icon(
        CategoryIcons.resolve(slug: category.icon, name: category.name),
        color: Colors.white,
        size: 22,
      );

  List<Color> _paletteForIndex(int index) {
    const palettes = [
      [Color(0xFF0F8A6C), Color(0xFF17B890)],
      [Color(0xFF1C6DD0), Color(0xFF54A6FF)],
      [Color(0xFFEF6C57), Color(0xFFFF9A62)],
      [Color(0xFF6C5CE7), Color(0xFF9C88FF)],
      [Color(0xFF0E7490), Color(0xFF22C3DD)],
      [Color(0xFF9A3412), Color(0xFFF97316)],
    ];
    return palettes[index % palettes.length];
  }
}
