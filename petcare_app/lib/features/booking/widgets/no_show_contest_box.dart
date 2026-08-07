import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';
import 'package:petcare_app/features/sitter_order/widgets/handover_photo_group.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/utils/anh_multipart.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

const int _moTaToiThieu = 10;

class NoShowContestBox extends ConsumerStatefulWidget {
  const NoShowContestBox({super.key, required this.don});

  final OwnerBookingDetail don;

  @override
  ConsumerState<NoShowContestBox> createState() => _NoShowContestBoxState();
}

class _NoShowContestBoxState extends ConsumerState<NoShowContestBox> {
  final _moTa = TextEditingController();
  final List<Uint8List> _anh = [];
  bool _dangGui = false;

  Future<void> _themAnh() async {
    final conChoDuoc = soAnhMoKhieuNai - _anh.length;
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

  @override
  void dispose() {
    _moTa.dispose();
    super.dispose();
  }

  bool get _conHan {
    final moc = widget.don.thongTinHuy?.mocHuy;
    if (moc == null) return false;
    return nowVn().difference(moc).inHours < gioHanPhanDoiVangMat;
  }

  Future<void> _gui() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _dangGui = true);
    try {
      await BookingsApiService().moKhieuNai(
        widget.don.id,
        moTa: _moTa.text.trim(),
        anh: anhMultipart(_anh, 'dispute'),
      );
      if (!mounted) return;
      ref.refreshBookingData();
      messenger.showSnackBar(SnackBar(content: Text(l10n.daGuiPhanDoi)));
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
    if (!_conHan) {
      return AppNoteBox(
        text: l10n.quaHanPhanDoiVangMat('$gioHanPhanDoiVangMat'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.banKhongDongY, style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          l10n.moTaHanPhanDoiChuNuoi('$gioHanPhanDoiVangMat'),
          style: AppTextStyles.captionSm,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _moTa,
          minLines: 3,
          maxLines: 5,
          textInputAction: TextInputAction.newline,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: l10n.hintPhanDoiVangMat),
        ),
        const SizedBox(height: 12),
        HandoverPhotoGroup(
          tieuDe: l10n.anhKhieuNaiTrenTran(
            '${_anh.length}',
            '$soAnhMoKhieuNai',
          ),
          anh: _anh,
          tran: soAnhMoKhieuNai,
          onThem: _themAnh,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: l10n.guiPhanDoi,
          height: 50,
          color: AppColors.accent,
          enabled: _moTa.text.trim().length >= _moTaToiThieu,
          dangTai: _dangGui,
          onTap: _gui,
        ),
      ],
    );
  }
}
