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
        backgroundColor: AppTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          actions: const [],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Categories',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          AppTheme.of(context).titleLarge.fontStyle,
                    ),
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        AppTheme.of(context).titleLarge.fontStyle,
                  ),
            ),
            centerTitle: true,
            expandedTitleScale: 1,
            titlePadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: wrapWithModel(
            model: _model.categoriesWidgetModel,
            updateCallback: () => safeSetState(() {}),
            child: const CategoriesWidgetWidget(),
          ),
        ),
      ),
    );
}
