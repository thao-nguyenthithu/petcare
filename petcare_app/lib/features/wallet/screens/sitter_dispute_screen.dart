import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/features/wallet/services/wallet_api_service.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/anh_multipart.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

const double _duongKinhAvatar = 44;

// Một màn dựng cả ba tình trạng khiếu nại
class SitterDisputeScreen extends StatefulWidget {
  const SitterDisputeScreen({super.key, required this.hoSo});

  final HoSoKhieuNai hoSo;

  @override
  State<SitterDisputeScreen> createState() => _SitterDisputeScreenState();
}

class _SitterDisputeScreenState extends State<SitterDisputeScreen> {
  final _phanHoiController = TextEditingController();
  final List<Uint8List> _anh = [];
  bool _dangGui = false;

  @override
  void dispose() {
    _phanHoiController.dispose();
    super.dispose();
  }

  Future<void> _themAnh() async {
    final conChoDuoc = soAnhPhanHoiKhieuNai - _anh.length;
    if (conChoDuoc <= 0) return;
    final chon = await chonNhieuAnh(conChoDuoc);
    if (!mounted) return;
    if (chon.quaNang > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loiAnhQuaNang('$mbAnhToiDa'))),
      );
    }
    if (chon.anh.isEmpty) return;
    setState(() => _anh.addAll(chon.anh));
  }

  Future<void> _guiPhanHoi() async {
    final noiDung = _phanHoiController.text.trim();
    if (noiDung.isEmpty) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _dangGui = true);
    try {
      await WalletApiService().phanHoiKhieuNai(
        widget.hoSo.ma,
        noiDung,
        anh: anhMultipart(_anh, 'dispute-reply'),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.daGuiPhanHoiKhieuNai)),
      );
      Navigator.of(context).pop();
    } catch (loi) {
      if (!mounted) return;
      setState(() => _dangGui = false);
      messenger.showSnackBar(
        SnackBar(content: Text(messageFromError(loi) ?? l10n.loiKetNoiMayChu)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hoSo = widget.hoSo;
    final choPhanHoi = hoSo.trangThai == TrangThaiKhieuNai.choBanPhanHoi;

    return AppScreen(
      backgroundColor: AppColors.background,
      header: AppScreenHeader(title: l10n.hoSoKhieuNai),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.labelGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          _Banner(hoSo: hoSo),
          const SizedBox(height: AppSpacing.stackGap),
          _HangDon(hoSo: hoSo),
          const SizedBox(height: AppSpacing.stackGap),
          const AppDongKe(),
          const SizedBox(height: AppSpacing.stackGap),
          ViNoteBlock(
            nhan: l10n.chuNuoiPhanAnh,
            noiDung: hoSo.phanAnh,
            moc: hoSo.thoiDiemPhanAnh,
          ),
          if (hoSo.anhPhanAnh.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.stackGap),
            ViPhotoRow(anh: hoSo.anhPhanAnh),
          ],
          const SizedBox(height: AppSpacing.groupGap),
          if (choPhanHoi)
            _OPhanHoi(
              controller: _phanHoiController,
              anh: _anh,
              onThemAnh: _themAnh,
              dangGui: _dangGui,
              onGui: _guiPhanHoi,
            )
          else if (hoSo.phanHoiCuaBan != null) ...[
            ViNoteBlock(
              nhan: l10n.phanHoiCuaBan,
              noiDung: hoSo.phanHoiCuaBan!,
              moc: hoSo.thoiDiemPhanHoi,
            ),
            if (hoSo.anhPhanHoi.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.stackGap),
              ViPhotoRow(anh: hoSo.anhPhanHoi),
            ],
          ],
          if (hoSo.ketLuan != null) ...[
            const SizedBox(height: AppSpacing.groupGap),
            _KhoiKetLuan(ketLuan: hoSo.ketLuan!),
          ],
          if (hoSo.tongCuoi != null) ...[
            const SizedBox(height: AppSpacing.groupGap),
            ViSectionTitle(l10n.tienVeTay),
            const SizedBox(height: AppSpacing.stackGap),
            ViMoneyRows(dong: hoSo.cacDongTien, tong: hoSo.tongCuoi!),
          ],
          if (hoSo.dienBien.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.groupGap),
            ViSectionTitle(l10n.dienBien),
            const SizedBox(height: AppSpacing.stackGap),
            ViTimeline(moc: hoSo.dienBien),
          ],
          if (hoSo.maGiaoDichLienQuan != null) ...[
            const SizedBox(height: AppSpacing.groupGap),
            ViSecondaryButton(
              nhan: hoSo.trangThai == TrangThaiKhieuNai.khongChapNhan
                  ? l10n.xemGiaoDichTienVaoVi(hoSo.maGiaoDichLienQuan!)
                  : l10n.xemGiaoDichTruTien(hoSo.maGiaoDichLienQuan!),
              onTap: () => context.push(
                AppRoutes.sitterTransactionPath(hoSo.maGiaoDichLienQuan!),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.stackGap),
          Text(switch (hoSo.trangThai) {
            TrangThaiKhieuNai.khongChapNhan => l10n.maKhieuNaiDaDong(hoSo.ma),
            TrangThaiKhieuNai.daHoanMotPhan => l10n.maKhieuNaiDaApDung(hoSo.ma),
            _ => l10n.maKhieuNaiLuuCanCu(hoSo.ma),
          }, style: AppTextStyles.captionSm),
          if (hoSo.dangCho) ...[
            const SizedBox(height: AppSpacing.textGap),
            Text(
              l10n.donDangKhieuNaiChoKetLuan,
              style: AppTextStyles.captionSm,
            ),
          ],
        ],
      ),
    );
  }
}

