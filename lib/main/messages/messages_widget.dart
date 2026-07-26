import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/content_container.dart';
import '/components/screen_header.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show CallHistoryDetailsPageWidget, ChatPageWidget, MyNotificationsWidget;
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, MessagesModel.new);
    _model.onStateChanged = () {
      if (mounted) {
        safeSetState(() {});
      }
    };
    _searchController.addListener(() {
      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  List<ChatRoom> get _filteredChatRooms {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _model.chatRooms;
    }

    return _model.chatRooms
        .where(
          (room) =>
              room.providerName.toLowerCase().contains(query) ||
              (room.lastMessage ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  List<CallHistory> get _filteredCallHistory {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _model.callHistory;
    }

    return _model.callHistory
        .where(
          (call) =>
              call.providerName.toLowerCase().contains(query) ||
              call.callStatus.toLowerCase().contains(query) ||
              call.callType.toLowerCase().contains(query),
        )
        .toList();
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
          body: SafeArea(
            top: true,
            child: RefreshIndicator(
              color: AppTheme.of(context).primary,
              onRefresh: _model.reload,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScreenHeader(
                          title: 'Messages',
                          subtitle: 'Stay close to providers, updates, and support.',
                          action: Icon(
                            Icons.tune_rounded,
                            color: Color(0xFF368EFF),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: _buildSearchField(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: double.infinity,
                            height: 68,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).primaryBackground,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppThemeData.shadowCard,
                            ),
                            child:
                                custom_widgets.CupertinoSlidingWidgetMessages(
                              width: double.infinity,
                              height: double.infinity,
                              initialIndex: _model.selectedTabIndex,
                              onChanged: (index) async {
                                _model.selectedTabIndex = index;
                                safeSetState(() {});
                                await _model.pageViewController?.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildSectionLabel(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: PageView(
                        controller: _model.pageViewController ??=
                            PageController(
                          initialPage: max(
                            0,
                            min(
                              valueOrDefault<int>(_model.selectedTabIndex, 0),
                              1,
                            ),
                          ),
                        ),
                        onPageChanged: (_) async {
                          _model.selectedTabIndex = _model.pageViewCurrentIndex;
                          safeSetState(() {});
                        },
                        children: [
                          _buildChatTab(),
                          _buildCallTab(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildSearchField() {
    final theme = AppTheme.of(context);
    return Container(
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppThemeData.shadowSoft,
        ),
        child: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search conversations or calls',
            hintStyle: theme.bodyMedium.override(
                  font: GoogleFonts.poppins(),
                  color: theme.textTertiary,
                ),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: _searchController.clear,
                    icon: const Icon(Icons.close_rounded),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: theme.primary.withValues(alpha: 0.22),
                width: 1.4,
              ),
            ),
            filled: true,
            fillColor: theme.primaryBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
        ),
      );
  }

  Widget _buildSectionLabel() {
    final theme = AppTheme.of(context);
    final itemCount = _model.selectedTabIndex == 0
        ? _filteredChatRooms.length
        : _filteredCallHistory.length;
    final title =
        _model.selectedTabIndex == 0 ? 'Recent conversations' : 'Recent calls';

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  color: theme.primaryText,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: theme.primaryLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$itemCount items',
            style: theme.labelSmall.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  color: theme.primaryBrandText,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatTab() {
    if (_model.isLoading) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const MessageCardSkeleton(),
      );
    }

    if (_filteredChatRooms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mark_chat_unread_rounded,
        title: _searchController.text.isEmpty
            ? 'No conversations yet'
            : 'No conversations matched',
        description: _searchController.text.isEmpty
            ? 'Messages from your providers will show up here once a booking starts.'
            : 'Try another provider name or keyword.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _filteredChatRooms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildChatRoomCard(context, _filteredChatRooms[index]),
    );
  }

  Widget _buildCallTab() {
    if (_model.isLoading) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const MessageCardSkeleton(),
      );
    }

    if (_filteredCallHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.call_outlined,
        title: _searchController.text.isEmpty
            ? 'No call activity yet'
            : 'No calls matched',
        description: _searchController.text.isEmpty
            ? 'Your completed and missed calls will appear here when that history is available.'
            : 'Try a different search term.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _filteredCallHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildCallHistoryCard(context, _filteredCallHistory[index]),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = AppTheme.of(context);
    return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: theme.primaryLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: theme.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.titleMedium.override(
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                        color: theme.primaryText,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.bodyMedium.override(
                        font: GoogleFonts.poppins(),
                        color: theme.secondaryText,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildChatRoomCard(BuildContext context, ChatRoom chatRoom) {
    final theme = AppTheme.of(context);
    return GestureDetector(
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              _buildAvatar(imageUrl: chatRoom.providerPhoto),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chatRoom.providerName,
                            style: theme.bodyLarge.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: theme.primaryText,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(chatRoom.lastMessageTime),
                          style: theme.bodySmall.override(
                                font: GoogleFonts.poppins(),
                                color: theme.textTertiary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chatRoom.lastMessage ?? 'No messages yet',
                      style: theme.bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            color: theme.secondaryText,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.surfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Conversation',
                            style: theme.labelSmall.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: AppThemeData.statusCompleted,
                                ),
                          ),
                        ),
                        const Spacer(),
                        if (chatRoom.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${chatRoom.unreadCount} unread',
                              style: theme.labelSmall.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildCallHistoryCard(BuildContext context, CallHistory call) {
    final theme = AppTheme.of(context);
    final statusColor = switch (call.callStatus) {
      'missed' => AppThemeData.statusCancelled,
      'incoming' => AppThemeData.statusActive,
      'outgoing' => AppThemeData.statusConfirmed,
      _ => AppThemeData.statusCompleted,
    };

    final callIcon = switch (call.callType) {
      'video' => Icons.videocam_rounded,
      'voice' => Icons.call_rounded,
      _ => Icons.call_rounded,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            _buildAvatar(imageUrl: call.providerPhoto),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.providerName,
                    style: theme.bodyLarge.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                          color: theme.primaryText,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        call.callStatus == 'missed'
                            ? Icons.call_missed_rounded
                            : call.callStatus == 'incoming'
                                ? Icons.call_received_rounded
                                : Icons.call_made_rounded,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        call.callStatus.toUpperCase(),
                        style: theme.labelSmall.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                              color: statusColor,
                            ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        callIcon,
                        size: 16,
                        color: theme.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        call.callType.toUpperCase(),
                        style: theme.bodySmall.override(
                              font: GoogleFonts.poppins(),
                              color: theme.secondaryText,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(call.createdAt),
              style: theme.bodySmall.override(
                    font: GoogleFonts.poppins(),
                    color: theme.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar({required String imageUrl}) => Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl.trim().isEmpty
            ? Icon(
                Icons.person_rounded,
                color: AppTheme.of(context).primary,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  color: AppTheme.of(context).primary,
                ),
              ),
      );

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
