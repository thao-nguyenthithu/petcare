import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';

// Pill mint cuối luồng khi chat đã khoá (Figma A1.15c-locked): thông báo kết thúc
// + link "trung tâm hỗ trợ" mở trang trợ giúp.
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
    final base = AppTextStyles.captionSm.copyWith(fontSize: 12);
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.itemGap,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardMint,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
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
  const ChatResetFooter({super.key});

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
              onPressed: () => baoDangPhatTrien(context),
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
