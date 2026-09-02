import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/models/address.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/services/addresses_service.dart';
import '/theme/app_theme.dart';
import 'addresses_model.dart';

export 'addresses_model.dart';

class AddressesWidget extends StatefulWidget {
  const AddressesWidget({super.key});

  static String routeName = 'Addresses';
  static String routePath = '/addresses';

  @override
  State<AddressesWidget> createState() => _AddressesWidgetState();
}

class _AddressesWidgetState extends State<AddressesWidget> {
  late AddressesModel _model;
  late Future<List<ShphAddress>> _addressesFuture;
  bool _didLoadOnce = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, AddressesModel.new);
    _loadAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadOnce) {
      _didLoadOnce = true;
      _loadAddresses();
    }
  }

  void _loadAddresses() {
    _addressesFuture = AddressesService.instance.getAddresses();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ShphAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            final loadingTheme = AppTheme.of(context);
            return Scaffold(
              backgroundColor: loadingTheme.secondaryBackground,
              appBar: _buildAppBar(),
              body: const Center(
                child: AppActivityIndicator(),
              ),
            );
          }

          final addresses = snapshot.data!;

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: AppTheme.of(context).secondaryBackground,
              appBar: _buildAppBar(),
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.of(context).primary,
                        onRefresh: () async {
                          _loadAddresses();
                          if (mounted) {
                            safeSetState(() {});
                          }
                        },
                        child: ListView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                          children: [
                            const SizedBox(height: 4),
                            if (addresses.isEmpty)
                              _buildEmptyState()
                            else
                              ...addresses.map(_buildAddressCard),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primaryBackground,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(28)),
                        boxShadow: AppThemeData.shadowCard,
                      ),
                      child: SafeArea(
                        top: false,
                        child: FFButtonWidget(
                          onPressed: () async {
                            await context.push(AddressFormWidget.routePath);
                            _loadAddresses();
                            if (mounted) {
                              safeSetState(() {});
                            }
                          },
                          text: _l10n.adAddNewAddress,
                          icon: const Icon(
                            Icons.add_location_alt_outlined,
                            size: 20,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 58,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              16,
                              0,
                              16,
                              0,
                            ),
                            iconPadding: EdgeInsetsDirectional.zero,
                            color: AppTheme.of(context).primary,
                            textStyle: AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: AppTheme.of(context).onPrimary,
                                  fontSize: 16,
                                ),
                            elevation: 0,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  PreferredSizeWidget _buildAppBar() => PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: AppTheme.of(context).secondaryBackground,
          leading: wrapWithModel(
            model: _model.backButtonModel,
            updateCallback: () => safeSetState(() {}),
            child: const BackButtonWidget(),
          ),
          title: _l10n.adTitle,
          titleStyle: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
                color: AppTheme.of(context).primaryText,
              ),
        ),
      );

  Widget _buildEmptyState() {
    final theme = AppTheme.of(context);
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.border),
        ),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 42,
                color: AppTheme.of(context).primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _l10n.adNoAddressesYet,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _l10n.adEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );
  }

  Widget _buildAddressCard(ShphAddress address) {
    final isDefault = address.isDefault;
    final isSelected = FFAppState().selectedLocationMode == 'saved' &&
        FFAppState().selectedAddressId == address.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? AppTheme.of(context).primary
              : isDefault
                  ? AppTheme.of(context).border
                  : Colors.transparent,
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _selectAddress(address),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context)
                            .primary
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getIconForLabel(address.label),
                        color: AppTheme.of(context).primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  address.label?.trim().isNotEmpty == true
                                      ? address.label!.trim()
                                       : _l10n.adSavedAddress,
                                   maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: AppTheme.of(context).primaryText,
                                          ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_horiz_rounded,
                                  color: AppTheme.of(context).textTertiary,
                                ),
                                onSelected: (value) async {
                                  switch (value) {
                                    case 'edit':
                                      await context.push(
                                        AddressFormWidget.routePath,
                                        extra: {'addressId': address.id},
                                      );
                                      _loadAddresses();
                                      if (mounted) {
                                        safeSetState(() {});
                                      }
                                      break;
                                    case 'default':
                                      await _setDefaultAddress(
                                        address.id.toString(),
                                      );
                                      break;
                                    case 'delete':
                                      await _showDeleteConfirmation(address);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                   PopupMenuItem(
                                     value: 'edit',
                                     child: Row(
                                       children: [
                                         Icon(Icons.edit_outlined, size: 20),
                                         SizedBox(width: 12),
                                         Text(_l10n.adEdit),
                                       ],
                                     ),
                                   ),
                                   if (!isDefault)
                                     PopupMenuItem(
                                       value: 'default',
                                       child: Row(
                                         children: [
                                           Icon(Icons.star_outline_rounded,
                                               size: 20),
                                           SizedBox(width: 12),
                                           Text(_l10n.adSetAsDefault),
                                         ],
                                       ),
                                     ),
                                   PopupMenuItem(
                                     value: 'delete',
                                     child: Row(
                                       children: [
                                         Icon(
                                           Icons.delete_outline_rounded,
                                           size: 20,
                                           color: Colors.red,
                                         ),
                                         SizedBox(width: 12),
                                         Text(
                                           _l10n.adDelete,
                                           style: TextStyle(color: Colors.red),
                                         ),
                                       ],
                                     ),
                                   ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (isDefault)
                                _buildPill(_l10n.adDefault, AppTheme.of(context).primaryBrandText),
                              if (isSelected)
                                _buildPill(
                                    _l10n.adSelected, AppTheme.of(context).primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _formatAddress(address),
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                        fontSize: 13,
                      ),
                ),
                if (address.latitude != null && address.longitude != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${address.latitude!.toStringAsFixed(5)}, ${address.longitude!.toStringAsFixed(5)}',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: AppTheme.of(context).labelSmall.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
                color: color,
              ),
        ),
      );

  String _formatAddress(ShphAddress address) {
    return [
      address.street,
      address.barangay,
      address.city,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
  }

  Future<void> _setDefaultAddress(String addressId) async {
    try {
      final id = int.tryParse(addressId);
      if (id == null) {
        return;
      }
      final updated = await AddressesService.instance.setDefault(id);
      if (updated == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_l10n.adErrorSetDefault)),
          );
        }
        return;
      }

      FFAppState().clearGetAddressCache();
      _loadAddresses();
      if (mounted) {
        safeSetState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.adDefaultUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.adErrorSetDefaultDetail(e.toString()))),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(ShphAddress address) async {
    final confirm = await AppFeedback.confirmDialog(
      context: context,
      title: _l10n.adDeleteTitle,
      message:
          _l10n.adDeleteConfirm(address.label ?? _l10n.adSavedAddress),
      confirmText: _l10n.adDelete,
      destructive: true,
    );

    if (confirm != true) {
      return;
    }

    try {
      final deletedSelectedAddress = FFAppState().selectedLocationMode == 'saved' &&
          FFAppState().selectedAddressId == address.id;
      await AddressesService.instance.deleteAddress(address.id);
      FFAppState().clearGetAddressCache();

      final remainingAddresses = await AddressesService.instance.getAddresses();
      final remainingMaps =
          remainingAddresses.map((a) => a.toSelectedMap()).toList();
      if (deletedSelectedAddress) {
        final nextAddress = FFAppState()
            .syncSelectedSavedAddressFromMap(remainingMaps);
        if (nextAddress == null) {
          FFAppState().clearSelectedAddress();
        }
      }

      _loadAddresses();
      if (mounted) {
        safeSetState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.adDeletedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.adErrorDeleteDetail(e.toString()))),
        );
      }
    }
  }

  void _selectAddress(ShphAddress address) {
    FFAppState().setSelectedAddressFromMap(address.toSelectedMap());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _l10n.adSelectedForBookings(
            address.label?.trim().isNotEmpty == true
                ? address.label!.trim()
                : _l10n.adSavedAddress,
          ),
        ),
      ),
    );
    safeSetState(() {});
  }

  IconData _getIconForLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'partner':
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}
