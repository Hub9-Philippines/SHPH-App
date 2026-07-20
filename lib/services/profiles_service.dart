import 'dart:typed_data';

import '/api/bridges/api_row_mapper.dart';
import '/api/resources/kyc_api.dart';
import '/api/resources/users_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class ProfilesService {
  ProfilesService._();
  static final ProfilesService instance = ProfilesService._();

  final _supabase = Supabase.instance.client;
  final _usersApi = ShphUsersApi.instance;
  final _kycApi = ShphKycApi.instance;

  Future<ProfilesRow?> getProfile() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final data = await _usersApi.getMe();
        return ApiRowMapper.profileToRow(data);
      } catch (e) {
        LoggingService.error('SHPH API getProfile failed, falling back: $e',
            tag: 'ProfilesService');
      }
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response == null) return null;
      return ProfilesRow(Map<String, dynamic>.from(response));
    } catch (e) {
      LoggingService.error('Supabase getProfile failed: $e',
          tag: 'ProfilesService');
      return null;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _usersApi.updateMe(data);
        return true;
      } catch (e) {
        LoggingService.error('SHPH API updateProfile failed, falling back: $e',
            tag: 'ProfilesService');
      }
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;
      await _supabase.from('profiles').update(data).eq('id', userId);
      return true;
    } catch (e) {
      LoggingService.error('Supabase updateProfile failed: $e',
          tag: 'ProfilesService');
      return false;
    }
  }

  Future<String?> uploadProfilePhoto(List<int> bytes, String fileName) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final resp = await _usersApi.uploadPhoto(bytes, fileName);
        return resp['photo_url'] ?? resp['photo'] ?? resp['url'] as String?;
      } catch (e) {
        LoggingService.error(
            'SHPH API uploadProfilePhoto failed, falling back: $e',
            tag: 'ProfilesService');
      }
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'profiles/$userId/profile_$timestamp-$fileName';
      final bucket = SupaFlow.client.storage.from('profiles');
      await bucket.uploadBinary(
        storagePath,
        Uint8List.fromList(bytes),
        fileOptions: const FileOptions(contentType: null),
      );
      return bucket.getPublicUrl(storagePath);
    } catch (e) {
      LoggingService.error('Supabase uploadProfilePhoto failed: $e',
          tag: 'ProfilesService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> submitKycDocument({
    required List<int> documentBytes,
    required String fileName,
  }) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final resp = await _kycApi.submitKyc(
            documentBytes: documentBytes, fileName: fileName);
        return resp;
      } catch (e) {
        LoggingService.error('SHPH API submitKyc failed, falling back: $e',
            tag: 'ProfilesService');
      }
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'kyc/$userId/$timestamp-$fileName';
      final bucket = SupaFlow.client.storage.from('profiles');
      await bucket.uploadBinary(
        storagePath,
        Uint8List.fromList(documentBytes),
        fileOptions: const FileOptions(contentType: null),
      );
      final publicUrl = bucket.getPublicUrl(storagePath);

      // Mark profile as submitted
      await _supabase.from('profiles').update({
        'id_document_url': publicUrl,
        'verification_status': 'submitted'
      }).eq('id', userId);

      return {'status': 'submitted', 'document_url': publicUrl};
    } catch (e) {
      LoggingService.error('Supabase submitKyc failed: $e',
          tag: 'ProfilesService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getKycStatus() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _kycApi.getStatus();
      } catch (e) {
        LoggingService.error('SHPH API getKycStatus failed, falling back: $e',
            tag: 'ProfilesService');
      }
    }

    try {
      final user = await getProfile();
      if (user == null) return null;
      return {
        'verification_status': user.verificationStatus,
        'is_face_verified': user.isFaceVerified,
        'submitted_at': user.submittedAt?.toIso8601String(),
      };
    } catch (e) {
      LoggingService.error('Supabase getKycStatus failed: $e',
          tag: 'ProfilesService');
      return null;
    }
  }
}
