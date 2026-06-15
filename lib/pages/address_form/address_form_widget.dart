import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/pages/geographic_selection/geographic_selection_widget.dart';
import '/services/psgc_service.dart';
import '/theme/app_theme.dart';
import 'address_form_model.dart';

export 'address_form_model.dart';

class AddressFormWidget extends StatefulWidget {
  const AddressFormWidget({super.key});

  static String routeName = 'AddressForm';
  static String routePath = '/addressForm';

  @override
  State<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  late AddressFormModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, AddressFormModel.new);

    // Initialize all text controllers
    _model.fullNameTextFieldTextController ??= TextEditingController();
    _model.fullNameTextFieldFocusNode ??= FocusNode();

    _model.mobileNumberTextFieldTextController ??= TextEditingController();
    _model.mobileNumberTextFieldFocusNode ??= FocusNode();
    _model.mobileNumberTextFieldFocusNode!
        .addListener(() => safeSetState(() {}));

    _model.labelTextFieldTextController ??= TextEditingController();
    _model.labelTextFieldFocusNode ??= FocusNode();

    _model.streetAddressTextFieldTextController ??= TextEditingController();
    _model.streetAddressTextFieldFocusNode ??= FocusNode();

    _model.barangayTextFieldTextController ??= TextEditingController();
    _model.barangayTextFieldFocusNode ??= FocusNode();

    _model.cityTextFieldTextController ??= TextEditingController();
    _model.cityTextFieldFocusNode ??= FocusNode();

    _model.provinceTextFieldTextController ??= TextEditingController();
    _model.provinceTextFieldFocusNode ??= FocusNode();

    _model.regionTextFieldTextController ??= TextEditingController();
    _model.regionTextFieldFocusNode ??= FocusNode();

    _model.postalCodeTextFieldTextController ??= TextEditingController();
    _model.postalCodeTextFieldFocusNode ??= FocusNode();

    // Load regions on init
    _model.loadRegions().then((_) {
      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if editing an existing address
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null &&
        args['addressId'] != null &&
        _model.editingAddressId == null) {
      _model.editingAddressId = args['addressId'] as String;
      _loadAddressData(_model.editingAddressId!);
    }
  }

  Future<void> _loadAddressData(String addressId) async {
    try {
      final addresses = await AddressesTable().queryRows(
        queryFn: (q) => q.eq('id', addressId),
      );
      if (addresses.isNotEmpty) {
        final address = addresses.first;
        setState(() {
          _model.fullNameTextFieldTextController?.text = address.fullName ?? '';
          _model.mobileNumberTextFieldTextController?.text =
              address.phoneNumber ?? '';
          _model.streetAddressTextFieldTextController?.text =
              address.addressLine1 ?? '';
          _model.barangayTextFieldTextController?.text = address.barangay ?? '';
          _model.cityTextFieldTextController?.text = address.city ?? '';
          _model.provinceTextFieldTextController?.text = address.province ?? '';
          _model.regionTextFieldTextController?.text = address.region ?? '';
          _model.postalCodeTextFieldTextController?.text =
              address.postalCode ?? '';
          _model.latitude = address.latitude;
          _model.longitude = address.longitude;
          _model.isDefault = address.isDefault ?? false;
          _model.selectedRegionCode = address.regionCode;
          _model.selectedProvinceCode = address.provinceCode;
          _model.selectedCityMunicipalityCode = address.cityMunicipalityCode;
          _model.selectedBarangayCode = address.barangayCode;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading address: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_model.formKey.currentState!.validate()) {
      return;
    }

    try {
      final addressData = {
        'user_id': currentUserUid,
        'full_name': _model.fullNameTextFieldTextController?.text,
        'phone_number': _model.mobileNumberTextFieldTextController?.text,
        'address_line1': _model.streetAddressTextFieldTextController?.text,
        'address_line2': _model.labelTextFieldTextController?.text,
        'barangay': _model.barangayTextFieldTextController?.text,
        'barangay_code': _model.selectedBarangayCode,
        'city': _model.cityTextFieldTextController?.text,
        'city_municipality_code': _model.selectedCityMunicipalityCode,
        'province': _model.provinceTextFieldTextController?.text,
        'province_code': _model.selectedProvinceCode,
        'region': _model.regionTextFieldTextController?.text,
        'region_code': _model.selectedRegionCode,
        'postal_code': _model.postalCodeTextFieldTextController?.text,
        'latitude': _model.latitude,
        'longitude': _model.longitude,
        'is_default': _model.isDefault,
      };

      if (_model.editingAddressId != null) {
        // Update existing address
        await AddressesTable().update(
          data: addressData,
          matchingRows: (q) => q.eq('id', _model.editingAddressId!),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully')),
          );
        }
      } else {
        // Create new address
        await AddressesTable().insert(addressData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address added successfully')),
          );
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving address: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              _model.editingAddressId != null ? 'Edit address' : 'New address',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
            actions: [
              if (_model.editingAddressId != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _showDeleteConfirmation,
                ),
            ],
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 20),
                child: Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Contact Information'),
                      _buildTextField(
                        controller: _model.fullNameTextFieldTextController,
                        focusNode: _model.fullNameTextFieldFocusNode,
                        label: 'Full name',
                        hint: 'Enter your full name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _model.mobileNumberTextFieldTextController,
                        focusNode: _model.mobileNumberTextFieldFocusNode,
                        label: 'Mobile number',
                        hint: '09XX XXX XXXX',
                        keyboardType: TextInputType.phone,
                        maxLength: 13,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Address Details'),
                      _buildLabelSelector(),
                      _buildTextField(
                        controller: _model.streetAddressTextFieldTextController,
                        focusNode: _model.streetAddressTextFieldFocusNode,
                        label: 'Street address',
                        hint: 'House/Unit number, Street name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your street address';
                          }
                          return null;
                        },
                      ),
                      _buildRegionDropdown(),
                      _buildProvinceDropdown(),
                      _buildCityDropdown(),
                      _buildBarangayDropdown(),
                      _buildTextField(
                        controller: _model.postalCodeTextFieldTextController,
                        focusNode: _model.postalCodeTextFieldFocusNode,
                        label: 'Postal code',
                        hint: 'Enter postal code',
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Location'),
                      _buildLocationPicker(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: _model.isDefault,
                            onChanged: (value) {
                              setState(() {
                                _model.isDefault = value ?? false;
                              });
                            },
                            activeColor: AppTheme.of(context).primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Set as default address',
                            style: AppTheme.of(context).bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      FFButtonWidget(
                        onPressed: _saveAddress,
                        text: _model.editingAddressId != null
                            ? 'Update address'
                            : 'Save address',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56,
                          color: AppTheme.of(context).primary,
                          textStyle: AppTheme.of(context).titleMedium.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: AppTheme.of(context).bodyLarge.override(
                font: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
                color: AppTheme.of(context).primaryText,
              ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (_) => EasyDebounce.debounce(
            '_model.textField',
            const Duration(milliseconds: 200),
            () => safeSetState(() {}),
          ),
          autofocus: false,
          textInputAction: TextInputAction.next,
          obscureText: false,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).secondaryText,
                ),
            hintStyle: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).secondaryText,
                ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.of(context).alternate,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.of(context).primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.of(context).error,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.of(context).error,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.of(context).primaryBackground,
            contentPadding:
                const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
            suffixIcon: controller?.text.isNotEmpty == true
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppTheme.of(context).secondaryText,
                      size: 20,
                    ),
                    onPressed: () {
                      controller?.clear();
                      safeSetState(() {});
                    },
                  )
                : null,
          ),
          style: AppTheme.of(context).bodyMedium.override(
                color: AppTheme.of(context).primaryText,
              ),
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          buildCounter: maxLength != null
              ? (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null
              : null,
          cursorColor: AppTheme.of(context).primaryText,
          validator: validator,
        ),
      );

  Widget _buildLabelSelector() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Label',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildLabelChip('Home', Icons.home_rounded),
                _buildLabelChip('Work', Icons.work),
                _buildLabelChip('Partner', Icons.favorite_rounded),
                _buildLabelChip('Other', Icons.location_on_rounded),
              ],
            ),
          ],
        ),
      );

  Widget _buildLabelChip(String label, IconData icon) => InkWell(
        onTap: () {
          setState(() {
            _model.labelTextFieldTextController?.text = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _model.labelTextFieldTextController?.text == label
                ? AppTheme.of(context).primary.withOpacity(0.1)
                : AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _model.labelTextFieldTextController?.text == label
                  ? AppTheme.of(context).primary
                  : AppTheme.of(context).alternate,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: _model.labelTextFieldTextController?.text == label
                    ? AppTheme.of(context).primary
                    : AppTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.of(context).bodySmall.override(
                      color: _model.labelTextFieldTextController?.text == label
                          ? AppTheme.of(context).primary
                          : AppTheme.of(context).secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      );

  Widget _buildRegionDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Region',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final result = await context.pushNamed(
                  GeographicSelectionWidget.routeName,
                  extra: {
                    'selectionType': GeographicSelectionType.region,
                  },
                );
                if (result != null && result is Region) {
                  setState(() {
                    _model.onRegionChanged(result);
                    _model.loadProvinces(result.code).then((_) {
                      if (mounted) safeSetState(() {});
                    });
                    _model.loadCitiesMunicipalities(result.code).then((_) {
                      if (mounted) safeSetState(() {});
                    });
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.of(context).alternate,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _model.selectedRegion?.regionName ?? 'Select region',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: _model.selectedRegion != null
                                  ? AppTheme.of(context).primaryText
                                  : AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.of(context).secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildProvinceDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Province',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _model.selectedRegion == null
                  ? null
                  : () async {
                      final result = await context.pushNamed(
                        GeographicSelectionWidget.routeName,
                        extra: {
                          'selectionType': GeographicSelectionType.province,
                          'parentCode': _model.selectedRegion?.code,
                        },
                      );
                      if (result != null && result is Province) {
                        setState(() {
                          _model.onProvinceChanged(result);
                          _model
                              .loadCitiesMunicipalitiesByProvince(result.code)
                              .then((_) {
                            if (mounted) safeSetState(() {});
                          });
                        });
                      }
                    },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _model.selectedRegion == null
                        ? AppTheme.of(context).alternate.withOpacity(0.5)
                        : AppTheme.of(context).alternate,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _model.selectedProvince?.name ?? 'Select province',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: _model.selectedProvince != null
                                  ? AppTheme.of(context).primaryText
                                  : AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: _model.selectedRegion == null
                          ? AppTheme.of(context).secondaryText.withOpacity(0.5)
                          : AppTheme.of(context).secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildCityDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City/Municipality',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: (_model.selectedRegion == null &&
                      _model.selectedProvince == null)
                  ? null
                  : () async {
                      final result = await context.pushNamed(
                        GeographicSelectionWidget.routeName,
                        extra: {
                          'selectionType':
                              GeographicSelectionType.cityMunicipality,
                          'parentCode': _model.selectedProvince?.code ??
                              _model.selectedRegion?.code,
                        },
                      );
                      if (result != null && result is CityMunicipality) {
                        setState(() {
                          _model.onCityMunicipalityChanged(result);
                          _model.loadBarangays(result.code).then((_) {
                            if (mounted) safeSetState(() {});
                          });
                        });
                      }
                    },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_model.selectedRegion == null &&
                            _model.selectedProvince == null)
                        ? AppTheme.of(context).alternate.withOpacity(0.5)
                        : AppTheme.of(context).alternate,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _model.selectedCityMunicipality?.name ??
                            'Select city/municipality',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: _model.selectedCityMunicipality != null
                                  ? AppTheme.of(context).primaryText
                                  : AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: (_model.selectedRegion == null &&
                              _model.selectedProvince == null)
                          ? AppTheme.of(context).secondaryText.withOpacity(0.5)
                          : AppTheme.of(context).secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBarangayDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Barangay',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _model.selectedCityMunicipality == null
                  ? null
                  : () async {
                      final result = await context.pushNamed(
                        GeographicSelectionWidget.routeName,
                        extra: {
                          'selectionType': GeographicSelectionType.barangay,
                          'parentCode': _model.selectedCityMunicipality?.code,
                        },
                      );
                      if (result != null && result is Barangay) {
                        setState(() {
                          _model.onBarangayChanged(result);
                        });
                      }
                    },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _model.selectedCityMunicipality == null
                        ? AppTheme.of(context).alternate.withOpacity(0.5)
                        : AppTheme.of(context).alternate,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _model.selectedBarangay?.name ?? 'Select barangay',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: _model.selectedBarangay != null
                                  ? AppTheme.of(context).primaryText
                                  : AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: _model.selectedCityMunicipality == null
                          ? AppTheme.of(context).secondaryText.withOpacity(0.5)
                          : AppTheme.of(context).secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildLocationPicker() => InkWell(
        onTap: () async {
          final result = await context.pushNamed(PinLocationWidget.routeName);
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _model.latitude = result['latitude'] as double?;
              _model.longitude = result['longitude'] as double?;
              _model.selectedAddress = result['address'] as String?;
            });
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.of(context).alternate,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: _model.latitude != null
                    ? AppTheme.of(context).primary
                    : AppTheme.of(context).secondaryText,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _model.selectedAddress ??
                          'Pin location on map (optional)',
                      style: AppTheme.of(context).bodyMedium.override(
                            color: _model.latitude != null
                                ? AppTheme.of(context).primaryText
                                : AppTheme.of(context).secondaryText,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_model.latitude != null)
                      Text(
                        'Lat: ${_model.latitude!.toStringAsFixed(6)}, Lng: ${_model.longitude!.toStringAsFixed(6)}',
                        style: AppTheme.of(context).bodySmall.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await AddressesTable().delete(
                  matchingRows: (q) => q.eq('id', _model.editingAddressId!),
                );
                if (mounted) {
                  Navigator.pop(context);
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Address deleted successfully')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting address: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
