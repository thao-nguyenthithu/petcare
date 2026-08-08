import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';

const List<String> maLyDoHuyChuNuoi = [
  'doiLichKhac',
  'khongCanNua',
  'timDuocNccKhac',
  'nccChamPhanHoi',
  'khac',
];

const String maLyDoKhac = 'khac';

const String maLyDoNccChuaToi = 'nccChuaToi';

String nhanLyDoHuy(BuildContext context, String? ma) {
  final l10n = context.l10n;
  return switch (ma) {
    'doiLichKhac' => l10n.lyDoDoiLichKhac,
    'khongCanNua' => l10n.lyDoKhongCanNua,
    'timDuocNccKhac' => l10n.lyDoTimDuocNccKhac,
    'nccChamPhanHoi' => l10n.lyDoNccChamPhanHoi,
    maLyDoNccChuaToi => l10n.nguoiChamChuaToi,
    _ => l10n.lyDoKhac,
  };
}
