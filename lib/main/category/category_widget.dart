import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '../../components/categories_widget/categories_widget.dart';
import 'category_model.dart';

export 'category_model.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  static String routeName = 'Category';
  static String routePath = '/category';

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  late CategoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CategoryModel.new);
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
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Categories',
                                  style: AppTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        color: const Color(0xFF16202A),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Jump into the service type you need most.',
                                  style:
                                      AppTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.poppins(),
                                            color: const Color(0xFF6F7B86),
                                          ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.grid_view_rounded,
                              color: AppTheme.of(context).primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0F8A6C),
                              Color(0xFF17B890),
                              Color(0xFF73D8B4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore by category',
                              style: AppTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Browse available services faster, then jump straight into results.',
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(),
                                    color: Colors.white.withValues(alpha: 0.84),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: wrapWithModel(
                      model: _model.categoriesWidgetModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const CategoriesWidgetWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
