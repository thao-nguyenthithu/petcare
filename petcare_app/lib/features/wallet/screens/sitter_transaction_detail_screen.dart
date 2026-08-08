import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/widgets/sitter_booking_card.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';

const double _duongKinhAvatar = 44;

// Một màn dựng cả ba loại giao dịch của ví
class SitterTransactionDetailScreen extends ConsumerWidget {
  const SitterTransactionDetailScreen({super.key, required this.chiTiet});

  final ChiTietGiaoDich chiTiet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final gd = chiTiet.giaoDich;
    final mau = gd.laTienVao ? AppColors.accent : AppColors.textPrimary;

    final (nhanLoai, nhanTrangThai) = switch (gd.loai) {
      LoaiGiaoDich.tienVao => (
        l10n.tienVaoVi,
        '${l10n.daVaoVi} · ${chiTiet.mocTrangThai}',
      ),
      LoaiGiaoDich.rutRa => (
        l10n.rutVeNganHang,
        '${l10n.nganHangNhan} · ${chiTiet.mocTrangThai}',
      ),
      LoaiGiaoDich.dieuChinh => (
        l10n.truTheoKetLuanKhieuNai,
        '${l10n.daApDung} · ${chiTiet.mocTrangThai}',
      ),
    };

    return AppScreen(
      backgroundColor: AppColors.background,
      header: AppScreenHeader(title: l10n.chiTietGiaoDich),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.blockGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          ViAmountHeader(
            nhanLoai: nhanLoai,
            soTien: gd.soTien,
            nhanTrangThai: nhanTrangThai,
            mau: mau,
          ),
          const SizedBox(height: AppSpacing.blockGap),
          const AppDongKe(),
          const SizedBox(height: AppSpacing.stackGap),
          if (gd.don != null)
            _HangDon(don: gd.don!)
          else if (gd.nganHang != null)
            BankAccountCard(taiKhoan: gd.nganHang!),
          const SizedBox(height: AppSpacing.stackGap),
          if (chiTiet.ketLuan != null) ...[
            _KhoiKetLuan(
              ketLuan: chiTiet.ketLuan!,
              phanAnh: chiTiet.chuNuoiPhanAnh,
            ),
            const SizedBox(height: AppSpacing.groupGap),
          ],
          ViSectionTitle(_tieuDeKhoiTien(context, gd.loai)),
          const SizedBox(height: AppSpacing.stackGap),
          ViMoneyRows(
            dong: _cacDong(
              context,
              gd.loai,
              ref.watch(cauHinhNghiepVuProvider).phiNenTangPhanTram,
            ),
            tong: (
              nhan: gd.loai == LoaiGiaoDich.rutRa
                  ? l10n.nganHangNhan
                  : l10n.thucNhan,
              tien: chiTiet.tong,
            ),
            mauTong: gd.loai == LoaiGiaoDich.rutRa
                ? AppColors.textPrimary
                : AppColors.accent,
          ),
          if (chiTiet.dienBien.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.groupGap),
            ViSectionTitle(l10n.dienBien),
            const SizedBox(height: AppSpacing.stackGap),
            ViTimeline(moc: chiTiet.dienBien),
          ],
          const SizedBox(height: AppSpacing.groupGap),
          const AppDongKe(),
          const SizedBox(height: AppSpacing.stackGap),
          ViInfoRows(dong: _thongTinCuoi(context, gd)),
          const SizedBox(height: AppSpacing.groupGap),
          _NutDay(chiTiet: chiTiet),
        ],
      ),
    );
  }

  String _tieuDeKhoiTien(BuildContext context, LoaiGiaoDich loai) {
    final l10n = context.l10n;
    return loai == LoaiGiaoDich.rutRa ? l10n.soTien : l10n.tienVeTay;
  }

  // Hai dòng phụ của khối tiền, nhãn tuỳ loại
  List<DongHoaDon> _cacDong(
    BuildContext context,
    LoaiGiaoDich loai,
    int phanTramPhiNenTang,
  ) {
    final l10n = context.l10n;
    return switch (loai) {
      LoaiGiaoDich.tienVao => [
        (nhan: l10n.giaDichVuChuNuoiTra, tien: chiTiet.dongMot),
        (
          nhan: l10n.phiNenTangPhanTram('$phanTramPhiNenTang'),
          tien: chiTiet.dongHai,
        ),
      ],
      LoaiGiaoDich.rutRa => [
        (nhan: l10n.soTienRut, tien: chiTiet.dongMot),
        (nhan: l10n.phiChuyen, tien: chiTiet.dongHai),
      ],
      LoaiGiaoDich.dieuChinh => [
        (nhan: l10n.dangGiuTamTruocDo, tien: chiTiet.dongMot),
        (nhan: l10n.hoanChoChuNuoi, tien: chiTiet.dongHai),
      ],
    };
  }

  List<({String nhan, String giaTri})> _thongTinCuoi(
    BuildContext context,
    GiaoDichVi gd,
  ) {
    final l10n = context.l10n;
    return [
      (
        nhan: gd.loai == LoaiGiaoDich.rutRa ? l10n.maLenhRut : l10n.maGiaoDich,
        giaTri: gd.ma,
      ),
      if (gd.maThamChieu != null)
        (nhan: l10n.maThamChieuNganHang, giaTri: gd.maThamChieu!),
      (nhan: l10n.soDuViSauGiaoDich, giaTri: '${dinhDangTien(gd.soDuSau)}đ'),
    ];
  }
}

