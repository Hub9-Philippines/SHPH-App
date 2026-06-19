import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show CallHistoryDetailsPageWidget, ChatPageWidget;
import '/theme/app_theme.dart';
import 'messages_model.dart';

export 'messages_model.dart';

class MessagesWidget extends StatefulWidget {
  const MessagesWidget({super.key});

  static String routeName = 'Messages';
  static String routePath = '/messages';

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  late MessagesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, MessagesModel.new);
    _model.onStateChanged = () {
      if (mounted) {
        safeSetState(() {});
      }
    };
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).secondaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Messages',
                style: AppTheme.of(context).titleLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                      ),
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                    ),
              ),
              centerTitle: true,
              expandedTitleScale: 1,
              titlePadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    decoration: const BoxDecoration(),
                    child: custom_widgets.CupertinoSlidingWidgetMessages(
                      width: double.infinity,
                      height: double.infinity,
                      initialIndex: _model.selectedTabIndex,
                      onChanged: (index) async {
                        _model.selectedTabIndex = index;
                        safeSetState(() {});
                        await _model.pageViewController?.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: PageView(
                      controller: _model.pageViewController ??= PageController(
                          initialPage: max(
                              0,
                              min(
                                  valueOrDefault<int>(
                                      _model.selectedTabIndex, 0),
                                  1))),
                      onPageChanged: (_) async {
                        safeSetState(() {});
                        _model.selectedTabIndex = _model.pageViewCurrentIndex;
                        safeSetState(() {});
                      },
                      scrollDirection: Axis.horizontal,
                      children: [
                        // --- PAGE 1: CHATS ---
                        if (_model.isLoading)
                          ListView.separated(
                            padding: EdgeInsets.only(
                              top: 10,
                              left: 15,
                              right: 15,
                              bottom: MediaQuery.sizeOf(context).width * 0.1,
                            ),
                            itemCount: 3,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) =>
                                const MessageCardSkeleton(),
                          )
                        else
                          ListView.separated(
                            padding: EdgeInsets.only(
                              top: 10,
                              left: 15,
                              right: 15,
                              bottom: MediaQuery.sizeOf(context).width * 0.1,
                            ),
                            itemCount: _model.chatRooms.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) => _buildChatRoomCard(
                                context, _model.chatRooms[index]),
                          ),
                        // --- PAGE 2: CALLS HISTORY ---
                        if (_model.isLoading)
                          ListView.separated(
                            padding: EdgeInsets.only(
                              top: 10,
                              left: 15,
                              right: 15,
                              bottom: MediaQuery.sizeOf(context).width * 0.1,
                            ),
                            itemCount: 3,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) =>
                                const MessageCardSkeleton(),
                          )
                        else
                          ListView.separated(
                            padding: EdgeInsets.only(
                              top: 10,
                              left: 15,
                              right: 15,
                              bottom: MediaQuery.sizeOf(context).width * 0.1,
                            ),
                            itemCount: _model.callHistory.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _model.callHistory[index];
                              return _buildCallHistoryCard(context, item);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildChatRoomCard(BuildContext context, ChatRoom chatRoom) =>
      GestureDetector(
        onTap: () => context.pushNamed(
          ChatPageWidget.routeName,
          pathParameters: {'roomId': chatRoom.id},
          extra: <String, dynamic>{
            'providerName': chatRoom.providerName,
            'providerPhoto': chatRoom.providerPhoto,
          },
        ),
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 0,
                color: Color(0x1A000000),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.network(chatRoom.providerPhoto).image,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatRoom.providerName,
                          style: AppTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                        ),
                        Text(
                          chatRoom.lastMessage ?? 'No messages yet',
                          style: AppTheme.of(context).bodyMedium.override(
                                color: AppTheme.of(context).secondaryText,
                                fontSize: 14,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ].divide(const SizedBox(height: 5)),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(chatRoom.lastMessageTime),
                      style: AppTheme.of(context).bodyMedium.override(
                            color: const Color(0xFF767676),
                          ),
                    ),
                    if (chatRoom.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          chatRoom.unreadCount.toString(),
                          style: AppTheme.of(context).bodySmall.override(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildCallHistoryCard(BuildContext context, CallHistory call) {
    final statusColor = switch (call.callStatus) {
      'missed' => Colors.red,
      'incoming' => Colors.green,
      'outgoing' => Colors.blue,
      _ => Colors.grey,
    };

    final callIcon = switch (call.callType) {
      'video' => Icons.videocam,
      'voice' => Icons.phone,
      _ => Icons.phone,
    };

    return GestureDetector(
      onTap: () => context.pushNamed(
        CallHistoryDetailsPageWidget.routeName,
        pathParameters: {'callId': call.id},
        extra: <String, dynamic>{
          'providerName': call.providerName,
          'providerPhoto': call.providerPhoto,
          'callType': call.callType,
          'callStatus': call.callStatus,
          'durationSeconds': call.durationSeconds,
          'createdAt': call.createdAt,
        },
      ),
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 0,
              color: Color(0x1A000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.network(call.providerPhoto).image,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        call.providerName,
                        style: AppTheme.of(context).bodyLarge.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500),
                            ),
                      ),
                      Row(
                        children: [
                          Icon(
                            call.callStatus == 'missed'
                                ? Icons.call_missed
                                : call.callStatus == 'incoming'
                                    ? Icons.call_received
                                    : Icons.call_made,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            call.callStatus.toUpperCase(),
                            style: AppTheme.of(context).bodySmall.override(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            callIcon,
                            size: 16,
                            color: AppTheme.of(context).secondaryText,
                          ),
                        ],
                      ),
                    ].divide(const SizedBox(height: 5)),
                  ),
                ),
              ),
              Text(
                _formatTime(call.createdAt),
                style: AppTheme.of(context).bodyMedium.override(
                      color: const Color(0xFF767676),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
