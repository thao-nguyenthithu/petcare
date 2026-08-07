import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Ảnh đại diện
class SitterAvatarPicker extends StatelessWidget {
  const SitterAvatarPicker({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.dangUp,
    required this.onDoi,
  });

  final String name;
  final String? avatarUrl;
  final bool dangUp;
  final VoidCallback onDoi;

  // Đường kính avatar của riêng màn sửa hồ sơ
  static const double _canh = 88;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              UserAvatar(
                name: name,
                imageUrl: avatarUrl,
                size: _canh,
                bordered: true,
                onTap: dangUp ? null : onDoi,
              ),
              if (dangUp)
                Container(
                  width: _canh,
                  height: _canh,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.itemGap),
          TextButton.icon(
            onPressed: dangUp ? null : onDoi,
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: Text(context.l10n.doiAnhDaiDien),
          ),
        ],
      ),
    );
  }
}
