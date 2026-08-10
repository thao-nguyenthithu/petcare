import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/reviews/providers/reviews_provider.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/anh_multipart.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const int _soAnhToiDa = 6;
const List<String> maKhenNguoiCham = [
  'dungGio',
  'chamSocTanTinh',
  'anhCapNhatDayDu',
  'giaoTiepTot',
  'beVuiVeKhiVe',
];

String nhanKhen(AppLocalizations l10n, String ma) => switch (ma) {
  'dungGio' => l10n.khenDungGio,
  'chamSocTanTinh' => l10n.khenChamSocTanTinh,
  'anhCapNhatDayDu' => l10n.khenAnhCapNhatDayDu,
  'giaoTiepTot' => l10n.khenGiaoTiepTot,
  _ => l10n.khenBeVuiVeKhiVe,
};

typedef DonDeDanhGia = ({
  String bookingId,
  String maDon,
  ServiceType loai,
  int soBe,
  String tenNcc,
  String? avatarNcc,
});

DonDeDanhGia donDeDanhGia(OwnerBookingDetail don) => (
  bookingId: don.id,
  maDon: don.maDon,
  loai: don.loai,
  soBe: don.pets.length,
  tenNcc: don.tenNcc,
  avatarNcc: don.avatarNcc,
);

// Màn đánh giá người chăm sau khi đơn hoàn thành
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.don, this.saoBanDau = 0});

  final DonDeDanhGia don;
  final int saoBanDau;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final TextEditingController _nhanXet = TextEditingController();
  final Set<String> _khen = {};
  List<Uint8List> _anh = [];
  late int _sao = widget.saoBanDau;
  bool _dangGui = false;

  @override
  void dispose() {
    _nhanXet.dispose();
    super.dispose();
  }

  Future<void> _gui() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nhanXet = _nhanXet.text.trim();
    setState(() => _dangGui = true);
    try {
      await ref
          .read(donChoDanhGiaCuaToiProvider.notifier)
          .viet(
            bookingId: widget.don.bookingId,
            sao: _sao,
            nhanXet: nhanXet.isEmpty ? null : nhanXet,
            anh: anhMultipart(_anh, 'review'),
            maKhen: _khen.toList(),
          );
      if (!mounted) return;
      ref.refreshBookingData();
      messenger.showSnackBar(SnackBar(content: Text(l10n.daGuiDanhGia)));
      context.pop();
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
    final don = widget.don;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.danhGiaDichVu,
            subtitle:
                '${don.maDon} · ${serviceTypeNameDai(context, don.loai)} · '
                '${l10n.soBe('${don.soBe}')}',
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 20, bottom: 24),
        children: [
          FlatSection(
            child: _ChonSao(don: don, sao: _sao, onChon: _datSao),
          ),
          const FlatDivider(),
          FlatSection(
            child: _ChonKhen(chon: _khen, onDoi: _doiKhen),
          ),
          const FlatDivider(),
          FlatSection(
            child: _NhanXet(
              controller: _nhanXet,
              anh: _anh,
              onDoiAnh: (ds) => setState(() => _anh = ds),
            ),
          ),
        ],
      ),
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: l10n.guiDanhGia,
                color: AppColors.accent,
                enabled: _sao > 0,
                dangTai: _dangGui,
                onTap: _gui,
              ),
              AppButton(
                text: l10n.deSau,
                flat: true,
                onTap: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _datSao(int sao) => setState(() => _sao = sao);

  void _doiKhen(String khen) => setState(() {
    if (!_khen.remove(khen)) _khen.add(khen);
  });
}

class _ChonSao extends StatelessWidget {
  const _ChonSao({required this.don, required this.sao, required this.onChon});

  final DonDeDanhGia don;
  final int sao;
  final void Function(int sao) onChon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAvatar(name: don.tenNcc, imageUrl: don.avatarNcc, size: 72),
        const SizedBox(height: 12),
        Text(don.tenNcc, style: AppTextStyles.h3),
        const SizedBox(height: 10),
        StarPicker(sao: sao, onChon: onChon, size: 34),
        if (sao > 0) ...[
          const SizedBox(height: 8),
          Text(
            nhanSoSao(context, sao),
            style: AppTextStyles.label.copyWith(color: AppColors.primaryColor),
          ),
        ],
      ],
    );
  }
}

class StarPicker extends StatelessWidget {
  const StarPicker({
    super.key,
    required this.sao,
    required this.onChon,
    this.size = 30,
  });

  final int sao;
  final void Function(int sao) onChon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          InkWell(
            onTap: () => onChon(i),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(
                Icons.star_rounded,
                size: size,
                color: i <= sao ? AppColors.honey : AppColors.neutralLight,
              ),
            ),
          ),
      ],
    );
  }
}

String nhanSoSao(BuildContext context, int sao) {
  final l10n = context.l10n;
  return switch (sao) {
    1 => l10n.saoRatTe,
    2 => l10n.saoChuaTot,
    3 => l10n.saoBinhThuong,
    4 => l10n.saoTot,
    _ => l10n.saoRatTot,
  };
}

class _ChonKhen extends StatelessWidget {
  const _ChonKhen({required this.chon, required this.onDoi});

  final Set<String> chon;
  final void Function(String khen) onDoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dieuGiBanHaiLong, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ma in maKhenNguoiCham)
              AppFilterChip(
                label: nhanKhen(l10n, ma),
                selected: chon.contains(ma),
                onTap: () => onDoi(ma),
              ),
          ],
        ),
      ],
    );
  }
}

class _NhanXet extends StatelessWidget {
  const _NhanXet({
    required this.controller,
    required this.anh,
    required this.onDoiAnh,
  });

  final TextEditingController controller;
  final List<Uint8List> anh;
  final ValueChanged<List<Uint8List>> onDoiAnh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.nhanXetThemTuyChon, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.hintNhanXetThem,
            hintStyle: AppTextStyles.captionSm,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PhotoPickerGrid(anh: anh, tran: _soAnhToiDa, onDoi: onDoiAnh),
      ],
    );
  }
}
