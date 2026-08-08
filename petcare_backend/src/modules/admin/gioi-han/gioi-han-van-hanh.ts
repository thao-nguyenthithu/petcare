import {
  CANH_DAI_DU_NET_PX,
  HAN_CHO_GOI_AI_MS,
  NGUONG_TIN_CAY_DAT,
  NGUONG_TIN_CAY_TU_XAC_NHAN,
  SO_LAN_GOI_TOI_DA_MOI_DON,
  SO_LAN_QUET_MOI_BE,
  SO_LUOT_CHUP_MOI_BE,
  TRAN_ANH_GUI_AI_BYTE,
} from '../../ai/ai.constants';
import { MOI_LUOT as DON_MOI_LUOT_TU_CHOT } from '../../bookings/auto-complete.job';
import {
  ARRIVE_GEOFENCE_METERS,
  DEPART_WINDOW_MINUTES,
  GEAR_WAIT,
  HAN_PHAN_DOI_HOURS,
  NO_SHOW_WAIT,
  PHUT_TU_HUY_KHONG_AI_BAT_DAU,
  START_WINDOW_MINUTES,
} from '../../bookings/booking-compensation';
import { MOI_LUOT as DON_MOI_LUOT_QUET } from '../../bookings/booking-sweep.job';
import {
  BAC_NGAY_TAM_AN,
  CANH_CAO_BAT_DAU_NHAC,
  GIO_SUPPORT_SOAT,
  SO_LAN_TAM_AN_KHOA,
  THANG_DEM_LAN_TAM_AN,
} from '../../bookings/sitter-penalty-rules';
import {
  DIEM_MOI_LAN_GUI,
  NGUONG_LECH_KM,
  NGUONG_LECH_TY_LE,
  NGUONG_NOISE_KMH,
  NGUONG_TOC_DO_TB_KMH,
  PHUT_AN_HAN_FLUSH_CUOI,
  TRAN_WAYPOINT_MOI_BATCH,
} from '../../gps/gps.constants';
import { MOI_LUOT as MUI_MOI_LUOT_NHAC } from '../../pets/prevention-reminder.job';
import {
  DIEM_DANH_GIA_TOI_THIEU,
  DON_HOAN_THANH_TOI_THIEU,
  TY_LE_HUY_TOI_DA,
} from '../../search/sitter-trusted';
import {
  TRAN_NGAY_DA_CHINH,
  TRAN_NGAY_MOT_DON,
  TRAN_NGAY_NGHI,
  TRAN_NGAY_XEM,
  TRAN_DON_XEM,
} from '../../sitter/schedule/schedule-shared';
import {
  GROOMING_PHUT_TOI_DA,
  GROOMING_PHUT_TOI_THIEU,
  WALKING_DURATIONS,
} from '../../sitter/services/sitter-services.service';
import { PHI_CHUYEN, TIEN_TO_MA } from '../../wallet/wallet.constants';
import { SO_ANH_BANG_CHUNG } from '../../sitter/orders/sitter-order-store.service';
import { TRAN_TIN_TRA_SOAT } from '../bookings/admin-booking-conversation.service';
import { TRAN_DIEM_TRA_SOAT } from '../bookings/tra-soat-gps';
import { MOI_TRANG_MAC_DINH, TRAN_MOI_TRANG } from '../chung/phan-trang';
import {
  day,
  mb,
  msRaGiay,
  phanTram,
  so,
  type NhomGioiHan,
} from './gioi-han.types';

