import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'categoriesgrid_model.dart';

export 'categoriesgrid_model.dart';

class CategoriesgridWidget extends StatefulWidget {
  const CategoriesgridWidget({super.key});

  @override
  State<CategoriesgridWidget> createState() => _CategoriesgridWidgetState();
}

class _CategoriesgridWidgetState extends State<CategoriesgridWidget> {
  late CategoriesgridModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CategoriesgridModel.new);
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GridView(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.5,
        ),
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          ...CategoriesgridModel.categories.map((category) => GestureDetector(
                onTap: () => category.categoryParam == 'All'
                    ? context.push('/services')
                    : context.push('/services?category=${category.categoryParam}'),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xAAF0F0F0),
                        borderRadius: BorderRadius.circular(category.borderRadius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          category.imageAsset,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontStyle:
                                  AppTheme.of(context).bodySmall.fontStyle,
                            ),
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                            fontStyle:
                                AppTheme.of(context).bodySmall.fontStyle,
                          ),
                    ),
                  ].divide(const SizedBox(height: 8)),
                ),
              )),
        ],
      );
}
