import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'geographic_selection_model.dart';

export 'geographic_selection_model.dart' show GeographicSelectionType;

class GeographicSelectionWidget extends StatefulWidget {
  const GeographicSelectionWidget({
    required this.selectionType,
    super.key,
    this.parentCode,
    this.isRegionFallback = false,
  });

  final GeographicSelectionType selectionType;
  final String? parentCode;
  final bool isRegionFallback;

  static String routeName = 'GeographicSelection';
  static String routePath = '/geographic-selection';

  @override
  State<GeographicSelectionWidget> createState() =>
      _GeographicSelectionWidgetState();
}

class _GeographicSelectionWidgetState extends State<GeographicSelectionWidget> {
  late GeographicSelectionModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = GeographicSelectionModel();
    _model.loadData(widget.selectionType, widget.parentCode,
        isRegionFallback: widget.isRegionFallback);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _model,
        builder: (context, child) => GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: AppTheme.of(context).primaryBackground,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: CupertinoPageHeader(
                backgroundColor: AppTheme.of(context).primaryBackground,
                automaticallyImplyLeading: true,
                title: _getTitle(widget.selectionType),
                titleStyle: AppTheme.of(context).titleLarge.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                        fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                      ),
                      letterSpacing: 0,
                      fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                      fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                    ),
              ),
            ),
            body: SafeArea(
              top: true,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: AppTheme.of(context).secondaryText,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                onChanged: (value) {
                                  _model.filterItems(value);
                                },
                                placeholder: _l10n.geSearch,
                                placeholderStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      color:
                                          AppTheme.of(context).secondaryText,
                                    ),
                                style: AppTheme.of(context).bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _model.isLoading
                        ? const Center(
                            child: AppActivityIndicator(),
                          )
                        : _model.groupedItems.isEmpty
                            ? Center(
                                child: Text(
                                  _l10n.geNoItemsFound,
                                  style: AppTheme.of(context).bodyMedium,
                                ),
                              )
                            : ListView.builder(
                                itemCount: _model.groupedItems.length,
                                itemBuilder: (context, index) {
                                  final letter =
                                      _model.groupedItems.keys.elementAt(index);
                                  final items = _model.groupedItems[letter]!;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16, 16, 16, 8),
                                        child: Text(
                                          letter,
                                          style: AppTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                color: AppTheme.of(context)
                                                    .primary,
                                                fontSize: 18,
                                              ),
                                        ),
                                      ),
                                      ...items.map((item) => InkWell(
                                            onTap: () {
                                              Navigator.pop(context, item);
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(16, 12, 16, 12),
                                              decoration: BoxDecoration(
                                                color: AppTheme.of(context)
                                                    .primaryBackground,
                                              ),
                                              child: Text(
                                                item.name,
                                                style: AppTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font:
                                                          GoogleFonts.plusJakartaSans(),
                                                      fontSize: 16,
                                                    ),
                                              ),
                                            ),
                                          )),
                                    ],
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  String _getTitle(GeographicSelectionType type) {
    switch (type) {
      case GeographicSelectionType.region:
        return _l10n.geTitleRegion;
      case GeographicSelectionType.province:
        return _l10n.geTitleProvince;
      case GeographicSelectionType.cityMunicipality:
        return _l10n.geTitleCity;
      case GeographicSelectionType.barangay:
        return _l10n.geTitleBarangay;
    }
  }
}
