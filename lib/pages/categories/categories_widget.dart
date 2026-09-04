import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/back_button/back_button_widget.dart';
import '/components/quick_book_bar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show ServicesScreen;
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../../components/categories_widget/categories_widget.dart';
import 'categories_model.dart';

export 'categories_model.dart';

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({super.key});

  static String routeName = 'Categories';
  static String routePath = '/categories';

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  late CategoriesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CategoriesModel.new);
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
          bottomNavigationBar: QuickBookBar(
            onUrgentAssistance: () => context.pushNamed(
              ServicesScreen.routeName,
              extra: <String, dynamic>{'emergencyMode': true},
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: wrapWithModel(
                          model: _model.backButtonModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const BackButtonWidget(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _l10n.catgTitle,
                              style: AppTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: const Color(0xFF14213D),
                                  ),
                            ),
                            Text(
                              _l10n.catgSubtitle,
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color: const Color(0xFF64748B),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
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
