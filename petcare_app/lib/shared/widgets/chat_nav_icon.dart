import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Icon tab Tin nhắn kèm badge số chưa đọc
class ChatNavIcon extends StatelessWidget {
  const ChatNavIcon({super.key, required this.unread, this.selected = false});

  final int unread;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      'assets/icons/icon_chat.svg',
      width: 24,
      colorFilter: selected
          ? null
          : const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
    );
    if (unread <= 0) return icon;
    return Badge(
      backgroundColor: AppColors.accent,
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: icon,
    );
  }
}
