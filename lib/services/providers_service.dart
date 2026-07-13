import '/api/bridges/api_row_mapper.dart';
import '/api/resources/providers_api.dart';
import '/api/resources/users_api.dart';
import '/services/logging_service.dart';

/// Service for provider-specific profile operations.
/// Wraps [ShphProvidersApi] with the API-first + Supabase fallback pattern.
class ProvidersService {
  ProvidersService._();
  static final ProvidersService instance = ProvidersService._();

  final _api = ShphProvidersApi.instance;
  final _usersApi = ShphUsersApi.instance;

  /// GET /api/providers/me/ — own provider details
  Future<Map<String, dynamic>> getMyProviderProfile() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.getMyProviderProfile();
      } catch (e) {
        LoggingService.error(
          'SHPH API getMyProviderProfile failed, falling back: $e',
          tag: 'ProvidersService',
        );
      }
    }
    // Fallback: use users_api to get profile with role=provider
    try {
      return await _usersApi.getMe();
    } catch (e) {
      LoggingService.error(
        'Fallback getMyProviderProfile failed: $e',
        tag: 'ProvidersService',
      );
      return {};
    }
  }

  /// PATCH /api/providers/me/ — update provider-specific fields
  Future<Map<String, dynamic>> updateMyProviderProfile(
    Map<String, dynamic> data,
  ) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.updateMyProviderProfile(data);
      } catch (e) {
        LoggingService.error(
          'SHPH API updateMyProviderProfile failed, falling back: $e',
          tag: 'ProvidersService',
        );
      }
    }
    try {
      await _usersApi.updateMe(data);
      return data;
    } catch (e) {
      LoggingService.error(
        'Fallback updateMyProviderProfile failed: $e',
        tag: 'ProvidersService',
      );
      return {};
    }
  }

  /// GET /api/providers/{id}/ — public provider profile
  Future<Map<String, dynamic>> getProviderProfile(int id) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.getProviderProfile(id);
      } catch (e) {
        LoggingService.error(
          'SHPH API getProviderProfile failed, falling back: $e',
          tag: 'ProvidersService',
        );
      }
    }
    return {};
  }

  /// GET /api/providers/ — search/list providers
  Future<List<Map<String, dynamic>>> listProviders({
    String? search,
    String? category,
    int? page,
  }) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final data = await _api.listProviders(
          search: search,
          category: category,
          page: page,
        );
        return (data['results'] as List?)?.cast<Map<String, dynamic>>() ??
               (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      } catch (e) {
        LoggingService.error(
          'SHPH API listProviders failed, falling back: $e',
          tag: 'ProvidersService',
        );
      }
    }
    return [];
  }
}
