import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

const double _thumb = 56;

const double _nutChup = 72;

// Hàng trên cùng: nút đóng, việc đang chụp và số bé
class CameraTopBar extends StatelessWidget {
  const CameraTopBar({super.key, required this.tieuDe, required this.nhanPhai});

  final String tieuDe;
  final String nhanPhai;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(
                context.l10n.dong,
                style: AppTextStyles.label.copyWith(color: AppColors.textWhite),
              ),
            ),
          ),
          Expanded(
            child: Text(
              tieuDe,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: AppColors.textWhite),
            ),
          ),
          Text(
            nhanPhai,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.neutral),
          ),
        ],
      ),
    );
  }
}

// Hàng chip chọn tấm đang chụp, nhãn do màn truyền vào
class CameraChipRow extends StatelessWidget {
  const CameraChipRow({
    super.key,
    required this.nhan,
    required this.dangChon,
    required this.daChup,
    required this.onChon,
    this.khoa = const [],
  });

  final List<String> nhan;
  final int dangChon;
  final List<bool> daChup;
  final List<bool> khoa;
  final ValueChanged<int>? onChon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: leMucPhang),
        itemCount: nhan.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final chon = i == dangChon;
          final xong = daChup[i];
          final biKhoa = i < khoa.length && khoa[i];
          return GestureDetector(
            onTap: onChon == null || biKhoa ? null : () => onChon!(i),
            child: Opacity(
              opacity: biKhoa ? 0.4 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: chon
                      ? AppColors.primaryColor
                      : AppColors.textWhite.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                ),
                child: Row(
                  children: [
                    if (xong && !chon) ...[
                      const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      nhan[i],
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Khung ống kính kèm câu hướng dẫn nổi ở đáy
class CameraViewfinder extends StatelessWidget {
  const CameraViewfinder({
    super.key,
    required this.camera,
    required this.dangMo,
    required this.nhay,
    required this.huongDan,
  });

  final CameraController? camera;
  final bool dangMo;

  // Đang trong nhịp loé sáng khi bấm chụp
  final bool nhay;

  final String huongDan;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (camera case final cam? when cam.value.isInitialized)
          // CameraPreview tự lo tỉ lệ và chiều xoay, chỉ cần đừng ép nó vừa khung
          ColoredBox(
            color: AppColors.textPrimary,
            child: Center(child: CameraPreview(cam)),
          )
        else
          ColoredBox(
            color: AppColors.textPrimary,
            child: Center(
              child: dangMo
                  ? const CircularProgressIndicator(color: AppColors.textWhite)
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        context.l10n.khongMoDuocCamera,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.captionSm.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                    ),
            ),
          ),
        Positioned(
          left: leMucPhang,
          right: leMucPhang,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadius.radius14),
            ),
            child: Text(
              huongDan,
              style: AppTextStyles.captionSm.copyWith(
                color: AppColors.textWhite,
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: nhay ? 1 : 0,
            duration: Duration(milliseconds: nhay ? 40 : 180),
            child: const ColoredBox(color: AppColors.textWhite),
          ),
        ),
      ],
    );
  }
}

class CameraThumbStrip extends StatelessWidget {
  const CameraThumbStrip({
    super.key,
    required this.anh,
    required this.dangChon,
    this.daGuiTruoc = const [],
    this.oCuoiLaKhungTrong = false,
  });

  final List<Uint8List?> anh;
  final List<bool> daGuiTruoc;
  final int dangChon;
  final bool oCuoiLaKhungTrong;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: leMucPhang),
        itemCount: anh.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final bytes = anh[i];
          final khungTrong = oCuoiLaKhungTrong && i == anh.length - 1;
          return Container(
            width: _thumb,
            height: _thumb,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: khungTrong
                    ? AppColors.neutral
                    : i == dangChon
                    ? AppColors.primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: switch (bytes) {
              final b? => Image.memory(b, fit: BoxFit.cover),
              _ when i < daGuiTruoc.length && daGuiTruoc[i] => const Icon(
                Icons.check,
                size: 20,
                color: AppColors.primaryColor,
              ),
              _ => const Icon(
                Icons.photo_camera_outlined,
                size: 18,
                color: AppColors.neutral,
              ),
            },
          );
        },
      ),
    );
  }
}

class CameraControls extends StatelessWidget {
  const CameraControls({
    super.key,
    required this.nhanDem,
    required this.nhanGui,
    required this.chupDuoc,
    required this.dangChup,
    required this.duAnh,
    required this.onChup,
    required this.onGui,
  });

  final String nhanDem;
  final String nhanGui;
  final bool chupDuoc;
  final bool dangChup;

  final bool duAnh;
  final VoidCallback onChup;
  final VoidCallback onGui;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: leMucPhang, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nhanDem,
              style: AppTextStyles.label.copyWith(color: AppColors.textWhite),
            ),
          ),
          GestureDetector(
            onTap: chupDuoc ? onChup : null,
            child: AnimatedScale(
              scale: dangChup ? 0.88 : 1,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: _nutChup,
                height: _nutChup,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: chupDuoc
                      ? AppColors.textWhite
                      : AppColors.textWhite.withValues(alpha: 0.35),
                  border: Border.all(color: AppColors.textWhite, width: 3),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: duAnh ? onGui : null,
              child: Text(
                nhanGui,
                textAlign: TextAlign.right,
                style: AppTextStyles.label.copyWith(
                  color: duAnh
                      ? AppColors.textWhite
                      : AppColors.textWhite.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
