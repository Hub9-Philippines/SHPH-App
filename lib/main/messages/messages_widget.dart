import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/screen_header.dart';
import '/components/search_bar_field.dart';
import '/components/segmented_control.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show CallHistoryDetailsPageWidget, ChatPageWidget;
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
            child: Column(
              children: [
                ScreenHeader(
                  title: _l10n.msTitle,
                  subtitle: _l10n.msSubtitle,
                  action: Icon(
                    Icons.tune_rounded,
                    color: AppTheme.of(context).primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildSearchField(),
                ),
                const SizedBox(height: AppThemeData.spaceLg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedControl<int>(
                    height: 52,
                    value: _model.selectedTabIndex,
                    onChanged: (index) async {
                      _model.selectedTabIndex = index;
                      safeSetState(() {});
                    },
                    segments: [
                      SegmentedOption(
                        value: 0,
                        label: _l10n.msChats,
                        icon: Icons.chat_bubble_outline_rounded,
                      ),
                      SegmentedOption(
                        value: 1,
                        label: _l10n.msCallsHistory,
                        icon: Icons.call_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSectionLabel(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF14B8A6),
                    backgroundColor: AppTheme.of(context).primaryBackground,
                    onRefresh: _model.reload,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: _model.selectedTabIndex == 0
                              ? _buildChatTabSliver()
                              : _buildCallTabSliver(),
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

  Widget _buildSearchField() {
    return SearchBarField(
      controller: _searchController,
      hintText: _l10n.msSearchPlaceholder,
    );
  }

  Widget _buildSectionLabel() {
    final theme = AppTheme.of(context);
    final itemCount = _model.selectedTabIndex == 0
        ? _filteredChatRooms.length
        : _filteredCallHistory.length;
    final title =
        _model.selectedTabIndex == 0 ? _l10n.msRecentConversations : _l10n.msRecentCalls;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: theme.primaryText,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            _l10n.msItems(itemCount),
            style: theme.labelSmall.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: theme.primary,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatTabSliver() {
    if (_model.isLoading) {
      return SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const MessageCardSkeleton(),
      );
    }

    if (_filteredChatRooms.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(
          icon: Icons.mark_chat_unread_rounded,
          title: _searchController.text.isEmpty
              ? _l10n.msNoConversations
              : _l10n.msNoConversationsMatch,
          description: _searchController.text.isEmpty
              ? _l10n.msEmptyChatsBody
              : _l10n.msTryAnotherProvider,
        ),
      );
    }

    return SliverList.separated(
      itemCount: _filteredChatRooms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildChatRoomCard(context, _filteredChatRooms[index]),
    );
  }

  Widget _buildCallTabSliver() {
    if (_model.isLoading) {
      return SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const MessageCardSkeleton(),
      );
    }

    if (_filteredCallHistory.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(
          icon: Icons.call_end_rounded,
          title: _searchController.text.isEmpty
              ? _l10n.msNoCalls
              : _l10n.msNoCallsMatch,
          description: _searchController.text.isEmpty
              ? _l10n.msEmptyCallsBody
              : _l10n.msTryOtherSearch,
        ),
      );
    }

    return SliverList.separated(
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
            padding: const EdgeInsets.all(AppThemeData.spaceXl),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: AppThemeData.spaceLg),
                Text(
                  title,
                  style: theme.titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: theme.primaryText,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppThemeData.spaceSm),
                Text(
                  description,
                  style: theme.bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
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
                                  font: GoogleFonts.plusJakartaSans(
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
                                font: GoogleFonts.plusJakartaSans(),
                                color: theme.textTertiary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chatRoom.lastMessage ?? _l10n.msNoMessages,
                      style: theme.bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(),
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
                            _l10n.msConversation,
                            style: theme.labelSmall.override(
                                  font: GoogleFonts.plusJakartaSans(
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
                              _l10n.msUnreadCount(chatRoom.unreadCount),
                              style: theme.labelSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: theme.onPrimary,
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
                          font: GoogleFonts.plusJakartaSans(
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
                              font: GoogleFonts.plusJakartaSans(
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
                              font: GoogleFonts.plusJakartaSans(),
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
                    font: GoogleFonts.plusJakartaSans(),
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
      return _l10n.msJustNow;
    }
    if (difference.inHours < 1) {
      return _l10n.msMinutesAgo(difference.inMinutes);
    }
    if (difference.inDays < 1) {
      return _l10n.msHoursAgo(difference.inHours);
    }
    if (difference.inDays < 7) {
      return _l10n.msDaysAgo(difference.inDays);
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
