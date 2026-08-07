import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/owner_booking_detail_provider.dart';
import 'package:petcare_app/features/booking/services/booking_error_mapper.dart';
import 'package:petcare_app/shared/utils/mo_chi_duong.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';

void moAnhMinhChung(BuildContext context, OwnerBookingDetail don) {
  context.push(AppRoutes.bookingProofPhotos, extra: don);
}

Future<void> chuNuoiXuatPhat(
  BuildContext context,
  WidgetRef ref,
  OwnerBookingDetail don, {
  bool daXuatPhat = false,
}) async {
  final viTri = don.viTri;
  if (viTri == null) return;
  if (!daXuatPhat) {
    try {
      await ref.read(bookingDetailProvider(don.id).notifier).xuatPhat();
    } catch (loi) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(moTaLoiDatLich(context, loi))));
      return;
    }
  }
  if (!context.mounted) return;
  await moChiDuong(context, viTri);
}

void moDanhSachBe(BuildContext context, OwnerBookingDetail don) {
  context.push(
    AppRoutes.bookingPets,
    extra: (maDon: don.maDon, tenDichVu: don.tenDichVu, pets: don.pets),
  );
}

void moHoSoGoiY(BuildContext context, GoiYNcc ncc) {
  final id = ncc.sitterId;
  if (id == null) {
    baoDangPhatTrien(context);
    return;
  }
  context.push(AppRoutes.sitterDetailPath(id));
}

void moHoSoNcc(BuildContext context, OwnerBookingDetail don) {
  final id = don.sitterId;
  if (id == null) {
    baoDangPhatTrien(context);
    return;
  }
  context.push(AppRoutes.sitterDetailPath(id));
}
