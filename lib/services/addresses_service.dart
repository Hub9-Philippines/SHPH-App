import '/api/resources/addresses_api.dart';
import '/backend/supabase/database/tables/addresses.dart';
import '/services/logging_service.dart';

/// API-only service for address CRUD operations.
class AddressesService {
  AddressesService._();
  static final AddressesService instance = AddressesService._();

  final _api = ShphAddressesApi.instance;

  Future<List<Map<String, dynamic>>> listAddresses() async {
    try {
      return await _api.listAddresses();
    } catch (e) {
      LoggingService.error('Error listing addresses: $e',
          tag: 'AddressesService');
      rethrow;
    }
  }

  Future<List<AddressesRow>> listAddressRows() async =>
      (await listAddresses()).map(AddressesRow.new).toList();

  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> payload) =>
      _api.createAddress(payload);

  Future<Map<String, dynamic>> getAddress(int id) => _api.getAddress(id);

  Future<Map<String, dynamic>> updateAddress(
          int id, Map<String, dynamic> payload) =>
      _api.updateAddress(id, payload);

  Future<bool> deleteAddress(int id) async {
    try {
      await _api.deleteAddress(id);
      return true;
    } catch (e) {
      LoggingService.error('Error deleting address: $e',
          tag: 'AddressesService');
      return false;
    }
  }

  Future<bool> setDefaultAddress(int id) async {
    try {
      await _api.setDefaultAddress(id);
      return true;
    } catch (e) {
      LoggingService.error('Error setting default address: $e',
          tag: 'AddressesService');
      return false;
    }
  }
}
