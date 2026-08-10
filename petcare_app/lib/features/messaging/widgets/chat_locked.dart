import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

class ChatEndedNotice extends StatefulWidget {
  const ChatEndedNotice({super.key, this.onHelpTap});

  final VoidCallback? onHelpTap;

  @override
  State<ChatEndedNotice> createState() => _ChatEndedNoticeState();
}

class _ChatEndedNoticeState extends State<ChatEndedNotice> {
  late final TapGestureRecognizer _helpTap;

  @override
  void initState() {
    super.initState();
    _helpTap = TapGestureRecognizer()..onTap = () => widget.onHelpTap?.call();
  }

  @override
  void dispose() {
    _helpTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final base = AppTextStyles.captionSm;
    return Center(
      child: AppCard(
        width: 300,
        nen: AppColors.cardMint,
        vien: false,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.itemGap,
        ),
        child: Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            style: base,
            children: [
              TextSpan(text: '${l10n.chatDaKetThuc}\n'),
              TextSpan(text: l10n.vuiLongVao),
              TextSpan(
                text: l10n.trungTamHoTro,
                recognizer: _helpTap,
                style: base.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: l10n.neuCanTroGiupThem),
            ],
          ),
        ),
      ),
    );
  }
}

// Chân màn khi chat đã khoá: nút Đặt lại dịch vụ (thay thanh soạn tin).
class ChatResetFooter extends StatelessWidget {
  const ChatResetFooter({super.key, this.sitterId});

  // Đặt lại với chính người chăm cũ; thiếu id thì không mở được hồ sơ nào
  final String? sitterId;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.neutralLight, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingWide,
            AppSpacing.itemGap,
            AppSpacing.screenPaddingWide,
            AppSpacing.itemGap,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: sitterId == null
                  ? null
                  : () => context.push(AppRoutes.sitterDetailPath(sitterId!)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(context.l10n.datLaiDichVu),
            ),
          ),
        ),
      ),
    );
  }
}
