import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';
import 'package:petcare_app/shared/widgets/session_blocks.dart';

// Dải số liệu chốt của phiên
List<SoLieuPhien> soLieuDonChuNuoi(
  BuildContext context,
  OwnerBookingDetail don,
  KetQuaPhien kq,
) {
  final l10n = context.l10n;
  final thoiLuong = (so: khoangChinhXac(l10n, kq.phut), nhan: l10n.thoiLuong);
  final anh = (so: l10n.nAnh('${kq.soAnh}'), nhan: l10n.minhChung);
  return switch (kq.km) {
    final km? => [
      thoiLuong,
      (so: l10n.soKm(soLeKm(km)), nhan: l10n.quangDuong),
      anh,
    ],
    _ when don.loai == ServiceType.grooming => [
      thoiLuong,
      (so: l10n.soBe('${don.pets.length}'), nhan: l10n.daLamNhan),
      anh,
    ],
    _ when don.chuNuoiPhaiDi => [
      (so: l10n.soDemNhan('${don.soDem ?? 0}'), nhan: l10n.thoiLuong),
      (so: l10n.nAnh('${kq.soAnh}'), nhan: l10n.nhatKyNhan),
      (so: l10n.soBe('${don.pets.length}'), nhan: l10n.daTrongNhan),
    ],
    _ => [thoiLuong, anh],
  };
}
