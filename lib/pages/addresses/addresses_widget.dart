import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
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
      queryFn: (q) => q.eq('user_id', currentUserUid),
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
              backgroundColor: AppTheme.of(context).secondaryBackground,
              appBar: AppBar(
                backgroundColor: AppTheme.of(context).primaryBackground,
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
                          fontWeight:
                              AppTheme.of(context).titleLarge.fontWeight,
                          fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                        ),
                        letterSpacing: 0,
                        fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                        fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                      ),
                ),
                actions: const [],
                centerTitle: true,
                elevation: 0,
              ),
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
              backgroundColor: AppTheme.of(context).secondaryBackground,
              appBar: AppBar(
                backgroundColor: AppTheme.of(context).primaryBackground,
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
                          fontWeight:
                              AppTheme.of(context).titleLarge.fontWeight,
                          fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                        ),
                        letterSpacing: 0,
                        fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                        fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                      ),
                ),
                actions: const [],
                centerTitle: true,
                elevation: 0,
              ),
              body: SafeArea(
                top: true,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              15, 0, 15, 0),
                          child: addresses.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_off,
                                        size: 64,
                                        color:
                                            AppTheme.of(context).secondaryText,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No addresses yet',
                                        style: AppTheme.of(context).titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add your first address',
                                        style: AppTheme.of(context).bodySmall,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: addresses.length,
                                  itemBuilder: (context, index) {
                                    final address = addresses[index];
                                    return _buildAddressCard(address);
                                  },
                                ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 15),
                        child: FFButtonWidget(
                          onPressed: () async {
                            await context.push(
                              AddressFormWidget.routePath,
                            );
                            _loadAddresses();
                            if (mounted) {
                              safeSetState(() {});
                            }
                          },
                          text: 'Add new address',
                          icon: const Icon(
                            Icons.add_circle_outline,
                            size: 22,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 60,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
                            color: AppTheme.of(context).primary,
                            textStyle: AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: AppTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  fontWeight: AppTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle:
                                      AppTheme.of(context).titleSmall.fontStyle,
                                ),
                            elevation: 0,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _buildAddressCard(AddressesRow address) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 0,
              color: Color(0x33000000),
              offset: Offset(0, 1),
            )
          ],
          borderRadius: BorderRadius.circular(8),
          border: address.isDefault == true
              ? Border.all(
                  color: AppTheme.of(context).primary,
                  width: 2,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(15, 12, 15, 12),
          child: InkWell(
            onTap: () async {
              await context.push(
                AddressFormWidget.routePath,
                extra: {'addressId': address.id},
              );
              _loadAddresses();
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0x1A368EFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconForLabel(address.addressLine2),
                          color: AppTheme.of(context).primary,
                          size: 28,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(15, 0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      address.addressLine2 ?? 'Address',
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.of(context)
                                          .titleLarge
                                          .override(
                                            font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500),
                                            color:
                                                AppTheme.of(context).primaryText,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ),
                                  if (address.isDefault == true) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.of(context).primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Default',
                                        style: AppTheme.of(context)
                                            .bodySmall
                                            .override(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${address.addressLine1 ?? ''}, ${address.barangay ?? ''}, ${address.city ?? ''}',
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.poppins(),
                                      fontSize: 12,
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xB757636C)),
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        await context.push(
                          AddressFormWidget.routePath,
                          extra: {'addressId': address.id},
                        );
                        _loadAddresses();
                        break;
                      case 'default':
                        await _setDefaultAddress(address.id.toString());
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
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (address.isDefault != true)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star_border, size: 20),
                            SizedBox(width: 12),
                            Text('Set as default'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _setDefaultAddress(String addressId) async {
    try {
      // First, unset all default addresses for this user
      await AddressesTable().update(
        data: {'is_default': false},
        matchingRows: (q) => q.eq('user_id', currentUserUid),
      );

      // Then set the selected address as default
      await AddressesTable().update(
        data: {'is_default': true},
        matchingRows: (q) => q.eq('id', addressId),
      );

      _loadAddresses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default address updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting default address: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(AddressesRow address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address'),
        content: Text(
            'Are you sure you want to delete ${address.addressLine2 ?? 'this address'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AddressesTable().delete(
          matchingRows: (q) => q.eq('id', address.id),
        );
        _loadAddresses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting address: $e')),
        );
      }
    }
  }

  IconData _getIconForLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work;
      case 'partner':
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}
