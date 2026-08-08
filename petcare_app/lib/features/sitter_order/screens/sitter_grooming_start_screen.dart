import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_absence.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/widgets/check_in_location_box.dart';
import 'package:petcare_app/features/sitter_order/widgets/sitter_grooming_blocks.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn bắt đầu buổi tắm và cắt tỉa, không có nhánh rọ mõm và dây xích
class SitterGroomingStartScreen extends StatelessWidget {
  const SitterGroomingStartScreen({super.key, required this.don});

  final SitterOrderDetail don;

  bool get _duGan => (don.metCachDiemDon ?? 0) <= metGeofence;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goiTungBe = don.grooming?.goiTungBe ?? const <GoiGroomingCuaBe>[];
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 12),
            child: Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chupAnhCheckInTruocKhiBatDau,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maDonDichVuSoBe(
                          don.maDon,
                          don.tenDichVu.split(' · ').first,
                          '${don.pets.length}',
                        ),
                        style: AppTextStyles.captionSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 24),
        children: [
          FlatSection(
            child: CheckInLocationBox(
              met: don.metCachDiemDon ?? 0,
              gio: don.gioToiNoi ?? '',
              duGan: _duGan,
              tieuDeGan: l10n.banDangONhaChuNuoi,
              tieuDeXa: l10n.banDangOXaNhaChuNuoi,
            ),
          ),
          const SizedBox(height: 14),
          FlatSection(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.canhBaoXaQuaBanKinhGrooming('$metGeofence'),
                    style: AppTextStyles.captionSm,
                  ),
                ),
              ],
            ),
          ),
          const FlatDivider(),
          FlatSection(child: SitterGroomingPackages(goiTungBe: goiTungBe)),
          const SizedBox(height: 20),
          FlatSection(
            child: _HangMucSeLam(
              goiTungBe: goiTungBe,
              gioDuKienXong: don.grooming?.gioDuKienXong ?? '',
            ),
          ),
        ],
      ),
      bottomBar: _ThanhNut(don: don, duGan: _duGan),
    );
  }
}

// Bản kê hạng mục sẽ làm kèm mốc dự kiến xong
class _HangMucSeLam extends StatelessWidget {
  const _HangMucSeLam({required this.goiTungBe, required this.gioDuKienXong});

  final List<GoiGroomingCuaBe> goiTungBe;
  final String gioDuKienXong;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.hangMucSeLam, style: AppTextStyles.h3)),
            const SizedBox(width: 10),
            Text(
              l10n.duKienXongKhoang(gioDuKienXong),
              style: AppTextStyles.label.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GroomingTasksToDo(goiTungBe: goiTungBe, coAvatar: false),
      ],
    );
  }
}

// Nút chính mở thẳng camera; nút phụ là lối cáo buộc nên chỉ sống sau ân hạn
class _ThanhNut extends StatelessWidget {
  const _ThanhNut({required this.don, required this.duGan});

  final SitterOrderDetail don;
  final bool duGan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: l10n.chupAnhCacBeTruocKhiLam,
                height: 50,
                enabled: duGan,
                onTap: () => context.push(
                  AppRoutes.sitterGroomingPhotosPath(don.bookingId),
                ),
              ),
              const SizedBox(height: 8),
              AppButton(
                text: don.gioMoBaoVangMat == null
                    ? l10n.chuNuoiKhongCoMat
                    : l10n.chuNuoiKhongCoMatMoLuc(don.gioMoBaoVangMat!),
                flat: true,
                height: 50,
                color: AppColors.textSecondary,
                enabled: don.gioMoBaoVangMat == null,
                onTap: () => context.push(
                  AppRoutes.sitterAbsencePath(
                    don.bookingId,
                    LoaiBaoVangMat.toiBao.ma,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
