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
    case 'THIEU_HO_TEN':
      return l10n.loiThieuHoTen;
    case 'SDT_DA_DUOC_DUNG':
      return l10n.loiSdtDaDuocDung;
    case 'TOKEN_KHONG_HOP_LE':
      return l10n.loiTokenKhongHopLe;
    case 'KHONG_PHAI_DON_CUA_BAN':
      return l10n.loiKhongPhaiDonCuaBan;
    case 'KHONG_TIM_THAY_LO_ANH':
      return l10n.loiKhongTimThayLoAnh;
    case 'CHUA_QUET_DU_CAC_BE':
      return l10n.loiChuaQuetDuCacBe;
    case 'KHONG_DOC_DUOC_KICH_THUOC_ANH':
      return l10n.loiKhongDocDuocKichThuocAnh;
    case 'SAI_DANH_SACH_SLOT':
      return l10n.loiSaiDanhSachSlot;
    case 'DANG_QUET_LO_TRUOC':
      return l10n.loiDangQuetLoTruoc;
    case 'TRUNG_SLOT_TRONG_LO':
      return l10n.loiTrungSlotTrongLo;
    case 'THIEU_ANH_BE':
      return l10n.loiThieuAnhBe;
    case 'SLOT_KHONG_HOP_LE':
      return l10n.loiSlotKhongHopLe;
    case 'CHUA_DUOC_TU_XAC_NHAN':
      return l10n.loiChuaDuocTuXacNhan;
    case 'DON_DA_NHAN_KHONG_TU_CHOI_DUOC':
      return l10n.loiDonDaNhanKhongTuChoiDuoc;
    case 'TRUNG_LICH_DON_KHAC':
      return l10n.loiTrungLichDonKhac;
    case 'SAI_LOAI_DICH_VU':
      return l10n.loiSaiLoaiDichVuViec;
    case 'THIEU_ANH_BANG_CHUNG':
      return l10n.loiThieuAnhBangChung;
    case 'KHONG_CO_ANH_DO_DUNG':
      return l10n.loiKhongCoAnhDoDung;
  }
  return messageFromError(error) ?? l10n.loiKetNoiMayChu;
}
