import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

const double _vien = 2;

// Ô sau đè lên ô trước, chỉ chừa lại phần này của bề rộng ô
const double _chong = 0.52;

// Dải avatar các thú cưng của một đơn
class PetAvatarStack extends StatelessWidget {
  const PetAvatarStack({
    super.key,
    required this.pets,
    this.size = 38,
    this.toiDa = 2,
    this.ring = false,
  });

  final List<PetBrief> pets;
  final double size;
  final int toiDa;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) return SizedBox(width: size, height: size);

    final hien = pets.take(toiDa).toList();
    final con = pets.length - hien.length;
    final soO = hien.length + (con > 0 ? 1 : 0);
    if (soO == 1) {
      return PetAvatar(
        imageUrl: hien.first.avatar,
        name: hien.first.name,
        size: size,
        ring: ring,
      );
    }

    final duongKinhO = size + _vien * 2;
    final buocChong = duongKinhO * _chong;

    return SizedBox(
      width: duongKinhO + buocChong * (soO - 1) - _vien,
      height: size + _vien,
      child: Stack(
        children: [
          for (var i = 0; i < hien.length; i++)
            Positioned(
              left: buocChong * i - _vien,
              top: -_vien,
              child: _OVien(
                child: PetAvatar(
                  imageUrl: hien[i].avatar,
                  name: hien[i].name,
                  size: size,
                ),
              ),
            ),
          if (con > 0)
            Positioned(
              left: buocChong * hien.length - _vien,
              top: -_vien,
              child: _OVien(
                child: _OThem(con: con, size: size),
              ),
            ),
        ],
      ),
    );
  }
}

// Viền trắng bao ngoài
class _OVien extends StatelessWidget {
  const _OVien({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_vien),
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

class _OThem extends StatelessWidget {
  const _OThem({required this.con, required this.size});

  final int con;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.cardMint,
        shape: BoxShape.circle,
      ),
      child: Text(
        '+$con',
        style: AppTextStyles.label.copyWith(
          fontSize: size * 0.32,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