// Đỏ khi còn hạn phản hồi, xanh khi đã có kết luận
class _Banner extends StatelessWidget {
  const _Banner({required this.hoSo});

  final HoSoKhieuNai hoSo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (hoSo.trangThai) {
      TrangThaiKhieuNai.choBanPhanHoi ||
      TrangThaiKhieuNai.choHoTroXuLy => ViStatusBanner(
        icon: Icons.priority_high_rounded,
        tieuDe: l10n.conKhoangDeBanPhanHoi(
          dongHoConLai(l10n, hoSo.phutConLai ?? 0),
        ),
        moTa: l10n.hetHanPhanHoiMoTa(hoSo.hanPhanHoi ?? ''),
        mau: AppColors.error,
      ),
      TrangThaiKhieuNai.daHoanMotPhan => ViStatusBanner(
        icon: Icons.check_rounded,
        tieuDe: l10n.daKetLuanHoanPhanTram('20'),
        moTa: l10n.moTaDaKetLuan(
          hoSo.ketLuan?.thoiDiem ?? '',
          dinhDangTien(hoSo.soTien),
        ),
        mau: AppColors.primaryColor,
      ),
      TrangThaiKhieuNai.khongChapNhan => ViStatusBanner(
        icon: Icons.check_rounded,
        tieuDe: l10n.khieuNaiKhongDuocChapNhan,
        moTa: l10n.moTaKhongChapNhan(dinhDangTien(hoSo.soTien)),
        mau: AppColors.primaryColor,
      ),
    };
  }
}

// Hàng đơn của hồ sơ, bên phải là tiền kèm tình trạng
class _HangDon extends StatelessWidget {
  const _HangDon({required this.hoSo});

  final HoSoKhieuNai hoSo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = hoSo.don;
    final be = don.pets.isEmpty ? null : don.pets.first;
    final dangGiu = hoSo.dangCho;
    return ViBookingRow(
      avatar: PetAvatar(
        imageUrl: be?.avatar,
        name: be?.name,
        size: _duongKinhAvatar,
      ),
      tieuDe: don.dichVu.ten(l10n),
      maDon: don.maDon,
      tenBe: be?.name ?? '',
      moTaMoc: hoSo.moTaMoc,
      duoi: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${dinhDangTien(hoSo.soTien)}đ',
            style: AppTextStyles.button.copyWith(
              color: dangGiu ? AppColors.textSecondary : AppColors.accent,
            ),
          ),
          Text(
            dangGiu ? l10n.dangBiGiu : l10n.daVaoVi,
            style: AppTextStyles.captionSm,
          ),
        ],
      ),
    );
  }
}

// Ô nhập phản hồi kèm nút gửi ảnh và nút gửi
class _OPhanHoi extends StatelessWidget {
  const _OPhanHoi({
    required this.controller,
    required this.anh,
    required this.onThemAnh,
    required this.dangGui,
    required this.onGui,
  });

  final TextEditingController controller;
  final List<Uint8List> anh;
  final VoidCallback onThemAnh;
  final bool dangGui;
  final VoidCallback onGui;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViSectionTitle(l10n.phanHoiCuaBan),
        const SizedBox(height: AppSpacing.stackGap),
        AppTextField(
          controller: controller,
          label: '',
          hint: l10n.hintPhanHoiKhieuNai,
          maxLines: 4,
          height: 108,
        ),
        const SizedBox(height: AppSpacing.itemGap),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: anh.length >= soAnhPhanHoiKhieuNai
                    ? null
                    : onThemAnh,
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  l10n.anhChungMinhTrenTran(
                    '${anh.length}',
                    '$soAnhPhanHoiKhieuNai',
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: FilledButton(
                onPressed: dangGui ? null : onGui,
                child: Text(l10n.guiPhanHoi),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Kết luận của hỗ trợ: nội dung, lý do, người xử lý
class _KhoiKetLuan extends StatelessWidget {
  const _KhoiKetLuan({required this.ketLuan});

  final KetLuanHoTro ketLuan;

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
              Text(ketLuan.thoiDiem, style: AppTextStyles.captionSm),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          ViNoteBlock(
            nhan: l10n.ketLuan,
            noiDung: ketLuan.noiDung,
            nhanNhat: true,
          ),
          if (ketLuan.lyDo != null) ...[
            const SizedBox(height: AppSpacing.itemGap),
            ViNoteBlock(
              nhan: l10n.lyDo,
              noiDung: ketLuan.lyDo!,
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
