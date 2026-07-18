import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/shph_auth/auth_util.dart';
import '/backend/shph_db/shph_db.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
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
  late Future<List<AddressesRow>> _addressesFuture;
  bool _didLoadOnce = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, AddressesModel.new);
    _loadAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadOnce && currentUserUid.isNotEmpty) {
      _didLoadOnce = true;
      _loadAddresses();
    }
  }

  void _loadAddresses() {
    if (currentUserUid.isEmpty) {
      _addressesFuture = Future.value([]);
      return;
    }
    _addressesFuture = AddressesTable().queryRows(
      queryFn: (q) =>
          q.eq('user_id', currentUserUid).order('is_default', ascending: false),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<AddressesRow>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F7FA),
              appBar: _buildAppBar(),
              body: const Center(
                child: CircularProgressIndicator(),
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
              backgroundColor: const Color(0xFFF5F7FA),
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
                            _buildHeader(addresses),
                            const SizedBox(height: 18),
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 20,
                            offset: Offset(0, -8),
                          ),
                        ],
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
                          text: 'Add new address',
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
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: Colors.white,
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

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        automaticallyImplyLeading: false,
        leading: wrapWithModel(
          model: _model.backButtonModel,
          updateCallback: () => safeSetState(() {}),
          child: const BackButtonWidget(),
        ),
        title: Text(
          'Addresses',
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
                color: const Color(0xFF16202A),
              ),
        ),
        centerTitle: true,
        elevation: 0,
      );

  Widget _buildHeader(List<AddressesRow> addresses) {
    final defaultAddressCount =
        addresses.where((address) => address.isDefault == true).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF16202A),
            Color(0xFF1F3447),
            Color(0xFF2B4A63),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A16202A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved places',
                      style: AppTheme.of(context).titleLarge.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep your booking flow fast by storing your key locations.',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(),
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _AddressHeaderMetric(
                  label: 'Total',
                  value: '${addresses.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AddressHeaderMetric(
                  label: 'Default',
                  value: '$defaultAddressCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AddressHeaderMetric(
                  label: 'Selected',
                  value: FFAppState().selectedLocationMode == 'saved'
                      ? 'Saved'
                      : 'Device',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
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
              'No addresses yet',
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                    ),
                    color: const Color(0xFF16202A),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your home, work, or favorite places so future bookings are quicker.',
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(),
                    color: const Color(0xFF6F7B86),
                  ),
            ),
          ],
        ),
      );

  Widget _buildAddressCard(AddressesRow address) {
    final isDefault = address.isDefault == true;
    final isSelected = FFAppState().selectedLocationMode == 'saved' &&
        FFAppState().selectedAddressId == address.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? AppTheme.of(context).primary
              : isDefault
                  ? const Color(0xFFCBD5DF)
                  : Colors.transparent,
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
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
                        _getIconForLabel(address.addressLine2),
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
                                  address.addressLine2?.trim().isNotEmpty ==
                                          true
                                      ? address.addressLine2!.trim()
                                      : 'Saved address',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: const Color(0xFF16202A),
                                          ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_horiz_rounded,
                                  color: Color(0xFF7C8793),
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
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 20),
                                        SizedBox(width: 12),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  if (!isDefault)
                                    const PopupMenuItem(
                                      value: 'default',
                                      child: Row(
                                        children: [
                                          Icon(Icons.star_outline_rounded,
                                              size: 20),
                                          SizedBox(width: 12),
                                          Text('Set as default'),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
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
                                          'Delete',
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
                                _buildPill('Default', const Color(0xFF0F8A6C)),
                              if (isSelected)
                                _buildPill(
                                    'Selected', AppTheme.of(context).primary),
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
                        font: GoogleFonts.poppins(),
                        color: const Color(0xFF5F6B76),
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
                      color: const Color(0xFFF6F8FB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: Color(0xFF6F7B86),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${address.latitude!.toStringAsFixed(5)}, ${address.longitude!.toStringAsFixed(5)}',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.poppins(),
                                  color: const Color(0xFF6F7B86),
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
                font: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
                color: color,
              ),
        ),
      );

  String _formatAddress(AddressesRow address) => [
        address.addressLine1,
        address.barangay,
        address.city,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');

  Future<void> _setDefaultAddress(String addressId) async {
    try {
      await AddressesTable().update(
        data: {'is_default': false},
        matchingRows: (q) => q.eq('user_id', currentUserUid),
      );

      await AddressesTable().update(
        data: {'is_default': true},
        matchingRows: (q) => q.eq('id', addressId),
      );

      FFAppState().clearGetAddressCache();
      _loadAddresses();
      if (mounted) {
        safeSetState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default address updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting default address: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(AddressesRow address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address'),
        content: Text(
          'Are you sure you want to delete ${address.addressLine2 ?? 'this address'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      final deletedSelectedAddress =
          FFAppState().selectedLocationMode == 'saved' &&
              FFAppState().selectedAddressId == address.id;
      await AddressesTable().delete(
        matchingRows: (q) => q.eq('id', address.id),
      );
      FFAppState().clearGetAddressCache();

      final remainingAddresses = await AddressesTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', currentUserUid)
            .order('is_default', ascending: false),
      );
      if (deletedSelectedAddress) {
        final nextAddress =
            FFAppState().syncSelectedSavedAddress(remainingAddresses);
        if (nextAddress == null) {
          FFAppState().clearSelectedAddress();
        }
      }

      _loadAddresses();
      if (mounted) {
        safeSetState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting address: $e')),
        );
      }
    }
  }

  void _selectAddress(AddressesRow address) {
    FFAppState().setSelectedAddressFromRow(address);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${address.addressLine2?.trim().isNotEmpty == true ? address.addressLine2!.trim() : 'Saved address'} selected for bookings',
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

class _AddressHeaderMetric extends StatelessWidget {
  const _AddressHeaderMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                    ),
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(),
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
            ),
          ],
        ),
      );
}
