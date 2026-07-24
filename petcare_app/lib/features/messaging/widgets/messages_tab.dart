import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/messaging/data/conversation.dart';
import 'package:petcare_app/features/messaging/widgets/conversation_tile.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_search_field.dart';
import 'package:petcare_app/shared/widgets/green_title_header.dart';

// Thân tab Tin nhắn
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
  });

  final List<Conversation> conversations;
  final String title;
  final String subtitle;
  final String searchHint;
  final String emptyTitle; // rỗng khi chưa có hội thoại nào
  final String emptyMessage;
  final bool lightHeader;

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  final _searchController = TextEditingController();
  String _keyword = '';
  bool _filterOpen = false;
  ConversationState? _sessionFilter; // null = tất cả trạng thái
  final Set<ServiceKind> _serviceTypes = {}; // rỗng = tất cả loại dịch vụ

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
                ? _buildFilterPanel(context)
                : const SizedBox(width: double.infinity),
          ),
          if (widget.lightHeader)
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutralLight,
            ),
          Expanded(
            child: AppRefreshIndicator(
              child: list.isEmpty
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
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.neutralLight,
                      ),
                      itemBuilder: (context, i) => ConversationTile(
                        conversation: list[i],
                        onTap: () => baoDangPhatTrien(context),
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

  // Panel lọc mở dưới header
  Widget _buildFilterPanel(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterGroupLabel(l10n.trangThai),
          Wrap(
            spacing: AppSpacing.labelGap,
            runSpacing: AppSpacing.labelGap,
            children: [
              AppFilterChip(
                label: l10n.tatCa,
                selected: _sessionFilter == null,
                onTap: () => setState(() => _sessionFilter = null),
              ),
              AppFilterChip(
                label: l10n.sapToi,
                selected: _sessionFilter == ConversationState.sapToi,
                onTap: () =>
                    setState(() => _sessionFilter = ConversationState.sapToi),
              ),
              AppFilterChip(
                label: l10n.dangDienRa,
                selected: _sessionFilter == ConversationState.dangDienRa,
                onTap: () => setState(
                  () => _sessionFilter = ConversationState.dangDienRa,
                ),
              ),
              AppFilterChip(
                label: l10n.daHoanTat,
                selected: _sessionFilter == ConversationState.daHoanTat,
                onTap: () => setState(
                  () => _sessionFilter = ConversationState.daHoanTat,
                ),
              ),
              AppFilterChip(
                label: l10n.daKetThuc,
                selected: _sessionFilter == ConversationState.daKetThuc,
                onTap: () => setState(
                  () => _sessionFilter = ConversationState.daKetThuc,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.itemGap),
          _FilterGroupLabel(l10n.loaiDichVu),
          Wrap(
            spacing: AppSpacing.blockGap,
            runSpacing: AppSpacing.textGap,
            children: [
              _ServiceCheckbox(
                label: l10n.datDiDao,
                selected: _serviceTypes.contains(ServiceKind.datDiDao),
                onTap: () => _toggleServiceType(ServiceKind.datDiDao),
              ),
              _ServiceCheckbox(
                label: l10n.trongGiu,
                selected: _serviceTypes.contains(ServiceKind.trongGiu),
                onTap: () => _toggleServiceType(ServiceKind.trongGiu),
              ),
              _ServiceCheckbox(
                label: l10n.tamVaTia,
                selected: _serviceTypes.contains(ServiceKind.tamTia),
                onTap: () => _toggleServiceType(ServiceKind.tamTia),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleServiceType(ServiceKind type) {
    setState(() {
      if (!_serviceTypes.remove(type)) _serviceTypes.add(type);
    });
  }
}

// Nhãn nhóm trong panel lọc
class _FilterGroupLabel extends StatelessWidget {
  const _FilterGroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.labelGap),
      child: Text(
        text,
        style: AppTextStyles.captionSm.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// Ô checkbox
class _ServiceCheckbox extends StatelessWidget {
  const _ServiceCheckbox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primaryColor,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: AppColors.neutralLight, width: 1.5),
            ),
          ),
          const SizedBox(width: AppSpacing.textGap),
          Text(
            label,
            style: AppTextStyles.captionSm.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
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
              Text(
                subtitle,
                style: AppTextStyles.captionSm.copyWith(fontSize: 13),
              ),
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
