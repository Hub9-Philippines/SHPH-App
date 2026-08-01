import '/api/models/address.dart';
import '/api/resources/profiles_api.dart';
import '/services/logging_service.dart';

class AddressesService {
  AddressesService._();
  static final AddressesService instance = AddressesService._();

  final _profilesApi = ShphProfilesApi.instance;

  Future<List<ShphAddress>> getAddresses() async {
    try {
      final result = await _profilesApi.listAddresses();
      return result.results;
    } catch (e) {
      LoggingService.error('Failed to load addresses: $e',
          tag: 'AddressesService');
      return [];
    }
  }

  Future<ShphAddress?> getAddress(int id) async {
    try {
      return await _profilesApi.getAddress(id);
    } catch (e) {
      LoggingService.error('Failed to load address $id: $e',
          tag: 'AddressesService');
      return null;
    }
  }

  Future<ShphAddress?> saveAddress(
    Map<String, dynamic> payload, {
    int? editingId,
  }) async {
    try {
      if (editingId != null) {
        return await _profilesApi.updateAddress(editingId, payload);
      }
      return await _profilesApi.createAddress(payload);
    } catch (e) {
      LoggingService.error('Failed to save address: $e',
          tag: 'AddressesService');
      return null;
    }
  }

  Future<bool> deleteAddress(int id) async {
    try {
      await _profilesApi.deleteAddress(id);
      return true;
    } catch (e) {
      LoggingService.error('Failed to delete address $id: $e',
          tag: 'AddressesService');
      return false;
    }
  }

  Future<ShphAddress?> setDefault(int id) async {
    try {
      return await _profilesApi.setDefaultAddress(id);
    } catch (e) {
      LoggingService.error('Failed to set default address $id: $e',
          tag: 'AddressesService');
      return null;
    }
  }
}
