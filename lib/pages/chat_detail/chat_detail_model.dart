import 'dart:async';

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/chat_detail_service.dart';
import '/services/logging_service.dart';
import 'chat_detail_widget.dart' show ChatDetailWidget;

class ChatDetailModel extends FlutterFlowModel<ChatDetailWidget> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  Map<String, dynamic>? threadDetails;
  bool isLoading = true;
  StreamSubscription? _pollSubscription;

  @override
  void initState(BuildContext context) {}

  Future<void> loadThread(String threadId) async {
    isLoading = true;
    try {
      threadDetails =
          await ChatDetailService.instance.getThreadDetails(threadId);
      messages = await ChatDetailService.instance.getMessages(threadId);
      ChatDetailService.instance.markRead(threadId);
      _startPolling(threadId);
    } catch (e) {
      LoggingService.error('Error loading chat thread: $e',
          tag: 'ChatDetailModel');
    } finally {
      isLoading = false;
    }
  }

  void _startPolling(String threadId) {
    _pollSubscription =
        Stream.periodic(const Duration(seconds: 5)).listen((_) async {
      final newMessages = await ChatDetailService.instance.getMessages(threadId);
      if (newMessages.length != messages.length) {
        messages = newMessages;
      }
    });
  }

  Future<bool> sendMessage(String threadId) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return false;

    final success =
        await ChatDetailService.instance.sendMessage(threadId, text);
    if (success) {
      messageController.clear();
      messages = await ChatDetailService.instance.getMessages(threadId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    return success;
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    _pollSubscription?.cancel();
  }
}
