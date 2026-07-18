import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend/shph_db/database/tables/addresses.dart';
import 'backend/shph_db/database/tables/profiles.dart';
import 'flutter_flow/request_manager.dart';

class FFAppState extends ChangeNotifier {
  factory FFAppState() => _instance;

  FFAppState._internal();
  static FFAppState _instance = FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _phone = prefs.getString('ff_phone') ?? _phone;
    });
    _safeInit(() {
      _isDarkMode = prefs.getBool('ff_isDarkMode') ?? _isDarkMode;
    });
    _safeInit(() {
      _email = prefs.getString('ff_email') ?? _email;
    });
    _safeInit(() {
      _hasCompletedOnboarding =
          prefs.getBool('ff_hasCompletedOnboarding') ?? _hasCompletedOnboarding;
    });
    _safeInit(() {
      _selectedAddressId = prefs.getInt('ff_selectedAddressId');
    });
    _safeInit(() {
      _selectedAddressLabel =
          prefs.getString('ff_selectedAddressLabel') ?? _selectedAddressLabel;
    });
    _safeInit(() {
      _selectedAddressLine1 =
          prefs.getString('ff_selectedAddressLine1') ?? _selectedAddressLine1;
    });
    _safeInit(() {
      _selectedAddressCity =
          prefs.getString('ff_selectedAddressCity') ?? _selectedAddressCity;
    });
    _safeInit(() {
      _selectedLatitude = prefs.getDouble('ff_selectedLatitude');
    });
    _safeInit(() {
      _selectedLongitude = prefs.getDouble('ff_selectedLongitude');
    });
    _safeInit(() {
      _selectedLocationMode =
          prefs.getString('ff_selectedLocationMode') ?? _selectedLocationMode;
    });
    _safeInit(() {
      _locale = prefs.getString('ff_locale') ?? _locale;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _phone = '';
  String get phone => _phone;
  set phone(String value) {
    _phone = value;
    prefs.setString('ff_phone', value);
  }

  bool toggleAgree = false;

  int pincode = 0;

  String tempsignuprole = '';

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  set isDarkMode(bool value) {
    _isDarkMode = value;
    prefs.setBool('ff_isDarkMode', value);
  }

  String _email = '';
  String get email => _email;
  set email(String value) {
    _email = value;
    prefs.setString('ff_email', value);
  }

  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  set hasCompletedOnboarding(bool value) {
    _hasCompletedOnboarding = value;
    prefs.setBool('ff_hasCompletedOnboarding', value);
  }

  int? _selectedAddressId;
  int? get selectedAddressId => _selectedAddressId;

  String _selectedAddressLabel = '';
  String get selectedAddressLabel => _selectedAddressLabel;

  String _selectedAddressLine1 = '';
  String get selectedAddressLine1 => _selectedAddressLine1;

  String _selectedAddressCity = '';
  String get selectedAddressCity => _selectedAddressCity;

  double? _selectedLatitude;
  double? get selectedLatitude => _selectedLatitude;

  double? _selectedLongitude;
  double? get selectedLongitude => _selectedLongitude;

  String _selectedLocationMode = 'device';
  String get selectedLocationMode => _selectedLocationMode;

  double _nearestProviderDistance = 99;
  double get nearestProviderDistance => _nearestProviderDistance;
  set nearestProviderDistance(double value) {
    _nearestProviderDistance = value;
    prefs.setDouble('ff_nearestProviderDistance', value);
  }

  String _locale = 'en';
  String get locale => _locale;
  set locale(String value) {
    _locale = value;
    prefs.setString('ff_locale', value);
    notifyListeners();
  }

  int _notificationCount = 0;
  int get notificationCount => _notificationCount;
  set notificationCount(int value) {
    _notificationCount = value;
    notifyListeners();
  }

  int _unreadConversations = 0;
  int get unreadConversations => _unreadConversations;
  set unreadConversations(int value) {
    _unreadConversations = value;
    notifyListeners();
  }

  bool get hasSelectedLocation =>
      (_selectedLatitude != null && _selectedLongitude != null) ||
      _selectedAddressLine1.isNotEmpty ||
      _selectedAddressLabel.isNotEmpty;

  void setSelectedAddress({
    required int? id,
    required String label,
    required String line1,
    required String city,
    required double? latitude,
    required double? longitude,
    String? locationMode,
  }) {
    _selectedAddressId = id;
    _selectedAddressLabel = label;
    _selectedAddressLine1 = line1;
    _selectedAddressCity = city;
    _selectedLatitude = latitude;
    _selectedLongitude = longitude;
    _selectedLocationMode = locationMode ?? (id == null ? 'device' : 'saved');

    if (id == null) {
      prefs.remove('ff_selectedAddressId');
    } else {
      prefs.setInt('ff_selectedAddressId', id);
    }
    prefs
      ..setString('ff_selectedAddressLabel', label)
      ..setString('ff_selectedAddressLine1', line1)
      ..setString('ff_selectedAddressCity', city);
    if (latitude == null) {
      prefs.remove('ff_selectedLatitude');
    } else {
      prefs.setDouble('ff_selectedLatitude', latitude);
    }
    if (longitude == null) {
      prefs.remove('ff_selectedLongitude');
    } else {
      prefs.setDouble('ff_selectedLongitude', longitude);
    }
    prefs.setString('ff_selectedLocationMode', _selectedLocationMode);

    notifyListeners();
  }

  void setSelectedAddressFromRow(AddressesRow address) {
    setSelectedAddress(
      id: address.id,
      label: address.addressLine2 ?? '',
      line1: address.addressLine1 ?? '',
      city: address.city ?? '',
      latitude: address.latitude,
      longitude: address.longitude,
      locationMode: 'saved',
    );
  }

  void setSelectedDeviceLocation({
    required double latitude,
    required double longitude,
    String label = 'Current location',
    String line1 = 'Current device location',
    String city = '',
  }) {
    setSelectedAddress(
      id: null,
      label: label,
      line1: line1,
      city: city,
      latitude: latitude,
      longitude: longitude,
      locationMode: 'device',
    );
  }

  void clearSelectedAddress() {
    setSelectedAddress(
      id: null,
      label: '',
      line1: '',
      city: '',
      latitude: null,
      longitude: null,
      locationMode: 'device',
    );
  }

  AddressesRow? resolveSelectedSavedAddress(List<AddressesRow> addresses) {
    if (addresses.isEmpty) {
      return null;
    }

    final selectedId = _selectedAddressId;
    if (selectedId != null) {
      for (final address in addresses) {
        if (address.id == selectedId) {
          return address;
        }
      }
    }

    for (final address in addresses) {
      if (address.isDefault == true) {
        return address;
      }
    }

    return addresses.first;
  }

  AddressesRow? syncSelectedSavedAddress(List<AddressesRow> addresses) {
    final address = resolveSelectedSavedAddress(addresses);
    if (address != null) {
      setSelectedAddressFromRow(address);
    }
    return address;
  }

  final _checkIfAccountExistsManager =
      FutureRequestManager<List<ProfilesRow>>();
  Future<List<ProfilesRow>> checkIfAccountExists({
    required Future<List<ProfilesRow>> Function() requestFn,
    String? uniqueQueryKey,
    bool? overrideCache,
  }) =>
      _checkIfAccountExistsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCheckIfAccountExistsCache() => _checkIfAccountExistsManager.clear();
  void clearCheckIfAccountExistsCacheKey(String? uniqueKey) =>
      _checkIfAccountExistsManager.clearRequest(uniqueKey);

  final _getAddressManager = FutureRequestManager<List<AddressesRow>>();
  Future<List<AddressesRow>> getAddress({
    required Future<List<AddressesRow>> Function() requestFn,
    String? uniqueQueryKey,
    bool? overrideCache,
  }) =>
      _getAddressManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearGetAddressCache() => _getAddressManager.clear();
  void clearGetAddressCacheKey(String? uniqueKey) =>
      _getAddressManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}
