import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';

// Avatar tròn cho người dùng
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 44,
    this.bordered = false,
    this.onTap,
  });

  final String? name;
  final String? imageUrl;
  final double size;
  final bool bordered;
  final VoidCallback? onTap;

  bool get _laMang => imageUrl != null && imageUrl!.startsWith('http');
  bool get _coAnh => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final o = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardMint,
        shape: BoxShape.circle,
        border: bordered
            ? Border.all(color: AppColors.textWhite, width: 3)
            : null,
      ),
      child: ClipOval(child: _anh(context)),
    );
    if (onTap == null) return o;
    return Stack(
      children: [
        o,
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(customBorder: const CircleBorder(), onTap: onTap),
          ),
        ),
      ],
    );
  }

  Widget _anh(BuildContext context) {
    if (!_coAnh) return _placeholder();
    if (_laMang) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: beRongCache(context, size),
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    return Image.asset(imageUrl!, width: size, height: size, fit: BoxFit.cover);
  }

  Widget _placeholder() {
    final ten = name?.trim() ?? '';
    if (ten.isEmpty) {
      return Center(
        child: Icon(
          Icons.person,
          size: size * 0.5,
          color: AppColors.primaryColor,
        ),
      );
    }
    final chuCai = ten
        .split(RegExp(r'\s+'))
        .last
        .characters
        .first
        .toUpperCase();
    return Center(
      child: Text(
        chuCai,
        style: AppTextStyles.h3.copyWith(
          color: AppColors.primaryColor,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
