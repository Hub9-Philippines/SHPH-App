import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/database/tables/addresses.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/addresses_service.dart';
import '/theme/app_theme.dart';
import 'edit_address_model.dart';

export 'edit_address_model.dart';

class EditAddressWidget extends StatefulWidget {
  const EditAddressWidget({super.key});

  @override
  State<EditAddressWidget> createState() => _EditAddressWidgetState();
}

class _EditAddressWidgetState extends State<EditAddressWidget> {
  late EditAddressModel _model;
  late Future<List<AddressesRow>> _addressesFuture;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EditAddressModel.new);
    _loadAddresses();
  }

  void _loadAddresses() {
    if (currentUserUid.isEmpty) {
      _addressesFuture = Future.value([]);
      return;
    }
    _addressesFuture = AddressesService.instance.listAddressRows();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).alternate,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select address',
                      style: AppTheme.of(context).headlineSmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<AddressesRow>>(
                  future: _addressesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final addresses = snapshot.data!;
                    if (addresses.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 48,
                              color: AppTheme.of(context).secondaryText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No addresses yet',
                              style: AppTheme.of(context).bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return _buildAddressItem(address);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
                child: FFButtonWidget(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                      AddressFormWidget.routePath,
                    );
                  },
                  text: 'Add new address',
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 22,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56,
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    iconPadding: EdgeInsetsDirectional.zero,
                    color: AppTheme.of(context).primary,
                    textStyle: AppTheme.of(context).titleMedium.override(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildAddressItem(AddressesRow address) => InkWell(
        onTap: () {
          FFAppState().setSelectedAddressFromRow(address);
          Navigator.pop(context, address);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: address.isDefault == true
                ? Border.all(
                    color: AppTheme.of(context).primary,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x1A368EFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForLabel(address.addressLine2),
                  color: AppTheme.of(context).primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.addressLine2 ?? 'Address',
                          style: AppTheme.of(context).titleSmall.override(
                                fontWeight: FontWeight.w600,
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
                              style: AppTheme.of(context).bodySmall.override(
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
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.of(context).secondaryText,
                size: 16,
              ),
            ],
          ),
        ),
      );

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
