import '/api/bridges/api_row_mapper.dart';
import '/api/resources/kyc_api.dart';
import '/api/resources/users_api.dart';
import '/backend/supabase/database/tables/profiles.dart';
import '/services/logging_service.dart';

class ProfilesService {
  ProfilesService._();
  static final ProfilesService instance = ProfilesService._();
  final _users = ShphUsersApi.instance;
  final _kyc = ShphKycApi.instance;

  Future<ProfilesRow?> getProfile() async {
    try {
      return ApiRowMapper.profileToRow(await _users.getMe());
    } catch (e) {
      LoggingService.error('Profile fetch failed: $e', tag: 'ProfilesService');
      return null;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      await _users.updateMe(data);
      return true;
    } catch (e) {
      LoggingService.error('Profile update failed: $e', tag: 'ProfilesService');
      return false;
    }
  }

  Future<String?> uploadProfilePhoto(List<int> bytes, String fileName) async {
    try {
      final data = await _users.uploadPhoto(bytes, fileName);
      return (data['photo_url'] ?? data['photo'] ?? data['url'])?.toString();
    } catch (e) {
      LoggingService.error('Photo upload failed: $e', tag: 'ProfilesService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> submitKycDocument({
    required List<int> documentBytes,
    required String fileName,
  }) async {
    try {
      return await _kyc.submitKyc(
          documentBytes: documentBytes, fileName: fileName);
    } catch (e) {
      LoggingService.error('KYC submission failed: $e', tag: 'ProfilesService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getKycStatus() async {
    try {
      return await _kyc.getStatus();
    } catch (e) {
      LoggingService.error('KYC status failed: $e', tag: 'ProfilesService');
      return null;
    }
  }
}
