import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/shared/utils/loi_vai_tro.dart';

String moTaLoiDonNcc(BuildContext context, Object error) {
  final l10n = context.l10n;
  final loiVai = moTaLoiVaiTro(l10n, error);
  if (loiVai != null) return loiVai;
  switch (codeFromError(error)) {
    case 'KHONG_TIM_THAY_DON':
      return l10n.loiKhongTimThayDon;
    case 'QUA_HAN_NHAN_DON':
      return l10n.loiQuaHanNhanDon;
    case 'TRANG_THAI_KHONG_HOP_LE':
      return l10n.loiTrangThaiKhongHopLe;
    case 'THIEU_CAM_KET_DUNG_CU':
      return l10n.camKetDungCuDeTiepTuc;
    case 'DA_XUAT_PHAT_KHONG_HUY_DUOC':
      return l10n.loiDaXuatPhatDungKhongTheTiepNhan;
    case 'CHUA_XUAT_PHAT':
      return l10n.loiChuaXuatPhat;
    case 'CHUA_TOI_DIEM_DON':
      return l10n.loiChuaToiDiemDon;
    case 'THIEU_MO_TA_LY_DO':
      return l10n.loiThieuMoTaLyDo;
    case 'THIEU_ANH':
      return l10n.loiThieuAnh;
    case 'HO_SO_DANG_BI_TAM_AN':
    case 'NGOAI_VUNG_DIEM_DON':
    case 'CHUA_TOI_GIO_XUAT_PHAT':
    case 'CHUA_CHO_DU_AN_HAN':
    case 'CHUA_HET_AN_HAN_DUNG_CU':
    case 'VUOT_GIOI_HAN_ANH':
    case 'VUOT_TRAN_ANH_MOI_LUOT':
    case 'SLOT_DA_DAT':
    case 'SAI_SO_ANH_BAT_BUOC':
    case 'CHUA_TOI_GIO_BAT_DAU':
    case 'CHUA_BAO_THIEU_DUNG_CU':
    case 'CHU_NUOI_DA_TOI':
      return messageFromError(error) ?? l10n.loiKetNoiMayChu;
  }
  return messageFromError(error) ?? l10n.loiKetNoiMayChu;
}
