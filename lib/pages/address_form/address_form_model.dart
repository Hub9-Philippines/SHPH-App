import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/psgc_service.dart';
import 'address_form_widget.dart' show AddressFormWidget;

class AddressFormModel extends FlutterFlowModel<AddressFormWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for backButton component.
  late BackButtonModel backButtonModel;

  // State field(s) for FullNameTextField widget.
  FocusNode? fullNameTextFieldFocusNode;
  TextEditingController? fullNameTextFieldTextController;
  String? Function(BuildContext, String?)?
      fullNameTextFieldTextControllerValidator;

  // State field(s) for MobileNumberTextField widget.
  FocusNode? mobileNumberTextFieldFocusNode;
  TextEditingController? mobileNumberTextFieldTextController;
  String? Function(BuildContext, String?)?
      mobileNumberTextFieldTextControllerValidator;

  // State field(s) for LabelTextField widget.
  FocusNode? labelTextFieldFocusNode;
  TextEditingController? labelTextFieldTextController;
  String? Function(BuildContext, String?)?
      labelTextFieldTextControllerValidator;

  // State field(s) for StreetAddressTextField widget.
  FocusNode? streetAddressTextFieldFocusNode;
  TextEditingController? streetAddressTextFieldTextController;
  String? Function(BuildContext, String?)?
      streetAddressTextFieldTextControllerValidator;

  // State field(s) for BarangayTextField widget.
  FocusNode? barangayTextFieldFocusNode;
  TextEditingController? barangayTextFieldTextController;
  String? Function(BuildContext, String?)?
      barangayTextFieldTextControllerValidator;

  // State field(s) for CityTextField widget.
  FocusNode? cityTextFieldFocusNode;
  TextEditingController? cityTextFieldTextController;
  String? Function(BuildContext, String?)? cityTextFieldTextControllerValidator;

  // State field(s) for ProvinceTextField widget.
  FocusNode? provinceTextFieldFocusNode;
  TextEditingController? provinceTextFieldTextController;
  String? Function(BuildContext, String?)?
      provinceTextFieldTextControllerValidator;

  // State field(s) for RegionTextField widget.
  FocusNode? regionTextFieldFocusNode;
  TextEditingController? regionTextFieldTextController;
  String? Function(BuildContext, String?)?
      regionTextFieldTextControllerValidator;

  // State field(s) for PostalCodeTextField widget.
  FocusNode? postalCodeTextFieldFocusNode;
  TextEditingController? postalCodeTextFieldTextController;
  String? Function(BuildContext, String?)?
      postalCodeTextFieldTextControllerValidator;

  // Location data
  double? latitude;
  double? longitude;
  String? selectedAddress;

  // Edit mode
  String? editingAddressId;
  bool isDefault = false;

  // PSGC data
  List<Region> regions = [];
  List<Province> provinces = [];
  List<CityMunicipality> citiesMunicipalities = [];
  List<Barangay> barangays = [];

  Region? selectedRegion;
  Province? selectedProvince;
  CityMunicipality? selectedCityMunicipality;
  Barangay? selectedBarangay;

  // PSGC codes
  String? selectedRegionCode;
  String? selectedProvinceCode;
  String? selectedCityMunicipalityCode;
  String? selectedBarangayCode;

  bool isLoadingRegions = false;
  bool isLoadingProvinces = false;
  bool isLoadingCities = false;
  bool isLoadingBarangays = false;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  Future<void> loadRegions() async {
    isLoadingRegions = true;
    try {
      regions = await PSGCService.getRegions();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading regions: $e');
      }
    } finally {
      isLoadingRegions = false;
    }
  }

  Future<void> loadProvinces(String regionCode) async {
    isLoadingProvinces = true;
    try {
      provinces = await PSGCService.getProvincesByRegion(regionCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading provinces: $e');
      }
    } finally {
      isLoadingProvinces = false;
    }
  }

  Future<void> loadCitiesMunicipalities(String regionCode) async {
    isLoadingCities = true;
    try {
      citiesMunicipalities =
          await PSGCService.getCitiesMunicipalitiesByRegion(regionCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cities/municipalities: $e');
      }
    } finally {
      isLoadingCities = false;
    }
  }

  Future<void> loadCitiesMunicipalitiesByProvince(String provinceCode) async {
    isLoadingCities = true;
    try {
      citiesMunicipalities =
          await PSGCService.getCitiesMunicipalitiesByProvince(provinceCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cities/municipalities: $e');
      }
    } finally {
      isLoadingCities = false;
    }
  }

  Future<void> loadBarangays(String cityMunicipalityCode) async {
    isLoadingBarangays = true;
    try {
      barangays = await PSGCService.getBarangaysByCityMunicipality(
          cityMunicipalityCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading barangays: $e');
      }
    } finally {
      isLoadingBarangays = false;
    }
  }

  void onRegionChanged(Region? region) {
    selectedRegion = region;
    selectedRegionCode = region?.code;
    selectedProvince = null;
    selectedProvinceCode = null;
    selectedCityMunicipality = null;
    selectedCityMunicipalityCode = null;
    selectedBarangay = null;
    selectedBarangayCode = null;
    provinces = [];
    citiesMunicipalities = [];
    barangays = [];
    regionTextFieldTextController?.text = region?.regionName ?? '';
    provinceTextFieldTextController?.text = '';
    cityTextFieldTextController?.text = '';
    barangayTextFieldTextController?.text = '';
  }

  void onProvinceChanged(Province? province) {
    selectedProvince = province;
    selectedProvinceCode = province?.code;
    selectedCityMunicipality = null;
    selectedCityMunicipalityCode = null;
    selectedBarangay = null;
    selectedBarangayCode = null;
    citiesMunicipalities = [];
    barangays = [];
    provinceTextFieldTextController?.text = province?.name ?? '';
    cityTextFieldTextController?.text = '';
    barangayTextFieldTextController?.text = '';
  }

  void onCityMunicipalityChanged(CityMunicipality? cityMunicipality) {
    selectedCityMunicipality = cityMunicipality;
    selectedCityMunicipalityCode = cityMunicipality?.code;
    selectedBarangay = null;
    selectedBarangayCode = null;
    barangays = [];
    cityTextFieldTextController?.text = cityMunicipality?.name ?? '';
    barangayTextFieldTextController?.text = '';
  }

  void onBarangayChanged(Barangay? barangay) {
    selectedBarangay = barangay;
    selectedBarangayCode = barangay?.code;
    barangayTextFieldTextController?.text = barangay?.name ?? '';
  }

  @override
  void dispose() {
    backButtonModel.dispose();
    fullNameTextFieldFocusNode?.dispose();
    fullNameTextFieldTextController?.dispose();
    mobileNumberTextFieldFocusNode?.dispose();
    mobileNumberTextFieldTextController?.dispose();
    labelTextFieldFocusNode?.dispose();
    labelTextFieldTextController?.dispose();
    streetAddressTextFieldFocusNode?.dispose();
    streetAddressTextFieldTextController?.dispose();
    barangayTextFieldFocusNode?.dispose();
    barangayTextFieldTextController?.dispose();
    cityTextFieldFocusNode?.dispose();
    cityTextFieldTextController?.dispose();
    provinceTextFieldFocusNode?.dispose();
    provinceTextFieldTextController?.dispose();
    regionTextFieldFocusNode?.dispose();
    regionTextFieldTextController?.dispose();
    postalCodeTextFieldFocusNode?.dispose();
    postalCodeTextFieldTextController?.dispose();
  }
}
