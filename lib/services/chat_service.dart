import '/api/bridges/api_row_mapper.dart';
import '/api/resources/chat_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _supabase = Supabase.instance.client;
  final _chatApi = ShphChatApi.instance;

  /// Returns a list of chat room maps. Structure depends on backend.
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    if (await ApiRowMapper.canUseApi()) {
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
      } catch (e) {
        LoggingService.error('SHPH API getChatRooms failed, falling back: $e',
            tag: 'ChatService');
      }
    }

    try {
      // Fallback: query Supabase chat_rooms
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final chatRoomsResponse = await _supabase.from('chat_rooms').select();
      final rooms = List<Map<String, dynamic>>.from(chatRoomsResponse);
      return rooms;
    } catch (e) {
      LoggingService.error('Supabase getChatRooms failed: $e',
          tag: 'ChatService');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String threadId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final dynamic resp = await _chatApi.listMessages(threadId);
        final results = resp['results'];
        if (results is List) {
          return List<Map<String, dynamic>>.from(results);
        }
        if (resp is List) {
          return List<Map<String, dynamic>>.from(resp);
        }
      } catch (e) {
        LoggingService.error('SHPH API getMessages failed, falling back: $e',
            tag: 'ChatService');
      }
    }

    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('chat_room_id', threadId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      LoggingService.error('Supabase getMessages failed: $e',
          tag: 'ChatService');
      return [];
    }
  }

  Future<bool> sendMessage(String threadId, String content) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _chatApi.sendMessage(threadId, content);
        return true;
      } catch (e) {
        LoggingService.error('SHPH API sendMessage failed, falling back: $e',
            tag: 'ChatService');
      }
    }

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        return false;
      }

      final room = await _supabase
          .from('chat_rooms')
          .select('client_id')
          .eq('id', threadId)
          .maybeSingle();
      if (room == null) {
        return false;
      }

      final isClient = room['client_id'] == currentUserId;

      final insertedMessage = await _supabase.from('chat_messages').insert({
        'chat_room_id': threadId,
        'sender_id': isClient ? 'client' : 'provider',
        'message_text': content,
      }).select('id').maybeSingle();

      await _supabase.from('chat_rooms').update({
        'updated_at': DateTime.now().toIso8601String(),
        if (insertedMessage?['id'] != null)
          'last_message_id': insertedMessage!['id'],
      }).eq('id', threadId);
      return true;
    } catch (e) {
      LoggingService.error('Supabase sendMessage failed: $e',
          tag: 'ChatService');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getRoom(String threadId) async {
    try {
      final room = await _supabase
          .from('chat_rooms')
          .select()
          .eq('id', threadId)
          .maybeSingle();
      if (room != null) {
        return Map<String, dynamic>.from(room);
      }
    } catch (e) {
      LoggingService.error('Supabase getRoom failed: $e', tag: 'ChatService');
    }
    return null;
  }

  Future<void> markRead(String threadId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _chatApi.markRead(threadId);
        return;
      } catch (e) {
        LoggingService.error('SHPH API markRead failed, falling back: $e',
            tag: 'ChatService');
      }
    }

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        return;
      }

      await _supabase
          .from('chat_messages')
          .update({'is_read': true})
          .eq('chat_room_id', threadId)
          .eq('recipient_id', currentUserId);
    } catch (e) {
      LoggingService.error('Supabase markRead failed: $e', tag: 'ChatService');
    }
  }

  Future<Map<String, dynamic>?> getOrCreateThreadForBooking(
      String bookingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _chatApi.getOrCreateThreadForBooking(bookingId);
      } catch (e) {
        LoggingService.error(
            'SHPH API getOrCreateThread failed, falling back: $e',
            tag: 'ChatService');
      }
    }

    try {
      final response = await _supabase
          .from('chat_rooms')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();
      if (response != null) {
        return Map<String, dynamic>.from(response);
      }

      // Create a new chat room
      final insert = await _supabase
          .from('chat_rooms')
          .insert({
            'booking_id': bookingId,
          })
          .select()
          .maybeSingle();
      if (insert != null) {
        return Map<String, dynamic>.from(insert);
      }
      return null;
    } catch (e) {
      LoggingService.error('Supabase getOrCreateThread failed: $e',
          tag: 'ChatService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getOrCreateDirectThread({
    required String providerId,
    String? providerName,
    String? providerPhoto,
  }) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final thread = await _chatApi.createDirectThread(
          participantId: providerId,
        );
        if (thread != null && thread.isNotEmpty) {
          return thread;
        }
      } catch (e) {
        LoggingService.error(
          'SHPH API createDirectThread failed, falling back: $e',
          tag: 'ChatService',
        );
      }
    }

    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null || providerId.isEmpty) {
      return null;
    }

    try {
      final existing = await _supabase
          .from('chat_rooms')
          .select()
          .eq('client_id', currentUserId)
          .eq('provider_id', providerId)
          .maybeSingle();
      if (existing != null) {
        return Map<String, dynamic>.from(existing);
      }

      final insertPayload = <String, dynamic>{
        'client_id': currentUserId,
        'provider_id': providerId,
        'updated_at': DateTime.now().toIso8601String(),
        if ((providerName ?? '').trim().isNotEmpty)
          'provider_name': providerName!.trim(),
        if ((providerPhoto ?? '').trim().isNotEmpty)
          'provider_photo': providerPhoto!.trim(),
      };

      final created = await _supabase
          .from('chat_rooms')
          .insert(insertPayload)
          .select()
          .maybeSingle();
      if (created != null) {
        return Map<String, dynamic>.from(created);
      }
    } catch (e) {
      LoggingService.error(
        'Supabase getOrCreateDirectThread failed: $e',
        tag: 'ChatService',
      );
    }

    return null;
  }
}
