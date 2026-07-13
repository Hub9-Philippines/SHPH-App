import '/api/bridges/api_row_mapper.dart';
import '/api/resources/addresses_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

/// Service for address CRUD operations.
/// API-first with Supabase fallback pattern.
class AddressesService {
  AddressesService._();
  static final AddressesService instance = AddressesService._();

  final _supabase = Supabase.instance.client;
  final _api = ShphAddressesApi.instance;

  /// GET /api/addresses/ — list user addresses
  Future<List<Map<String, dynamic>>> listAddresses() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.listAddresses();
      } catch (e) {
        LoggingService.error(
          'SHPH API listAddresses failed, falling back: $e',
          tag: 'AddressesService',
        );
      }
    }
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final result = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);
      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error listing addresses: $e', tag: 'AddressesService');
      return [];
    }
  }

  /// POST /api/addresses/ — create a new address
  Future<Map<String, dynamic>?> createAddress(Map<String, dynamic> payload) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.createAddress(payload);
      } catch (e) {
        LoggingService.error(
          'SHPH API createAddress failed, falling back: $e',
          tag: 'AddressesService',
        );
      }
    }
    try {
      final result = await _supabase
          .from('addresses')
          .insert(payload)
          .select()
          .single();
      return result;
    } catch (e) {
      LoggingService.error('Error creating address: $e', tag: 'AddressesService');
      return null;
    }
  }

  /// GET /api/addresses/{id}/ — get a single address
  Future<Map<String, dynamic>?> getAddress(int id) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.getAddress(id);
      } catch (e) {
        LoggingService.error(
          'SHPH API getAddress failed, falling back: $e',
          tag: 'AddressesService',
        );
      }
    }
    try {
      final result = await _supabase
          .from('addresses')
          .select()
          .eq('id', id)
          .maybeSingle();
      return result;
    } catch (e) {
      LoggingService.error('Error getting address: $e', tag: 'AddressesService');
      return null;
    }
  }

  /// PATCH /api/addresses/{id}/ — update an address
  Future<Map<String, dynamic>?> updateAddress(int id, Map<String, dynamic> payload) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.updateAddress(id, payload);
      } catch (e) {
        LoggingService.error(
          'SHPH API updateAddress failed, falling back: $e',
          tag: 'AddressesService',
        );
      }
    }
    try {
      final result = await _supabase
          .from('addresses')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return result;
    } catch (e) {
      LoggingService.error('Error updating address: $e', tag: 'AddressesService');
      return null;
    }
  }

  /// DELETE /api/addresses/{id}/ — delete an address
  Future<bool> deleteAddress(int id) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _api.deleteAddress(id);
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API deleteAddress failed, falling back: $e',
          tag: 'AddressesService',
        );
      }
    }
    try {
      await _supabase.from('addresses').delete().eq('id', id);
      return true;
    } catch (e) {
      LoggingService.error('Error deleting address: $e', tag: 'AddressesService');
      return false;
    }
  }
}