export function nhomVanHanh(): NhomGioiHan[] {
  return [
    {
      key: 'mocPhien',
      cot: 'phai',
      coDongDaChuyen: true,
      items: [
        {
          ma: 'mocPhien.cuaSoMoNutXuatPhat',
          value: so(DEPART_WINDOW_MINUTES),
          unit: 'phut',
        },
        {
          ma: 'mocPhien.moNutBatDauTruocGioHen',
          value: so(START_WINDOW_MINUTES),
          unit: 'phut',
        },
        {
          ma: 'mocPhien.banKinhGeofenceDiemHen',
          value: so(ARRIVE_GEOFENCE_METERS),
          unit: 'met',
        },
        {
          ma: 'mocPhien.choTruocKhiBaoChuNuoiVangMat',
          value: so(NO_SHOW_WAIT),
          unit: 'phut',
        },
        {
          ma: 'mocPhien.choChuNuoiLayRoMomDayXich',
          value: so(GEAR_WAIT),
          unit: 'phut',
        },
        {
          ma: 'mocPhien.heThongTuKhepDonKhongAiBatDau',
          value: so(PHUT_TU_HUY_KHONG_AI_BAT_DAU),
          unit: 'phut',
        },
        {
          ma: 'mocPhien.hanChuNuoiPhanDoiKhiBiBaoVangMat',
          value: so(HAN_PHAN_DOI_HOURS),
          unit: 'gio',
        },
      ],
    },
    {
      key: 'kyLuat',
      cot: 'phai',
      coDongDaChuyen: true,
      items: [
        {
          ma: 'kyLuat.thoiGianTamAnHoSo',
          value: day(BAC_NGAY_TAM_AN),
          unit: 'ngay',
        },
        {
          ma: 'kyLuat.soLanTamAnThiKhoaHan',
          value: so(SO_LAN_TAM_AN_KHOA),
          unit: 'lan',
        },
        {
          ma: 'kyLuat.cuaSoDemSoLanTamAn',
          value: so(THANG_DEM_LAN_TAM_AN),
          unit: 'thang',
        },
        {
          ma: 'kyLuat.hanDoiHoTroSoatDonDungGiuaDuong',
          value: so(GIO_SUPPORT_SOAT),
          unit: 'gio',
        },
        {
          ma: 'kyLuat.nhacNguoiChamTuCanhCaoThu',
          value: so(CANH_CAO_BAT_DAU_NHAC),
          unit: '',
        },
        {
          ma: 'kyLuat.anhBatBuocKhiBoDonGiuaDuong',
          value: `1 - ${so(SO_ANH_BANG_CHUNG)}`,
          unit: 'anh',
        },
      ],
    },
    {
      key: 'gps',
      cot: 'phai',
      items: [
        {
          ma: 'gps.soDiemGomMoiLanGui',
          value: so(DIEM_MOI_LAN_GUI),
          unit: 'diem',
        },
        {
          ma: 'gps.diemToiDaMayChuNhanMoiLanGui',
          value: so(TRAN_WAYPOINT_MOI_BATCH),
          unit: 'diem',
        },
        {
          ma: 'gps.nguongNhieuTocDo',
          value: so(NGUONG_NOISE_KMH),
          unit: 'kmGio',
        },
        {
          ma: 'gps.nguongTocDoTrungBinhCaLuot',
          value: so(NGUONG_TOC_DO_TB_KMH),
          unit: 'kmGio',
        },
        {
          ma: 'gps.anHanNhanGoiCuoi',
          value: so(PHUT_AN_HAN_FLUSH_CUOI),
          unit: 'phut',
        },
        {
          ma: 'gps.nguongLechQuangDuong',
          value: so(NGUONG_LECH_KM),
          unit: 'km',
        },
        {
          ma: 'gps.nguongLechTheoTyLe',
          value: phanTram(NGUONG_LECH_TY_LE),
          unit: 'phanTram',
        },
      ],
    },
    {
      key: 'aiAnh',
      cot: 'phai',
      coDongDaChuyen: true,
      items: [
        {
          ma: 'aiAnh.soLanQuetMoiBe',
          value: so(SO_LAN_QUET_MOI_BE),
          unit: 'lan',
        },
        {
          ma: 'aiAnh.soLuotChupMoiBeKeCaLanDau',
          value: so(SO_LUOT_CHUP_MOI_BE),
          unit: 'luot',
        },
        {
          ma: 'aiAnh.soLanGoiToiDaMotDon',
          value: so(SO_LAN_GOI_TOI_DA_MOI_DON),
          unit: 'lan',
        },
        {
          ma: 'aiAnh.canhDaiAnhCoiLaDuNet',
          value: so(CANH_DAI_DU_NET_PX),
          unit: 'px',
        },
        {
          ma: 'aiAnh.nguongTinCayCoiLaDat',
          value: so(NGUONG_TIN_CAY_DAT),
          unit: '',
        },
        {
          ma: 'aiAnh.nguongTinCayNguoiChamTuXacNhan',
          value: so(NGUONG_TIN_CAY_TU_XAC_NHAN),
          unit: '',
        },
        {
          ma: 'aiAnh.dungLuongToiDaAnhGuiDiQuet',
          value: mb(TRAN_ANH_GUI_AI_BYTE),
          unit: 'mb',
        },
        {
          ma: 'aiAnh.hanChoMotLuotGoi',
          value: msRaGiay(HAN_CHO_GOI_AI_MS),
          unit: 'giay',
        },
      ],
    },
    {
      key: 'dichVuLich',
      cot: 'phai',
      coDongDaChuyen: true,
      items: [
        {
          ma: 'dichVuLich.thoiLuongMotLuotDat',
          value: day(WALKING_DURATIONS),
          unit: 'phut',
        },
        {
          ma: 'dichVuLich.thoiLuongTamVaCatTia',
          value: `${so(GROOMING_PHUT_TOI_THIEU)} - ${so(GROOMING_PHUT_TOI_DA)}`,
          unit: 'phut',
        },
        {
          ma: 'dichVuLich.khoangNgayMoiLanHoiLich',
          value: so(TRAN_NGAY_XEM),
          unit: 'ngay',
        },
        {
          ma: 'dichVuLich.doDaiMotLanDatNghi',
          value: so(TRAN_NGAY_NGHI),
          unit: 'ngay',
        },
        {
          ma: 'dichVuLich.soNgayCaiRiengMoiNguoiCham',
          value: so(TRAN_NGAY_DA_CHINH),
          unit: 'ngay',
        },
        {
          ma: 'dichVuLich.donDocToiDaMoiLuotDungLich',
          value: so(TRAN_DON_XEM),
          unit: 'don',
        },
        {
          ma: 'dichVuLich.soONgayToiDaMotDonTo',
          value: so(TRAN_NGAY_MOT_DON),
          unit: 'ngay',
        },
        {
          ma: 'dichVuLich.huyHieuSoDonHoanThanhToiThieu',
          value: so(DON_HOAN_THANH_TOI_THIEU),
          unit: 'don',
        },
        {
          ma: 'dichVuLich.huyHieuDiemDanhGiaToiThieu',
          value: so(DIEM_DANH_GIA_TOI_THIEU),
          unit: 'sao',
        },
        {
          ma: 'dichVuLich.huyHieuTyLeHuyToiDa',
          value: phanTram(TY_LE_HUY_TOI_DA),
          unit: 'phanTram',
        },
      ],
    },
    {
      key: 'hienThi',
      cot: 'phai',
      items: [
        {
          ma: 'hienThi.dongMoiTrangMacDinh',
          value: so(MOI_TRANG_MAC_DINH),
          unit: 'dong',
        },
        {
          ma: 'hienThi.tranDongMoiTrang',
          value: so(TRAN_MOI_TRANG),
          unit: 'dong',
        },
        {
          ma: 'hienThi.hoiThoaiMotDonOManTraSoat',
          value: so(TRAN_TIN_TRA_SOAT),
          unit: 'tin',
        },
        {
          ma: 'hienThi.diemLoTrinhMotDonOManTraSoat',
          value: so(TRAN_DIEM_TRA_SOAT),
          unit: 'diem',
        },
      ],
    },
    {
      key: 'viVaViecChay',
      cot: 'phai',
      coDongDaChuyen: true,
      items: [
        {
          ma: 'viVaViecChay.phiChuyenKhiRut',
          value: so(PHI_CHUYEN),
          unit: 'dong2',
        },
        {
          ma: 'viVaViecChay.tienToMaGiaoDichVi',
          value: Object.values(TIEN_TO_MA).join(' · '),
          unit: '',
        },
        {
          ma: 'viVaViecChay.donXuLyMoiLuotQuetQuaHan',
          value: so(DON_MOI_LUOT_QUET),
          unit: 'don',
        },
        {
          ma: 'viVaViecChay.donXuLyMoiLuotTuChot',
          value: so(DON_MOI_LUOT_TU_CHOT),
          unit: 'don',
        },
        {
          ma: 'viVaViecChay.muiNhacXuLyMoiLuot',
          value: so(MUI_MOI_LUOT_NHAC),
          unit: 'mui',
        },
      ],
    },
    {
      key: 'chuaCo',
      cot: 'phai',
      chuaCoTrongCode: true,
      items: [
        {
          ma: 'chuaCo.soDiaChiToiDaMoiTaiKhoan',
          value: '',
          unit: '',
        },
        {
          ma: 'chuaCo.thoiGianLuuAnhBangChung',
          value: '',
          unit: '',
        },
        {
          ma: 'chuaCo.hoaHongRiengTheoDichVu',
          value: '',
          unit: '',
        },
        {
          ma: 'chuaCo.bangLenhHoanTienRieng',
          value: '',
          unit: '',
        },
      ],
    },
  ];
}
