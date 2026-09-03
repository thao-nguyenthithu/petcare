import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/dispute_reasons.dart';
import 'package:petcare_app/features/booking/data/owner_dispute.dart';
import 'package:petcare_app/features/booking/providers/owner_dispute_provider.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/dispute_booking_facts.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';

// Hồ sơ khiếu nại chủ nuôi mở, chỉ đọc: rút khiếu nại đã bỏ khỏi hệ
class OwnerDisputeDetailScreen extends ConsumerWidget {
  const OwnerDisputeDetailScreen({super.key, required this.ma});

  final String ma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = hoSoKhieuNaiChuNuoiProvider(ma);
    return AppScreen(
      header: AppScreenHeader(title: l10n.hoSoKhieuNai, subtitle: ma),
      body: switch (ref.watch(provider)) {
        AsyncData(:final value) => _Than(hoSo: value),
        AsyncError() => AppNetworkError(
          onRetry: () => ref.invalidate(provider),
        ),
        _ => const AppSkeletonList(soThe: 4, caoThe: 88),
      },
    );
  }
}

class _Than extends StatelessWidget {
  const _Than({required this.hoSo});

  final HoSoKhieuNaiChuNuoi hoSo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        AppSpacing.screenEdgeGap,
      ),
      children: [
        _Banner(hoSo: hoSo),
        const SizedBox(height: AppSpacing.stackGap),
        DisputeBookingFacts(
          tenDichVu: hoSo.tenDichVu,
          maDon: hoSo.maDon,
          tenBe: hoSo.tenBe,
          nhanDoiPhuong: l10n.nguoiCham,
          tenDoiPhuong: hoSo.tenNcc,
          thoiGian: _moc(hoSo.batDau) ?? '',
        ),
        const SizedBox(height: AppSpacing.groupGap),
        if (hoSo.maLyDo case final ma?) ...[
          ViNoteBlock(
            nhan: l10n.loaiSuCo,
            noiDung: nhanSuCoChuNuoi(context, ma),
            nhanNhat: true,
          ),
          const SizedBox(height: AppSpacing.stackGap),
        ],
        ViNoteBlock(
          nhan: hoSo.banMo ? l10n.phanAnhCuaBan : l10n.nguoiChamPhanAnh,
          noiDung: hoSo.phanAnh,
          moc: _moc(hoSo.luc),
        ),
        if (hoSo.anhPhanAnh.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.stackGap),
          ViPhotoRow(anh: hoSo.anhPhanAnh),
        ],
        if (hoSo.phanHoiNcc case final phanHoi?) ...[
          const SizedBox(height: AppSpacing.groupGap),
          ViNoteBlock(
            nhan: l10n.phanHoiCuaNguoiCham,
            noiDung: phanHoi,
            moc: _moc(hoSo.lucPhanHoi),
          ),
          if (hoSo.anhPhanHoi.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.stackGap),
            ViPhotoRow(anh: hoSo.anhPhanHoi),
          ],
        ],
        if (hoSo.ketLuan case final ketLuan?) ...[
          const SizedBox(height: AppSpacing.groupGap),
          _KhoiKetLuan(ketLuan: ketLuan, tienHoan: hoSo.tienHoan),
        ],
        const SizedBox(height: AppSpacing.groupGap),
        Text(switch (hoSo.tinhTrang) {
          TinhTrangHoSo.khongChapNhan => l10n.maKhieuNaiDaDong(hoSo.ma),
          TinhTrangHoSo.daHoanMotPhan => l10n.maKhieuNaiDaApDung(hoSo.ma),
          _ => l10n.maKhieuNaiLuuCanCu(hoSo.ma),
        }, style: AppTextStyles.captionSm),
      ],
    );
  }
}

// Đỏ khi hồ sơ còn treo, xanh khi đã có kết luận
class _Banner extends StatelessWidget {
  const _Banner({required this.hoSo});

  final HoSoKhieuNaiChuNuoi hoSo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final luc = _moc(hoSo.ketLuan?.luc) ?? '';
    return switch (hoSo.tinhTrang) {
      TinhTrangHoSo.choNguoiChamPhanHoi => ViStatusBanner(
        icon: Icons.hourglass_empty_rounded,
        tieuDe: l10n.daGuiChoNccPhanHoi,
        moTa: l10n.moTaChoNccPhanHoi,
        mau: AppColors.accent,
      ),
      TinhTrangHoSo.choHoTroXuLy => ViStatusBanner(
        icon: Icons.support_agent_rounded,
        tieuDe: l10n.hoTroDangXemXet,
        moTa: l10n.moTaHoTroDangXemXet,
        mau: AppColors.accent,
      ),
      TinhTrangHoSo.daHoanMotPhan => ViStatusBanner(
        icon: Icons.check_rounded,
        tieuDe: l10n.daCoKetLuanHoanTien(
          '${dinhDangTien(hoSo.tienHoan ?? 0)}đ',
        ),
        moTa: l10n.hoanTienVeTaiKhoan,
        mau: AppColors.primaryColor,
      ),
      TinhTrangHoSo.khongChapNhan => ViStatusBanner(
        icon: Icons.info_outline_rounded,
        tieuDe: l10n.khieuNaiKhongDuocChapNhan,
        moTa: l10n.moTaKhongChapNhanChuNuoi(luc),
        mau: AppColors.textSecondary,
      ),
    };
  }
}

class _KhoiKetLuan extends StatelessWidget {
  const _KhoiKetLuan({required this.ketLuan, required this.tienHoan});

  final KetLuanHoSo ketLuan;
  final int? tienHoan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: ViSectionTitle(l10n.ketLuanCuaHoTro)),
              Text(_moc(ketLuan.luc) ?? '', style: AppTextStyles.captionSm),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          ViNoteBlock(
            nhan: l10n.ketLuan,
            noiDung: ketLuan.noiDung ?? '',
            nhanNhat: true,
          ),
          if (ketLuan.lyDo case final lyDo?) ...[
            const SizedBox(height: AppSpacing.itemGap),
            ViNoteBlock(nhan: l10n.lyDo, noiDung: lyDo, nhanNhat: true),
          ],
          if (tienHoan case final tien? when tien > 0) ...[
            const SizedBox(height: AppSpacing.itemGap),
            ViNoteBlock(
              nhan: l10n.tienHoanChoBan,
              noiDung: '${dinhDangTien(tien)}đ',
              nhanNhat: true,
            ),
          ],
          const SizedBox(height: AppSpacing.itemGap),
          ViNoteBlock(
            nhan: l10n.nguoiXuLy,
            noiDung: ketLuan.nguoiXuLy,
            nhanNhat: true,
          ),
        ],
      ),
    );
  }
}

String? _moc(DateTime? luc) =>
    luc == null ? null : '${gioPhut(luc)} · ${ngayThang(luc)}';
