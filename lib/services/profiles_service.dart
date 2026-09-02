import '/api/bridges/api_row_mapper.dart';
import '/api/resources/kyc_api.dart';
import '/api/resources/users_api.dart';
import '/backend/supabase/database/tables/profiles.dart';
import '/services/logging_service.dart';

class ProfilesService {
  ProfilesService({ShphUsersApi? usersApi, ShphKycApi? kycApi})
      : _usersApi = usersApi ?? ShphUsersApi.instance,
        _kycApi = kycApi ?? ShphKycApi.instance;

  static final ProfilesService instance = ProfilesService();

  final ShphUsersApi _usersApi;
  final ShphKycApi _kycApi;

  Future<ProfilesRow?> getProfile() async {
    try {
      final data = await _usersApi.getMe();
      final profile = data['profile'] is Map<String, dynamic>
          ? data['profile'] as Map<String, dynamic>
          : data;
      return ApiRowMapper.profileToRow(profile);
    } catch (e) {
      LoggingService.error('getProfile failed: $e', tag: 'ProfilesService');
      return null;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      await _usersApi.updateMe(data);
      await _refreshAuth();
      return true;
    } catch (e) {
      LoggingService.error('updateProfile failed: $e', tag: 'ProfilesService');
      return false;
    }
  }

  Future<void> _refreshAuth() async {
    try {
      final data = await _usersApi.getMe();
      final profile = data['profile'] is Map<String, dynamic>
          ? data['profile'] as Map<String, dynamic>
          : data;
      // Also ensure is_profile_complete is set in current user map
      profile['is_profile_complete'] = true;
    } catch (_) {}
  }

  Future<String?> uploadProfilePhoto(
    List<int> bytes,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final resp = await _usersApi.uploadPhoto(
        bytes,
        fileName,
        onSendProgress: (sent, total) =>
            onProgress?.call(total <= 0 ? 0 : (sent / total).clamp(0, 1)),
      );
      return resp['photo_url'] ?? resp['photo'] ?? resp['url'] as String?;
    } catch (e) {
      LoggingService.error('uploadProfilePhoto failed: $e',
          tag: 'ProfilesService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> submitKycDocument({
    required List<int> documentBytes,
    required String fileName,
  }) async {
    try {
      final resp = await _kycApi.submitKyc(
          documentBytes: documentBytes, fileName: fileName);
      return resp;
    } catch (e) {
      LoggingService.error('submitKycDocument failed: $e',
          tag: 'ProfilesService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getKycStatus() async {
    try {
      return await _kycApi.getStatus();
    } catch (e) {
      LoggingService.error('getKycStatus failed: $e', tag: 'ProfilesService');
      return null;
    }
  }
}
