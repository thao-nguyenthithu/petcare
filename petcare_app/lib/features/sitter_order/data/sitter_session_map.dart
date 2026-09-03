import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/features/sitter_order/data/grooming_session.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_absence.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_check_in.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';

WalkingSession phienDatTuDon(
  AppLocalizations l10n,
  String bookingId,
  SitterOrderDetail don,
  ChiTietDonNccApi api,
) {
  final bayGio = nowVn();
  final phien = api.phien;
  final batDau = phien?.batDauLuc;
  final het = api.dong.ketThuc;
  final phutDaDat = batDau == null ? 0 : bayGio.difference(batDau).inMinutes;
  final km = phien?.km ?? 0;
  return WalkingSession(
    bookingId: bookingId,
    don: don,
    giaiDoan: _giaiDoanPhien(batDau, het, bayGio),
    kmDaDi: km,
    kmLoTrinh: km,
    conLai: het == null
        ? dongHoPhutGiay(Duration.zero)
        : dongHoPhutGiay(het.difference(bayGio)),
    phutDaDat: phutDaDat < 0 ? 0 : phutDaDat,
    soAnhDaGui: phien?.tongAnh ?? 0,
    batDauLuc: batDau,
    ketThucLuc: het,
  );
}

// Buổi tắm và cắt tỉa đang chạy
GroomingSession buoiGroomingTuDon(
  AppLocalizations l10n,
  SitterOrderDetail don,
  ChiTietDonNccApi api,
) {
  final bayGio = nowVn();
  final g = api.grooming;
  final duKien = g?.duKienXongLuc;
  final quaGio = duKien != null && bayGio.isAfter(duKien);
  final lech = duKien == null
      ? Duration.zero
      : (quaGio ? bayGio.difference(duKien) : duKien.difference(bayGio));
  return GroomingSession(
    don: don,
    giaiDoan: quaGio ? GiaiDoanGrooming.quaDuKien : GiaiDoanGrooming.dungHen,
    gioBatDau: _gio(g?.batDauLuc) ?? '',
    conLaiDuKien: dongHoDem(lech),
    soAnhDaGui: (g?.anhTruoc.length ?? 0) + (g?.anhSau.length ?? 0),
  );
}

// Kỳ trông giữ đang chạy
BoardingSession kyGiuTuDon(SitterOrderDetail don, ChiTietDonNccApi api) {
  final ky = api.trongGiu;
  final tra = ky?.traBeLuc;
  return BoardingSession(
    don: don,
    soAnhDaGui: ky?.anh.length ?? 0,
    moTraBe: tra != null && !nowVn().isBefore(tra),
  );
}

CheckInArgs checkInTuDon(SitterOrderDetail don, ChiTietDonNccApi api) {
  final bayGio = nowVn();
  final hetCho = api.hetChoDungCuLuc;
  final trangThai = switch (hetCho) {
    null => TrangThaiCheckIn.binhThuong,
    final moc when bayGio.isBefore(moc) => TrangThaiCheckIn.daBaoThieu,
    _ => TrangThaiCheckIn.hetHanDungCu,
  };
  return (
    don: don,
    trangThai: trangThai,
    gioBaoThieu: hetCho == null
        ? null
        : gioPhut(hetCho.subtract(const Duration(minutes: phutChoDungCu))),
    conLai: trangThai == TrangThaiCheckIn.daBaoThieu
        ? dongHoPhutGiay(hetCho!.difference(bayGio))
        : null,
  );
}

BaoVangMat baoVangMatTuDon(SitterOrderDetail don, ChiTietDonNccApi api) {
  final bayGio = nowVn();
  final mocCho = [
    api.dong.batDau,
    ?api.toiNoiLuc,
  ].reduce((a, b) => a.isAfter(b) ? a : b);
  final daCho = bayGio.difference(mocCho).inMinutes;
  return BaoVangMat(
    don: don,
    loai: LoaiBaoVangMat.toiBao,
    gioCoMat: _gio(api.toiNoiLuc) ?? gioPhut(api.dong.batDau),
    phutDaCho: daCho < 0 ? 0 : daCho,
    metSaiLech: api.metCachDiemDon ?? 0,
  );
}

GiaiDoanPhien _giaiDoanPhien(DateTime? batDau, DateTime? het, DateTime bayGio) {
  if (batDau == null || het == null) return GiaiDoanPhien.dangDat;
  final tong = het.difference(batDau).inSeconds;
  if (tong <= 0) return GiaiDoanPhien.phaiQuayVe;
  final daQua = bayGio.difference(batDau).inSeconds;
  return daQua * 2 >= tong ? GiaiDoanPhien.phaiQuayVe : GiaiDoanPhien.dangDat;
}

String? _gio(DateTime? d) => d == null ? null : gioPhut(d);
