import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';

String moTaLoiDatLich(BuildContext context, Object error) {
  final l10n = context.l10n;
  switch (codeFromError(error)) {
    case 'NCC_KHONG_NHAN_DICH_VU':
      return l10n.loiNccKhongNhanDichVu;
    case 'NCC_NGHI_NGAY_NAY':
      return l10n.loiNccNghiNgayNay;
    case 'KHUNG_GIO_DA_CO_DON':
      return l10n.loiKhungGioDaCoDon;
    case 'HET_CHO_TRONG_GIU':
      return l10n.loiHetChoTrongGiu;
    case 'BE_DA_CO_DON':
      return messageFromError(error) ?? l10n.loiBeDaCoDon;
    case 'NGOAI_GIO_LAM_VIEC':
      return messageFromError(error) ?? l10n.loiNgoaiGioLamViec;
    case 'KHONG_TIM_THAY_NCC':
      return l10n.loiKhongTimThayNcc;
    case 'KHONG_TIM_THAY_THU_CUNG':
      return l10n.loiKhongTimThayHoSoBe;
    case 'KHONG_TIM_THAY_DIA_CHI':
      return l10n.loiKhongTimThayDiaChi;
    case 'THIEU_CAM_KET_DUNG_CU':
      return l10n.camKetDungCuDeTiepTuc;
    case 'THIEU_GIA_DICH_VU':
    case 'THIEU_GOI_GROOMING':
      return l10n.loiThieuGiaDichVu;
    case 'KHONG_TIM_THAY_DON':
      return l10n.loiKhongTimThayDon;
    case 'DON_KHONG_HUY_DUOC':
      return messageFromError(error) ?? l10n.loiDonKhongHuyDuoc;
    case 'DA_XUAT_PHAT_KHONG_HUY_DUOC':
      return l10n.loiDaXuatPhatKhongHuyDuoc;
    case 'THIEU_MO_TA_LY_DO':
      return l10n.loiThieuMoTaLyDo;
    case 'TRANG_THAI_KHONG_HOP_LE':
      return l10n.loiTrangThaiKhongHopLe;
    case 'THIEU_NGAY_TRA':
      return l10n.loiThieuNgayTra;
    case 'KHOANG_KHONG_HOP_LE':
      return l10n.loiKhoangKhongHopLe;
    case 'THIEU_THOI_LUONG':
      return l10n.loiThieuThoiLuong;
    case 'KHONG_SINH_DUOC_MA_DON':
      return l10n.loiKhongSinhDuocMaDon;
    case 'SAI_LOAI_DICH_VU':
      return l10n.loiSaiLoaiDichVuXuatPhat;
    case 'THIEU_MOC_GIO':
      return l10n.loiThieuMocGio;
    case 'DA_XUAT_PHAT':
      return l10n.loiDaXuatPhat;
    case 'NGAY_TRA_KHONG_HOP_LE':
      return l10n.loiNgayTraKhongHopLe;
    case 'KHONG_TU_DAT_CHINH_MINH':
      return l10n.loiKhongTuDatChinhMinh;
    case 'THIEU_CAU_HINH_CONG':
      return l10n.loiThieuCauHinhCong;
    case 'CHU_KY_KHONG_HOP_LE':
      return l10n.loiChuKyKhongHopLe;
    case 'KHONG_TIM_THAY_GIAO_DICH':
      return l10n.loiKhongTimThayGiaoDich;
    case 'KHONG_BAT_CONG_GIA_LAP':
      return l10n.loiKhongBatCongGiaLap;
    case 'DON_KHONG_CHO_THANH_TOAN':
      return l10n.loiDonKhongChoThanhToan;
    case 'HET_HAN_GIU_CHO':
      return l10n.loiHetHanGiuCho;
    case 'SO_TIEN_KHONG_HOP_LE':
      return l10n.loiSoTienKhongHopLe;
  }
  return messageFromError(error) ?? l10n.loiKetNoiMayChu;
}
