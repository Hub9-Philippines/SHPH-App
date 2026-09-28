import 'package:dio/dio.dart' show FormData, MultipartFile;

import '/api/resources/bookings_api.dart';
import '/api/resources/chat_api.dart';
import '/api/shph_api_exception.dart';
import '/auth/base_auth_user_provider.dart';
import '/services/logging_service.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _chatApi = ShphChatApi.instance;

  /// Returns a list of chat room maps. Structure depends on backend.
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final dynamic resp = await _chatApi.listThreads();
      final results = resp['results'];
      if (results is List) {
        return List<Map<String, dynamic>>.from(results);
      }
      // If API returns a flat list
      if (resp is List) {
        return List<Map<String, dynamic>>.from(resp);
      }
      return const [];
    } catch (e) {
      LoggingService.error('getChatRooms failed: $e', tag: 'ChatService');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String threadId) async {
    try {
      final dynamic resp = await _chatApi.listMessages(threadId);
      final results = resp['results'];
      if (results is List) {
        return List<Map<String, dynamic>>.from(results);
      }
      if (resp is List) {
        return List<Map<String, dynamic>>.from(resp);
      }
      return const [];
    } catch (e) {
      LoggingService.error('getMessages failed: $e', tag: 'ChatService');
      return [];
    }
  }

  Future<bool> sendMessage(String threadId, String content) async {
    try {
      await _chatApi.sendMessage(threadId, content);
      return true;
    } catch (e) {
      LoggingService.error('sendMessage failed: $e', tag: 'ChatService');
      return false;
    }
  }

  /// Uploads an image file to the thread and sends it as an attachment
  /// message. Returns true when the message was sent.
  Future<bool> sendImageMessage(
    String threadId,
    String filePath, {
    String fileName = 'image.jpg',
  }) async {
    try {
      final formData = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final upload = await _chatApi.uploadFile(threadId, formData);
      final url = upload['url']?.toString() ?? '';
      if (url.isEmpty) {
        return false;
      }
      final fileType = upload['file_type']?.toString() ?? 'image';
      await _chatApi.sendMessageExtended(
        threadId,
        content: '',
        fileAttachment: url,
        fileType: fileType,
      );
      return true;
    } catch (e) {
      LoggingService.error('sendImageMessage failed: $e', tag: 'ChatService');
      return false;
    }
  }

  /// Blocks (or unblocks) [userId] via `/api/chat/block/`.
  Future<bool> setUserBlocked(int userId, {required bool block}) async {
    try {
      await _chatApi.blockUser(userId, block: block);
      return true;
    } catch (e) {
      LoggingService.error('setUserBlocked failed: $e', tag: 'ChatService');
      return false;
    }
  }

  /// Fetches full thread details (booking id, other participant, thread
  /// type) for the room header and menu.
  Future<Map<String, dynamic>?> getThreadDetails(String threadId) async {
    try {
      return await _chatApi.getThreadDetails(threadId);
    } catch (e) {
      LoggingService.error('getThreadDetails failed: $e', tag: 'ChatService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRoom(String threadId) async {
    try {
      return await _chatApi.getThreadDetails(threadId);
    } catch (e) {
      LoggingService.error('getRoom failed: $e', tag: 'ChatService');
      return null;
    }
  }

  Future<void> markRead(String threadId) async {
    try {
      await _chatApi.markRead(threadId);
    } catch (e) {
      LoggingService.error('markRead failed: $e', tag: 'ChatService');
    }
  }

  Future<Map<String, dynamic>?> getOrCreateThreadForBooking(
      String bookingId) async {
    try {
      return await _chatApi.getOrCreateThreadForBooking(bookingId);
    } catch (e) {
      LoggingService.error('getOrCreateThreadForBooking failed: $e',
          tag: 'ChatService');
      return null;
    }
  }

  /// Returns the chat thread map for the authenticated user's direct thread
  /// with the given provider, or null if it could not be resolved.
  ///
  /// Strategy:
  /// 1. Try the spec'd `POST /api/chat/threads/direct/` endpoint.
  /// 2. If the deployed backend does not implement it (404 even for valid
  ///    input), reuse an existing direct thread with the provider from the
  ///    thread list.
  /// 3. Otherwise create an `inquiry` booking for one of the provider's
  ///    listings (requires [listingId]) and open its booking thread — the same
  ///    approach the reference web app uses in ContactProviderPage.vue.
  Future<Map<String, dynamic>?> getOrCreateDirectThread({
    required String providerId,
    String? providerName,
    String? providerPhoto,
    int? listingId,
  }) async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty || providerId.isEmpty) {
      return null;
    }

    final parsedId = int.tryParse(providerId.trim());
    if (parsedId == null) {
      return null;
    }

    try {
      return await _chatApi.getOrCreateDirectThread(parsedId);
    } on ShphApiException catch (e) {
      // The route is missing on the deployed backend (the {id} detail pattern
      // captures "direct"). Only fall back on this specific 404; rethrow
      // anything else (auth, validation, ...) to the caller.
      if (e.statusCode != 404) {
        LoggingService.error('getOrCreateDirectThread failed: $e',
            tag: 'ChatService');
        return null;
      }
      LoggingService.warning(
        'Direct-thread endpoint unavailable (404); using fallbacks',
        tag: 'ChatService',
        error: e,
      );
    } catch (e) {
      LoggingService.error('getOrCreateDirectThread failed: $e',
          tag: 'ChatService');
      return null;
    }

    // Fallback 1: reuse an existing direct thread with this provider.
    final existing = await _findExistingDirectThread(parsedId);
    if (existing != null) {
      return existing;
    }

    // Fallback 2: inquiry booking → booking thread (web-app parity).
    if (listingId == null) {
      LoggingService.warning(
        'No listing id available to create an inquiry-booking thread',
        tag: 'ChatService',
      );
      return null;
    }
    return _createInquiryBookingThread(listingId);
  }

  /// Finds the current user's existing direct thread whose other participant
  /// is [providerId]. Returns null when none matches or the lookup fails.
  Future<Map<String, dynamic>?> _findExistingDirectThread(int providerId) async {
    try {
      final resp = await _chatApi.listDirectThreads();
      final results = resp['results'];
      if (results is! List) {
        return null;
      }
      for (final raw in results.whereType<Map<String, dynamic>>()) {
        final other = raw['other_participant'];
        if (other is Map<String, dynamic> && other['id']?.toString() == providerId.toString()) {
          return raw;
        }
      }
      return null;
    } catch (e) {
      LoggingService.warning(
        'Direct thread lookup failed: $e',
        tag: 'ChatService',
      );
      return null;
    }
  }

  /// Web-app parity fallback (ContactProviderPage.vue): create an `inquiry`
  /// booking on one of the provider's listings, then open its chat thread.
  /// The deployed backend creates a `direct` thread per booking, and
  /// get-or-create semantics keep repeat taps on the same listing idempotent.
  Future<Map<String, dynamic>?> _createInquiryBookingThread(int listingId) async {
    try {
      final now = DateTime.now().toUtc().add(const Duration(days: 1));
      final booking = await ShphBookingsApi.instance.createBooking(
        listingId: listingId,
        scheduledAt: now,
        notes: 'Chat inquiry',
        status: 'inquiry',
      );
      return await _chatApi.getOrCreateThreadForBooking(booking.id);
    } catch (e) {
      LoggingService.error('Inquiry-booking thread fallback failed: $e',
          tag: 'ChatService');
      return null;
    }
  }
}
