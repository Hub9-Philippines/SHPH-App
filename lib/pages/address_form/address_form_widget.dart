import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/addresses_service.dart';
import '/theme/app_theme.dart';
import '/pages/geographic_selection/geographic_selection_widget.dart';
import '/services/psgc_service.dart';
import 'address_form_model.dart';

export 'address_form_model.dart';

class AddressFormWidget extends StatefulWidget {
  const AddressFormWidget({
    super.key,
    this.addressId,
  });

  static String routeName = 'AddressForm';
  static String routePath = '/addressForm';

  final int? addressId;

  @override
  State<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  late AddressFormModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasLoadedRegions = false;
  bool _hasLoadedAddressData = false;
  bool _isRestoringGeography = false;

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
      _hasLoadedRegions = true;
      _restoreGeographicSelectionFromCodes();
      if (mounted) {
        safeSetState(() {});
      }
    });

    if (widget.addressId == null) {
      getCurrentUserLocation(
        defaultLocation: const LatLng(14.5995, 120.9842),
      ).then((loc) {
        if (mounted) {
          setState(() {
            _model.latitude = loc.latitude;
            _model.longitude = loc.longitude;
            _model.selectedAddress = 'Current device location';
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.addressId != null && _model.editingAddressId == null) {
      _model.editingAddressId = widget.addressId.toString();
      _loadAddressData(_model.editingAddressId!);
    }
  }

  Future<void> _loadAddressData(String addressId) async {
    try {
      final addressIdNum = int.tryParse(addressId);
      if (addressIdNum == null) {
        return;
      }
      final address =
          await AddressesService.instance.getAddress(addressIdNum);
      if (address != null) {
        setState(() {
          _model.fullNameTextFieldTextController?.text =
              address.label ?? '';
          _model.labelTextFieldTextController?.text = address.label ?? '';
          _model.streetAddressTextFieldTextController?.text =
              address.street ?? '';
          _model.barangayTextFieldTextController?.text =
              address.barangay ?? '';
          _model.cityTextFieldTextController?.text = address.city ?? '';
          _model.provinceTextFieldTextController?.text =
              address.province ?? '';
          _model.postalCodeTextFieldTextController?.text =
              address.zipCode ?? '';
          _model.latitude = address.latitude;
          _model.longitude = address.longitude;
          if (_model.latitude != null && _model.longitude != null) {
            _model.selectedAddress = address.street;
          }
          _model.isDefault = address.isDefault;
          _model.selectedRegionCode = null;
          _model.selectedProvinceCode = null;
          _model.selectedCityMunicipalityCode = null;
          _model.selectedBarangayCode = null;
        });
        _hasLoadedAddressData = true;
        await _restoreGeographicSelectionFromCodes();

        if (_model.latitude == null || _model.longitude == null) {
          final loc = await getCurrentUserLocation(
            defaultLocation: const LatLng(14.5995, 120.9842),
          );
          if (mounted) {
            setState(() {
              if (_model.latitude == null) {
                _model.latitude = loc.latitude;
                _model.longitude = loc.longitude;
                _model.selectedAddress = 'Current device location';
              }
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading address: $e')),
        );
      }
    }
  }

  Future<void> _restoreGeographicSelectionFromCodes() async {
    if (!_hasLoadedRegions ||
        !_hasLoadedAddressData ||
        _isRestoringGeography ||
        _model.selectedRegionCode == null ||
        _model.selectedRegionCode!.isEmpty) {
      return;
    }

    _isRestoringGeography = true;
    try {
      final region = _model.regions.firstWhereOrNull(
        (item) => item.code == _model.selectedRegionCode,
      );
      if (region == null) {
        return;
      }

      _model.selectedRegion = region;
      _model.regionTextFieldTextController?.text = region.regionName;

      if (_model.selectedProvinceCode != null &&
          _model.selectedProvinceCode!.isNotEmpty) {
        await _model.loadProvinces(region.code);
        _model.selectedProvince = _model.provinces.firstWhereOrNull(
          (item) => item.code == _model.selectedProvinceCode,
        );
        _model.provinceTextFieldTextController?.text =
            _model.selectedProvince?.name ?? '';
      } else {
        _model.selectedProvince = null;
        _model.provinces = [];
        _model.provinceTextFieldTextController?.text = '';
      }

      if (_model.selectedProvince != null) {
        await _model.loadCitiesMunicipalitiesByProvince(
          _model.selectedProvince!.code,
        );
      } else {
        await _model.loadCitiesMunicipalities(region.code);
      }

      _model.selectedCityMunicipality = _model.citiesMunicipalities
          .firstWhereOrNull(
              (item) => item.code == _model.selectedCityMunicipalityCode);
      _model.cityTextFieldTextController?.text =
          _model.selectedCityMunicipality?.name ?? '';

      if (_model.selectedCityMunicipality != null) {
        await _model.loadBarangays(_model.selectedCityMunicipality!.code);
        _model.selectedBarangay = _model.barangays.firstWhereOrNull(
          (item) => item.code == _model.selectedBarangayCode,
        );
        _model.barangayTextFieldTextController?.text =
            _model.selectedBarangay?.name ?? '';
      } else {
        _model.selectedBarangay = null;
        _model.barangays = [];
        _model.barangayTextFieldTextController?.text = '';
      }

      if (mounted) {
        safeSetState(() {});
      }
    } finally {
      _isRestoringGeography = false;
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
      final editingId =
          int.tryParse(_model.editingAddressId ?? '');

      final labelValue =
          _model.labelTextFieldTextController?.text.trim().isNotEmpty == true
              ? _model.labelTextFieldTextController!.text.trim()
              : _model.fullNameTextFieldTextController?.text.trim() ?? '';
      final streetValue =
          _model.streetAddressTextFieldTextController?.text.trim() ?? '';

      final addressData = {
        'label': labelValue,
        'street': streetValue,
        'barangay': _model.barangayTextFieldTextController?.text,
        'city': _model.cityTextFieldTextController?.text,
        'province': _model.provinceTextFieldTextController?.text,
        'zip_code': _model.postalCodeTextFieldTextController?.text,
        'latitude': _model.latitude,
        'longitude': _model.longitude,
        'is_default': _model.isDefault,
      };

      final savedAddress = await AddressesService.instance.saveAddress(
        addressData,
        editingId: editingId,
      );
      if (savedAddress == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving address')),
          );
        }
        return;
      }

      final shouldRefreshSelectedAddress =
          editingId != null &&
                  ((FFAppState().selectedAddressId == editingId) ||
                      (_model.isDefault &&
                          FFAppState().selectedLocationMode == 'saved')) ||
              _model.isDefault ||
              !FFAppState().hasSelectedLocation;
      if (shouldRefreshSelectedAddress) {
        FFAppState().setSelectedAddressFromMap(savedAddress.toSelectedMap());
      }

      // Clear the address cache to ensure changes are fetched fresh
      FFAppState().clearGetAddressCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editingId != null
                  ? 'Address updated successfully'
                  : 'Address added successfully',
            ),
          ),
        );
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
                    font: GoogleFonts.plusJakartaSans(
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
                        maxLength: 11,
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
                      // Location picker - moved to first position under Address Details
                      _buildLocationPicker(),
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
                                color: AppTheme.of(context).onPrimary,
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
                font: GoogleFonts.plusJakartaSans(
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
                ? AppTheme.of(context).primary.withValues(alpha: 0.1)
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
                        ? AppTheme.of(context).alternate.withValues(alpha: 0.5)
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
                          ? AppTheme.of(context).secondaryText.withValues(alpha: 0.5)
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
                      // Determine the correct parent code for fetching cities:
                      // If a province is selected, use its code (cities under province)
                      // Otherwise, use the region code (e.g. NCR with no provinces)
                      final parentCode = _model.selectedProvince?.code ??
                          _model.selectedRegion?.code;
                      if (parentCode == null) return;

                      final result = await context.pushNamed(
                        GeographicSelectionWidget.routeName,
                        extra: {
                          'selectionType':
                              GeographicSelectionType.cityMunicipality,
                          'parentCode': parentCode,
                          'isRegionFallback': _model.selectedProvince == null,
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
                        ? AppTheme.of(context).alternate.withValues(alpha: 0.5)
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
                          ? AppTheme.of(context).secondaryText.withValues(alpha: 0.5)
                          : AppTheme.of(context).secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  void _showBarangayBottomSheet() {
    if (_model.barangays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No barangays available for this city/municipality'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final searchController = TextEditingController();
        final searchFocus = FocusNode();
        List<Barangay> filteredBarangays = List.from(_model.barangays);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).alternate,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select Barangay',
                        style: AppTheme.of(context).titleLarge.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Search field
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.of(context).alternate,
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          focusNode: searchFocus,
                          onChanged: (value) {
                            setSheetState(() {
                              filteredBarangays = _model.barangays
                                  .where((b) => b.name
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search barangay...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppTheme.of(context).secondaryText,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Barangay list
                      Expanded(
                        child: filteredBarangays.isEmpty
                            ? Center(
                                child: Text(
                                  'No barangays found',
                                  style: AppTheme.of(context).bodyMedium,
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filteredBarangays.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final barangay = filteredBarangays[index];
                                  final isSelected = barangay.code ==
                                      _model.selectedBarangayCode;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _model.onBarangayChanged(barangay);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              barangay.name,
                                              style: AppTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                    color: isSelected
                                                        ? AppTheme.of(context)
                                                            .primary
                                                        : AppTheme.of(context)
                                                            .primaryText,
                                                  ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check,
                                              color:
                                                  AppTheme.of(context).primary,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

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
                  : _showBarangayBottomSheet,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _model.selectedCityMunicipality == null
                        ? AppTheme.of(context).alternate.withValues(alpha: 0.5)
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
                          ? AppTheme.of(context).secondaryText.withValues(alpha: 0.5)
                          : AppTheme.of(context).secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  /// Opens the pin location map. When the user submits, the result
  /// includes lat/lng and an address string. The selected location
  /// is shown as a preview card (which is tappable to re-pin).
  Future<void> _openPinLocation() async {
    LatLng startLocation;
    if (_model.latitude != null && _model.longitude != null) {
      startLocation = LatLng(_model.latitude!, _model.longitude!);
    } else {
      startLocation = await getCurrentUserLocation(
        defaultLocation: const LatLng(14.5995, 120.9842),
      );
    }

    if (!mounted) return;
    final result = await context.pushNamed(
      PinLocationWidget.routeName,
      extra: startLocation,
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _model.latitude = result['latitude'] as double?;
        _model.longitude = result['longitude'] as double?;
        if (result['address'] != null &&
            (result['address'] as String).isNotEmpty) {
          _model.selectedAddress = result['address'] as String?;
        } else {
          _model.selectedAddress ??= 'Pinned location';
        }
      });
    }
  }

  /// Builds the location picker. Shows a pin preview when a location
  /// is already selected, or a "Pin location on map" placeholder.
  Widget _buildLocationPicker() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pin Location',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _openPinLocation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _model.latitude != null
                        ? AppTheme.of(context).primary
                        : AppTheme.of(context).alternate,
                    width: _model.latitude != null ? 2 : 1,
                  ),
                ),
                child: _model.latitude != null
                    ? _buildPinPreview()
                    : _buildPinPlaceholder(),
              ),
            ),
          ],
        ),
      );

  Widget _buildPinPlaceholder() => Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppTheme.of(context).secondaryText,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pin location on map (optional)',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppTheme.of(context).secondaryText,
            size: 16,
          ),
        ],
      );

  Widget _buildPinPreview() => Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.of(context).primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: AppTheme.of(context).primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _model.selectedAddress ?? 'Pinned location',
                  style: AppTheme.of(context).bodyMedium.override(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.of(context).primaryText,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_model.latitude!.toStringAsFixed(6)}, ${_model.longitude!.toStringAsFixed(6)}',
                  style: AppTheme.of(context).bodySmall.override(
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Change',
            style: AppTheme.of(context).bodySmall.override(
                  color: AppTheme.of(context).primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppTheme.of(context).primary,
            size: 14,
          ),
        ],
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
                final editingId = int.tryParse(_model.editingAddressId ?? '');
                final deletedSelectedAddress =
                    FFAppState().selectedLocationMode == 'saved' &&
                        editingId != null &&
                        FFAppState().selectedAddressId == editingId;

                if (editingId == null) {
                  return;
                }
                await AddressesService.instance.deleteAddress(editingId);
                FFAppState().clearGetAddressCache();

                if (deletedSelectedAddress) {
                  final remainingAddresses =
                      await AddressesService.instance.getAddresses();
                  final remainingMaps =
                      remainingAddresses.map((a) => a.toSelectedMap()).toList();
                  final nextAddress = FFAppState()
                      .syncSelectedSavedAddressFromMap(remainingMaps);
                  if (nextAddress == null) {
                    FFAppState().clearSelectedAddress();
                  }
                }

                if (!context.mounted) return;
                Navigator.pop(context);
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Address deleted successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting address: $e')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.of(context).error)),
          ),
        ],
      ),
    );
  }
}
