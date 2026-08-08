import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/shared/data/pet.dart';

// Map mã lỗi cụm thú cưng sang câu tiếng Việt hiển thị cho chủ nuôi
String moTaLoiThuCung(BuildContext context, Object error) {
  final l10n = context.l10n;
  switch (codeFromError(error)) {
    case 'BE_DANG_CO_DON':
      return l10n.loiBeDangCoDon;
    case 'HANG_MUC_DA_CO':
      return l10n.hangMucDaCo;
    case 'VUOT_GIOI_HAN_ANH':
      return l10n.daDuSoAnhToiDa('$maxPetPhotos');
    case 'ANH_QUA_LON':
    case 'KIEU_ANH_KHONG_HO_TRO':
    case 'ANH_KHONG_HOP_LE':
      return l10n.loiAnhKhongHopLe;
    case 'VUOT_GIOI_HAN_THU_CUNG':
    case 'VUOT_GIOI_HAN_HANG_MUC':
    case 'VUOT_GIOI_HAN_LAN_GHI':
      return messageFromError(error) ?? l10n.loiKetNoiMayChu;
    case 'KHONG_TIM_THAY_THU_CUNG':
    case 'KHONG_TIM_THAY_HANG_MUC':
    case 'KHONG_TIM_THAY_LAN_GHI':
      return l10n.loiKhongTimThayHoSoBe;
    case 'NGAY_SINH_KHONG_HOP_LE':
      return l10n.loiNgaySinhBeKhongHopLe;
    case 'KHONG_TIM_THAY_ANH':
      return l10n.loiKhongTimThayAnh;
    case 'THIEU_ANH':
      return l10n.loiThieuAnh;
    case 'THIEU_TEN_HANG_MUC':
      return l10n.loiThieuTenHangMuc;
    case 'CHU_KY_KHONG_DAY_DU':
      return l10n.loiChuKyKhongDayDu;
    case 'NGAY_THUC_HIEN_O_TUONG_LAI':
      return l10n.loiNgayThucHienOTuongLai;
  }
  return messageFromError(error) ?? l10n.loiKetNoiMayChu;
}
