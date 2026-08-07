import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

const double _avatar = 60;

typedef BeChon = ({Pet be, bool chon, String? lyDoMo});

// Mục Chọn bé của trang đặt lịch
class BookingPetPicker extends StatelessWidget {
  const BookingPetPicker({
    super.key,
    required this.danhSach,
    required this.onDoiChon,
    required this.onThemBe,
    this.ghiChu,
    this.loi,
  });

  final List<BeChon> danhSach;
  final void Function(Pet be) onDoiChon;
  final VoidCallback onThemBe;
  final String? ghiChu;
  final String? loi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.chonBe, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        if (danhSach.isEmpty)
          _KhoiChuaCoBe(onThemBe: onThemBe)
        else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final m in danhSach)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _OBe(muc: m, onTap: () => onDoiChon(m.be)),
                  ),
                _OThemBe(onTap: onThemBe),
              ],
            ),
          ),
          if (ghiChu != null) ...[
            const SizedBox(height: 14),
            Text(ghiChu!, style: AppTextStyles.captionSm),
          ],
          if (loi != null) ...[
            const SizedBox(height: 10),
            AppNoteBox(text: loi!, kieu: NoteKind.canhBao),
          ],
        ],
      ],
    );
  }
}

class _OBe extends StatelessWidget {
  const _OBe({required this.muc, required this.onTap});

  final BeChon muc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mo = muc.lyDoMo != null;
    final be = muc.be;
    return SizedBox(
      width: _avatar + 8,
      child: Column(
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: mo ? null : onTap,
            child: Opacity(
              opacity: mo ? 0.4 : 1,
              child: SizedBox(
                width: _avatar,
                height: _avatar,
                child: Stack(
                  children: [
                    Container(
                      width: _avatar,
                      height: _avatar,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: muc.chon
                              ? AppColors.primaryColor
                              : AppColors.neutralLight,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: PetAvatar(
                          imageUrl: be.avatar,
                          name: be.name,
                          size: _avatar - 8,
                        ),
                      ),
                    ),
                    if (muc.chon)
                      const Positioned(right: 0, bottom: 0, child: _Tick()),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            be.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: muc.chon
                ? AppTextStyles.label
                : AppTextStyles.captionSm.copyWith(
                    color: mo ? AppColors.neutral : AppColors.textSecondary,
                  ),
          ),
          if (mo) ...[
            const SizedBox(height: 2),
            Text(
              muc.lyDoMo!,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionSm.copyWith(color: AppColors.accent),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: const Icon(Icons.check, size: 11, color: AppColors.textWhite),
    );
  }
}

// Ô thêm hồ sơ bé mới
class _OThemBe extends StatelessWidget {
  const _OThemBe({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _avatar + 8,
      child: Column(
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: CustomPaint(
              painter: const _VienNetDut(),
              child: SizedBox(
                width: _avatar,
                height: _avatar,
                child: const Icon(
                  Icons.add,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.themBe,
            maxLines: 1,
            style: AppTextStyles.captionSm,
          ),
        ],
      ),
    );
  }
}

class _VienNetDut extends CustomPainter {
  const _VienNetDut();

  @override
  void paint(Canvas canvas, Size size) {
    final but = Paint()
      ..color = AppColors.neutral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final tam = size.center(Offset.zero);
    final banKinh = size.width / 2 - 1;
    // Vẽ từng cung ngắn để thành nét đứt
    const soVach = 22;
    const cungMoi = 6.283185307179586 / soVach;
    for (var i = 0; i < soVach; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: tam, radius: banKinh),
        cungMoi * i,
        cungMoi * 0.55,
        false,
        but,
      );
    }
  }

  @override
  bool shouldRepaint(_VienNetDut oldDelegate) => false;
}

class _KhoiChuaCoBe extends StatelessWidget {
  const _KhoiChuaCoBe({required this.onThemBe});

  final VoidCallback onThemBe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      nen: AppColors.background,
      vien: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        children: [
          const Icon(Icons.pets, size: 22, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(
            l10n.chuaCoHoSoThuCungNao,
            textAlign: TextAlign.center,
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.viSaoNccCanHoSoBe,
            textAlign: TextAlign.center,
            style: AppTextStyles.captionSm,
          ),
          const SizedBox(height: 16),
          AppButton(
            text: l10n.themHoSoThuCung,
            outlined: true,
            height: 48,
            onTap: onThemBe,
          ),
        ],
      ),
    );
  }
}
