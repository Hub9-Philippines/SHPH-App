import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend/supabase/supabase.dart';
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
