import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 44,
    this.ring = false,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final bool ring; // viền trắng

  bool get _laMang => imageUrl != null && imageUrl!.startsWith('http');
  bool get _coAnh => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardMint,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: AppColors.surface, width: 2) : null,
      ),
      child: ClipOval(child: _anh()),
    );
  }

  Widget _anh() {
    if (!_coAnh) return _placeholder();
    if (_laMang) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    return Image.asset(imageUrl!, width: size, height: size, fit: BoxFit.cover);
  }

  Widget _placeholder() {
    final ten = name?.trim() ?? '';
    if (ten.isNotEmpty) {
      final chu = ten.split(RegExp(r'\s+')).last.characters.first.toUpperCase();
      return Center(
        child: Text(
          chu,
          style: AppTextStyles.h3.copyWith(
            fontSize: size * 0.4,
            color: AppColors.primaryColor,
          ),
        ),
      );
    }
    return Center(
      child: Icon(Icons.pets, size: size * 0.5, color: AppColors.primaryColor),
    );
  }
}
