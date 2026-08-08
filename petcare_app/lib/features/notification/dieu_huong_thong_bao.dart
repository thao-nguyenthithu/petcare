import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/account/widgets/sitter_switch_sheet.dart';
import 'package:petcare_app/features/messaging/mo_chat_cua_don.dart';
import 'package:petcare_app/features/notification/data/thong_bao.dart';
import 'package:petcare_app/features/pets/screens/pet_detail_screen.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';

// Tin của vai phải đổi chế độ trước, không thì lạc giữa hai bộ route
Future<void> moThongBao(
  BuildContext context,
  ThongBao tin, {
  required bool dangCheDoNcc,
  bool coVaiNcc = true,
  TomTatDonNcc? tomTatNcc,
}) async {
  // Hồ sơ chưa duyệt thì không có bộ route người chăm để chuyển sang
  final laTinNcc = tin.vai == VaiNhan.nguoiCham && coVaiNcc;

  if (laTinNcc != dangCheDoNcc) {
    final sheet = laTinNcc
        ? showSitterSwitchSheet(context, tomTat: tomTatNcc)
        : showOwnerSwitchSheet(context);
    final dongY = await sheet;
    if (dongY != true || !context.mounted) return;
    context.go(laTinNcc ? AppRoutes.sitterHome : AppRoutes.home);
    if (!context.mounted) return;
  }

  await _moDich(context, tin, laNcc: laTinNcc);
}

Future<void> _moDich(
  BuildContext context,
  ThongBao tin, {
  required bool laNcc,
}) async {
  final id = tin.targetId;
  switch (tin.loai) {
    case LoaiThongBao.donHang:
    case LoaiThongBao.donHuy:
    case LoaiThongBao.donMoi:
    case LoaiThongBao.nhacLich:
    case LoaiThongBao.khieuNai:
    case LoaiThongBao.bangChung:
      _moDon(context, id, laNcc: laNcc);

    case LoaiThongBao.tinNhan:
      if (id == null) return;
      await moChatCuaDon(context, id, laChuNuoi: !laNcc);

    case LoaiThongBao.danhGia:
      if (laNcc) {
        context.push(AppRoutes.sitterReviews);
      } else {
        _moDon(context, id, laNcc: false);
      }

    case LoaiThongBao.tienVi:
      context.push(laNcc ? AppRoutes.sitterWallet : AppRoutes.ownerSpending);

    case LoaiThongBao.hoSo:
      context.push(AppRoutes.sitterSubmitted);

    case LoaiThongBao.phongBenh:
      if (id == null) return;
      context.push(AppRoutes.petDetail, extra: PetDetailArgs(petId: id));

    case LoaiThongBao.noiDung:
      return;
  }
}

void _moDon(BuildContext context, String? bookingId, {required bool laNcc}) {
  if (bookingId == null) return;
  if (laNcc) {
    context.push(AppRoutes.sitterOrderDetailPath(bookingId));
  } else {
    context.push(AppRoutes.bookingDetail, extra: bookingId);
  }
}
