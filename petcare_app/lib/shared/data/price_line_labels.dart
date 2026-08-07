import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

String nhanDongGiaDon(
  BuildContext context, {
  required String key,
  required int tien,
  required Map<String, dynamic> meta,
  Pet? be,
}) {
  final l10n = context.l10n;
  int so(String khoa) => (meta[khoa] as num?)?.round() ?? 0;
  switch (key) {
    case 'goiDat':
      return l10n.dongBeDauGoi(
        dinhDangTien(tien),
        l10n.nPhut('${so('durationMinutes')}'),
      );
    case 'phuPhiBeThem':
      return l10n.dongPhuPhiThemNBe(
        '${so('soBeThem')}',
        dinhDangTien(so('moiBe')),
      );
    case 'giaDemBeDau':
      return l10n.dongBeDauMoiDem(dinhDangTien(so('giaDem')), '${so('soDem')}');
    case 'phuPhiBeThemMoiDem':
      return l10n.dongPhuPhiThemNBeMoiDem(
        '${so('soBeThem')}',
        dinhDangTien(so('moiBe')),
        '${so('soDem')}',
      );
    case 'phiGiuThem':
      return l10n.phiGiuThemNhan;
    case 'goiCuaBe':
      if (be == null) return l10n.chuaCapNhat;
      final goi = meta['packageCode'] == 'bath'
          ? GroomingPackage.bath
          : GroomingPackage.bathAndTrim;
      return '${be.name} · ${groomingPackageName(context, goi)} · '
          '${l10n.soKgCanNang(canNangGon(be.weightKg))}';
  }
  return l10n.chuaCapNhat;
}
