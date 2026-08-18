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
                  'Error loading categories',
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
                  'No categories available',
                  style: AppTheme.of(context).bodyMedium,
                ),
              ),
            );
          }

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) =>
                _buildCategoryCard(categories[index], index),
          );
        },
      );

  Widget _buildCategoryCard(CategoriesRow category, int index) {
    final palette = _paletteForIndex(index);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/services?category=${category.name}'),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: palette.first.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildCategoryArt(category),
                  ),
                ),
                const Spacer(),
                Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Open services',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                        ),
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryArt(CategoriesRow category) => Icon(
        _categoryIcon(category),
        color: Colors.white,
        size: 22,
      );

  IconData _categoryIcon(CategoriesRow category) {
    final bySlug = _iconBySlug(category.icon);
    if (bySlug != null) {
      return bySlug;
    }
    return _iconByName(category.name);
  }

  IconData? _iconBySlug(String? slug) {
    if (slug == null) {
      return null;
    }
    switch (slug.trim().toLowerCase()) {
      case 'key':
        return Icons.key_rounded;
      case 'wrench':
        return Icons.plumbing_rounded;
      case 'zap':
        return Icons.bolt_rounded;
      case 'sparkles':
        return Icons.cleaning_services_rounded;
      case 'wind':
        return Icons.ac_unit_rounded;
      case 'tool':
        return Icons.kitchen_rounded;
      case 'bug':
        return Icons.bug_report_rounded;
      case 'car':
        return Icons.local_car_wash_rounded;
      case 'hammer':
        return Icons.handyman_rounded;
      case 'paint-bucket':
        return Icons.format_paint_rounded;
      case 'home':
        return Icons.roofing_rounded;
      case 'layers':
        return Icons.layers_rounded;
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'tree':
        return Icons.park_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      case 'users':
        return Icons.engineering_rounded;
      default:
        return null;
    }
  }

  IconData _iconByName(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('clean')) {
      return Icons.cleaning_services_rounded;
    }
    if (normalized.contains('plumb')) {
      return Icons.plumbing_rounded;
    }
    if (normalized.contains('paint')) {
      return Icons.format_paint_rounded;
    }
    if (normalized.contains('electric')) {
      return Icons.bolt_rounded;
    }
    if (normalized.contains('aircon') || normalized.contains('hvac')) {
      return Icons.ac_unit_rounded;
    }
    if (normalized.contains('car wash')) {
      return Icons.local_car_wash_rounded;
    }
    if (normalized.contains('carpent') || normalized.contains('wood')) {
      return Icons.handyman_rounded;
    }
    if (normalized.contains('lock')) {
      return Icons.key_rounded;
    }
    if (normalized.contains('appliance')) {
      return Icons.kitchen_rounded;
    }
    if (normalized.contains('pest')) {
      return Icons.bug_report_rounded;
    }
    if (normalized.contains('roof')) {
      return Icons.roofing_rounded;
    }
    if (normalized.contains('mason')) {
      return Icons.layers_rounded;
    }
    if (normalized.contains('weld')) {
      return Icons.local_fire_department_rounded;
    }
    if (normalized.contains('landscap') || normalized.contains('garden')) {
      return Icons.park_rounded;
    }
    if (normalized.contains('mov')) {
      return Icons.local_shipping_rounded;
    }
    if (normalized.contains('labor') || normalized.contains('handyman')) {
      return Icons.engineering_rounded;
    }
    return Icons.category_rounded;
  }

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
