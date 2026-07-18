import '/api/bridges/api_row_mapper.dart';
import '/api/resources/kyc_api.dart';
import '/api/resources/users_api.dart';
import '/backend/shph_db/database/tables/profiles.dart';
import '/services/logging_service.dart';

class ProfilesService {
  ProfilesService._();
  static final ProfilesService instance = ProfilesService._();

  final _usersApi = ShphUsersApi.instance;
  final _kycApi = ShphKycApi.instance;

  Future<ProfilesRow?> getProfile() async {
    try {
      final data = await _usersApi.getMe();
      return ApiRowMapper.profileToRow(data);
    } catch (e) {
      LoggingService.error('getProfile failed: $e', tag: 'ProfilesService');
      return null;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      await _usersApi.updateMe(data);
      return true;
    } catch (e) {
      LoggingService.error('updateProfile failed: $e', tag: 'ProfilesService');
      return false;
    }
  }

  Future<String?> uploadProfilePhoto(List<int> bytes, String fileName) async {
    try {
      final resp = await _usersApi.uploadPhoto(bytes, fileName);
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
      return await _kycApi.submitKyc(
          documentBytes: documentBytes, fileName: fileName);
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