// Hàng đơn rút gọn, chạm vào mở chi tiết đơn
class _HangDon extends StatelessWidget {
  const _HangDon({required this.don});

  final SitterBooking don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final be = don.pets.isEmpty ? null : don.pets.first;
    return ViBookingRow(
      avatar: PetAvatar(
        imageUrl: be?.avatar,
        name: be?.name,
        size: _duongKinhAvatar,
      ),
      tieuDe: don.dichVu.ten(l10n),
      maDon: don.maDon,
      tenBe: be?.name ?? '',
      moTaMoc: '${don.tenChuNuoi} · ${don.nhanThoiGian(l10n)}',
      onTap: () => moChiTietDonNcc(context, don),
    );
  }
}

// Khối kết luận xử lý của giao dịch trừ tiền
class _KhoiKetLuan extends StatelessWidget {
  const _KhoiKetLuan({required this.ketLuan, this.phanAnh});

  final KetLuanHoTro ketLuan;
  final String? phanAnh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViSectionTitle(l10n.ketLuanXuLy),
        const SizedBox(height: AppSpacing.stackGap),
        if (phanAnh != null) ...[
          ViNoteBlock(
            nhan: l10n.chuNuoiPhanAnh,
            noiDung: phanAnh!,
            nhanNhat: true,
          ),
          const SizedBox(height: AppSpacing.stackGap),
        ],
        ViNoteBlock(
          nhan: l10n.ketLuanCuaHoTro,
          noiDung: ketLuan.noiDung,
          nhanNhat: true,
        ),
        const SizedBox(height: AppSpacing.stackGap),
        ViNoteBlock(
          nhan: l10n.nguoiXuLy,
          noiDung: ketLuan.nguoiXuLy,
          nhanNhat: true,
        ),
      ],
    );
  }
}

// Nút đáy đổi theo loại giao dịch
class _NutDay extends StatelessWidget {
  const _NutDay({required this.chiTiet});

  final ChiTietGiaoDich chiTiet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gd = chiTiet.giaoDich;
    final maKhieuNai = gd.maKhieuNai;
    return switch (gd.loai) {
      LoaiGiaoDich.tienVao || LoaiGiaoDich.rutRa => const SizedBox.shrink(),
      LoaiGiaoDich.dieuChinh => ViSecondaryButton(
        nhan: l10n.xemHoSoKhieuNai,
        onTap: maKhieuNai == null
            ? null
            : () => context.push(AppRoutes.sitterDisputePath(maKhieuNai)),
      ),
    };
  }
}
