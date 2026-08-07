import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/conversation.dart';
import 'package:petcare_app/features/messaging/screens/chat_detail_screen.dart';
import 'package:petcare_app/features/messaging/widgets/conversation_filter_panel.dart';
import 'package:petcare_app/features/messaging/widgets/conversation_tile.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_search_field.dart';
import 'package:petcare_app/shared/widgets/green_title_header.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Nội dung tab Tin nhắn
class MessagesTab extends StatefulWidget {
  const MessagesTab({
    super.key,
    required this.conversations,
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.emptyTitle,
    required this.emptyMessage,
    this.lightHeader = false,
    this.onOpen,
    this.onRefresh,
    this.dangTai = false,
  });

  final List<Conversation> conversations;
  final String title;
  final String subtitle;
  final String searchHint;
  final String emptyTitle; // rỗng khi chưa có hội thoại nào
  final String emptyMessage;
  final bool lightHeader;
  final ValueChanged<Conversation>? onOpen; // đánh dấu đã đọc khi mở
  final Future<void> Function()? onRefresh;

  // Lượt tải đầu đừng nhá "chưa có tin nhắn nào" rồi đổi thành danh sách
  final bool dangTai;

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  final _searchController = TextEditingController();
  String _keyword = '';
  bool _filterOpen = false;
  ConversationState? _sessionFilter; // null = tất cả trạng thái
  final Set<ServiceType> _serviceTypes = {}; // rỗng = tất cả loại dịch vụ

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilter => _sessionFilter != null || _serviceTypes.isNotEmpty;

  List<Conversation> get _filtered {
    return widget.conversations.where((c) {
      if (_keyword.isNotEmpty && !c.matches(_keyword)) return false;
      if (_sessionFilter != null && c.state != _sessionFilter) return false;
      if (_serviceTypes.isNotEmpty && !_serviceTypes.contains(c.serviceType)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _openChat(Conversation conversation) {
    widget.onOpen?.call(conversation);
    context.push(
      AppRoutes.chatThread,
      extra: ChatArgs(conversation: conversation, isOwner: widget.lightHeader),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final coDieuKien = _keyword.isNotEmpty || _hasFilter;
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(context),
          // Panel lọc bung/thu
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _filterOpen
                ? ConversationFilterPanel(
                    sessionFilter: _sessionFilter,
                    serviceTypes: _serviceTypes,
                    onSessionChanged: (v) => setState(() => _sessionFilter = v),
                    onToggleServiceType: _toggleServiceType,
                  )
                : const SizedBox(width: double.infinity),
          ),
          if (widget.lightHeader) const AppDongKe(),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: widget.onRefresh,
              child: widget.dangTai
                  ? const AppSkeletonList(soThe: 6, caoThe: 68)
                  : list.isEmpty
                  ? _DanhSachRong(
                      icon: coDieuKien
                          ? Icons.search_off_rounded
                          : Icons.forum_outlined,
                      title: coDieuKien
                          ? context.l10n.khongTimThayTinNhan
                          : widget.emptyTitle,
                      message: coDieuKien
                          ? context.l10n.thuTuKhoaKhac
                          : widget.emptyMessage,
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        AppSpacing.screenEdgeGap,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const AppDongKe(),
                      itemBuilder: (context, i) => ConversationTile(
                        conversation: list[i],
                        onTap: () => _openChat(list[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Header
  Widget _buildHeader(BuildContext context) {
    void toggle() => setState(() => _filterOpen = !_filterOpen);
    // Chủ nuôi
    if (widget.lightHeader) {
      return _LightHeader(
        title: widget.title,
        subtitle: widget.subtitle,
        child: AppSearchField(
          controller: _searchController,
          onChanged: (v) => setState(() => _keyword = v),
          hintText: widget.searchHint,
          filterOpen: _filterOpen,
          onToggleFilter: toggle,
        ),
      );
    }
    // Người chăm
    return GreenTitleHeader(
      title: widget.title,
      subtitle: widget.subtitle,
      bottom: Row(
        children: [
          Expanded(
            child: AppSearchField(
              controller: _searchController,
              onChanged: (v) => setState(() => _keyword = v),
              hintText: widget.searchHint,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(width: AppSpacing.textGap),
          IconButton(
            onPressed: toggle,
            icon: const Icon(Icons.tune_rounded),
            color: _filterOpen ? AppColors.textSecondary : AppColors.textWhite,
            tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          ),
        ],
      ),
    );
  }

  void _toggleServiceType(ServiceType type) {
    setState(() {
      if (!_serviceTypes.remove(type)) _serviceTypes.add(type);
    });
  }
}

// Header nền sáng cho tab chủ nuôi
class _LightHeader extends StatelessWidget {
  const _LightHeader({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingWide,
            AppSpacing.labelGap,
            AppSpacing.screenPaddingWide,
            AppSpacing.itemGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.textGap),
              Text(subtitle, style: AppTextStyles.captionSm),
              const SizedBox(height: AppSpacing.itemGap),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _DanhSachRong extends StatelessWidget {
  const _DanhSachRong({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        AppEmptyState(
          icon: icon,
          title: title,
          message: message,
          circleColor: AppColors.cardMint,
        ),
      ],
    );
  }
}
