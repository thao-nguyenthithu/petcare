import {
  KHOA_DANG_NHAP_PHUT,
  MAT_KHAU_TOI_THIEU,
  OTP_MOI_GIO,
  SAI_MAT_KHAU_TOI_DA,
} from '../../auth/auth.constants';
import {
  LOCK_SECONDS,
  MAX_ATTEMPTS,
  OTP_TTL_SECONDS,
  RESEND_COOLDOWN_SECONDS,
  RESET_TOKEN_TTL_SECONDS,
} from '../../auth/otp.service';
import {
  DEM_KY_DAI,
  DEM_TINH_PHI_TOI_DA,
  GIO_HUY_MIEN_PHI_VN,
  LATE_BOOK_GRACE_MINUTES,
  NGAY_LUI_KY_DAI,
  NGAY_LUI_MAC_DINH,
  PHUT_QUA_HEN_NCC,
  PHUT_TU_HUY_NCC_CHUA_TOI,
} from '../../bookings/booking-cancel';
import {
  TRAN_BE_WALKING,
  TRAN_PHUT_GROOMING,
} from '../../bookings/booking-pricing';
import {
  DEM_TAN_NOI_MINUTES,
  DEM_WALKING_MINUTES,
  MAX_ADVANCE_DAYS,
  MIN_LEAD_MINUTES,
  PHUT_GIU_CHO_TRA_TIEN,
  SLOT_STEP_MINUTES,
  TRAN_DEM_MOT_DON,
  hanNhanDonPhut,
} from '../../bookings/booking-time';
import { TRAN_DON_CHO_MOI_CHU } from '../../bookings/booking-write.service';
import { GIOI_HAN_ANH_BYTE, TRAN_TEP_MOI_LUOT } from '../../media/image-upload';
import { SO_ANH_MOI_LUOT } from '../../messaging/chat-photo.service';
import { TRANG_TIN } from '../../messaging/messaging.service';
import { TRAN_MOI_TRANG as THONG_BAO_MOI_TRANG } from '../../notifications/notifications.service';
import { CAN_NANG_TOI_DA, TUOI_BE_TOI_DA } from '../../pets/dto/create-pet.dto';
import { CHU_KY_NGAY_TOI_DA } from '../../pets/dto/create-prevention.dto';
import { MOC_NHAC } from '../../pets/prevention-reminder.job';
import {
  MAX_DOSE_PHOTOS,
  MAX_HANG_MUC_MOI_BE,
  MAX_LAN_MOI_HANG_MUC,
  SO_NAM_LUI_TOI_DA,
} from '../../pets/preventions.service';
import { MAX_PET_MOI_CHU, MAX_PET_PHOTOS } from '../../pets/pets.service';
import { SO_ANH_DANH_GIA } from '../../reviews/dto/create-review.dto';
import { NGAY_DUOC_PHAN_HOI } from '../../reviews/review-select';
import {
  NGAY_DUOC_DANH_GIA,
  TRAN_MOI_TRANG as DANH_GIA_MOI_TRANG,
} from '../../reviews/reviews.service';
import { MAX_PHOTOS as ANH_HO_SO_NCC } from '../../sitter/me/sitter-me.service';
import {
  SO_ANH_BANG_CHUNG,
  SO_ANH_DO_DUNG,
  SO_ANH_GIUA_PHIEN,
} from '../../sitter/orders/sitter-order-store.service';
import { TUOI_TOI_THIEU_NCC } from '../../sitter/profile/sitter-profile.service';
import { SO_ANH_MO_KHIEU_NAI } from '../../wallet/dto/wallet.dto';
import {
  day,
  giayRaPhut,
  mb,
  phutRaGio,
  so,
  type MucGioiHan,
  type NhomGioiHan,
} from './gioi-han.types';

// Bốn bậc hạn trả lời lấy bằng cách GỌI hàm thật, không chép lại bốn con số
const MOT_GIO_PHUT = 60;
const BAC_HAN_TRA_LOI = [
  hanNhanDonPhut(0),
  hanNhanDonPhut(7 * MOT_GIO_PHUT),
  hanNhanDonPhut(48 * MOT_GIO_PHUT),
  hanNhanDonPhut(30 * 24 * MOT_GIO_PHUT),
];

// Dạng lạ thì giữ nguyên chuỗi để người đọc thấy cấu hình đang sai
function hanPhien(tho: string): MucGioiHan {
  const khop = /^(\d+)d$/.exec(tho);
  return {
    ma: 'taiKhoan.phienDangNhap',
    value: khop ? so(Number(khop[1])) : tho,
    unit: khop ? 'ngay' : '',
  };
}

export function nhomNenTang(hanPhienTho: string): NhomGioiHan[] {
  return [
    {
      key: 'taiKhoan',
      cot: 'trai',
      items: [
        {
          ma: 'taiKhoan.matKhauToiThieu',
          value: so(MAT_KHAU_TOI_THIEU),
          unit: 'kyTu',
        },
        {
          ma: 'taiKhoan.hanDungMaXacMinh',
          value: giayRaPhut(OTP_TTL_SECONDS),
          unit: 'phut',
        },
        {
          ma: 'taiKhoan.soLanNhapSaiMaToiDa',
          value: so(MAX_ATTEMPTS),
          unit: 'lan',
        },
        {
          ma: 'taiKhoan.thoiGianKhoaONhapMa',
          value: giayRaPhut(LOCK_SECONDS),
          unit: 'phut',
        },
        {
          ma: 'taiKhoan.choGiuaHaiLanGuiLaiMa',
          value: so(RESEND_COOLDOWN_SECONDS),
          unit: 'giay',
        },
        {
          ma: 'taiKhoan.soMaGuiChoMotEmailMoiGio',
          value: so(OTP_MOI_GIO),
          unit: 'ma',
        },
        {
          ma: 'taiKhoan.soLanDangNhapSaiMatKhau',
          value: so(SAI_MAT_KHAU_TOI_DA),
          unit: 'lan',
        },
        {
          ma: 'taiKhoan.thoiGianKhoaDangNhap',
          value: so(KHOA_DANG_NHAP_PHUT),
          unit: 'phut',
        },
        {
          ma: 'taiKhoan.thoiGianDatMatKhauMoi',
          value: giayRaPhut(RESET_TOKEN_TTL_SECONDS),
          unit: 'phut',
        },
        hanPhien(hanPhienTho),
        {
          ma: 'taiKhoan.tuoiToiThieuDangKyNguoiCham',
          value: so(TUOI_TOI_THIEU_NCC),
          unit: 'tuoi',
        },
        {
          ma: 'taiKhoan.dungLuongToiDaMoiAnh',
          value: mb(GIOI_HAN_ANH_BYTE),
          unit: 'mb',
        },
        {
          ma: 'taiKhoan.anhThuVienHoSoNguoiCham',
          value: so(ANH_HO_SO_NCC),
          unit: 'anh',
        },
      ],
    },
    {
      key: 'thuCung',
      cot: 'trai',
      items: [
        {
          ma: 'thuCung.soBeToiDaMoiTaiKhoan',
          value: so(MAX_PET_MOI_CHU),
          unit: 'be',
        },
        {
          ma: 'thuCung.soAnhToiDaMoiBe',
          value: so(MAX_PET_PHOTOS),
          unit: 'anh',
        },
        {
          ma: 'thuCung.canNangNhapToiDa',
          value: so(CAN_NANG_TOI_DA),
          unit: 'kg',
        },
        {
          ma: 'thuCung.tuoiBeNhapDuoc',
          value: so(TUOI_BE_TOI_DA),
          unit: 'tuoi',
        },
        {
          ma: 'thuCung.hangMucPhongBenhMoiBe',
          value: so(MAX_HANG_MUC_MOI_BE),
          unit: 'muc',
        },
        {
          ma: 'thuCung.soLanGhiMoiHangMuc',
          value: so(MAX_LAN_MOI_HANG_MUC),
          unit: 'lan',
        },
        {
          ma: 'thuCung.anhPhieuMoiLanGhi',
          value: so(MAX_DOSE_PHOTOS),
          unit: 'anh',
        },
        {
          ma: 'thuCung.chuKyNhacLai',
          value: `1 - ${so(CHU_KY_NGAY_TOI_DA)}`,
          unit: 'ngay',
        },
        {
          ma: 'thuCung.nhacTruocHanPhongBenh',
          value: day(MOC_NHAC),
          unit: 'ngay',
        },
        {
          ma: 'thuCung.soNamLuiKhiNhapMuiCu',
          value: so(SO_NAM_LUI_TOI_DA),
          unit: 'nam',
        },
      ],
    },
    {
      key: 'datLich',
      cot: 'trai',
      items: [
        {
          ma: 'datLich.datTruocToiThieu',
          value: so(MIN_LEAD_MINUTES),
          unit: 'phut',
        },
        {
          ma: 'datLich.datTruocToiDa',
          value: so(MAX_ADVANCE_DAYS),
          unit: 'ngay',
        },
        {
          ma: 'datLich.buocSinhKhungGio',
          value: so(SLOT_STEP_MINUTES),
          unit: 'phut',
        },
        {
          ma: 'datLich.demGiuaHaiDonLienNhau',
          value: day([DEM_WALKING_MINUTES, DEM_TAN_NOI_MINUTES]),
          unit: 'phut',
        },
        {
          ma: 'datLich.soDemToiDaMotDonTrongGiu',
          value: so(TRAN_DEM_MOT_DON),
          unit: 'dem',
        },
        {
          ma: 'datLich.soBeToiDaMotDonDat',
          value: so(TRAN_BE_WALKING),
          unit: 'be',
        },
        {
          ma: 'datLich.tranThoiLuongMotDonTamVaCatTia',
          value: phutRaGio(TRAN_PHUT_GROOMING),
          unit: 'gio',
        },
        {
          ma: 'datLich.donChuaNgaNguMoiChuNuoi',
          value: so(TRAN_DON_CHO_MOI_CHU),
          unit: 'don',
        },
        {
          ma: 'datLich.hanNguoiChamTraLoi',
          value: day(BAC_HAN_TRA_LOI),
          unit: 'phut',
        },
        {
          ma: 'datLich.hanGiuChoChoTraTien',
          value: so(PHUT_GIU_CHO_TRA_TIEN),
          unit: 'phut',
        },
      ],
    },
    {
      key: 'huyDon',
      cot: 'trai',
      coDongDaChuyen: true,
      items: [
        {
          ma: 'huyDon.mocHuyMienPhiTrongNgay',
          value: GIO_HUY_MIEN_PHI_VN,
          unit: 'gioVn',
        },
        {
          ma: 'huyDon.soNgayLuiMocDonThuong',
          value: so(NGAY_LUI_MAC_DINH),
          unit: 'ngay',
        },
        {
          ma: 'huyDon.soNgayLuiMocKyTrongGiuDai',
          value: so(NGAY_LUI_KY_DAI),
          unit: 'ngay',
        },
        {
          ma: 'huyDon.soDemDeTinhLaKyDai',
          value: so(DEM_KY_DAI),
          unit: 'dem',
        },
        {
          ma: 'huyDon.soDemBiTinhPhiToiDa',
          value: so(DEM_TINH_PHI_TOI_DA),
          unit: 'dem',
        },
        {
          ma: 'huyDon.anHanHuy0DongCuaDonDatGap',
          value: so(LATE_BOOK_GRACE_MINUTES),
          unit: 'phut',
        },
        {
          ma: 'huyDon.quaGioHenMaNguoiChamChuaToi',
          value: so(PHUT_QUA_HEN_NCC),
          unit: 'phut',
        },
        {
          ma: 'huyDon.heThongTuHuyDonNguoiChamChuaToi',
          value: so(PHUT_TU_HUY_NCC_CHUA_TOI),
          unit: 'phut',
        },
      ],
    },
    {
      key: 'anhPhien',
      cot: 'trai',
      items: [
        {
          ma: 'anhPhien.tepToiDaMoiLuotTaiLen',
          value: so(TRAN_TEP_MOI_LUOT),
          unit: 'tep',
        },
        {
          ma: 'anhPhien.anhGiuaPhien',
          value: so(SO_ANH_GIUA_PHIEN),
          unit: 'anh',
        },
        {
          ma: 'anhPhien.anhDoDungGuiKemVaTraLai',
          value: so(SO_ANH_DO_DUNG),
          unit: 'anh',
        },
        {
          ma: 'anhPhien.anhBangChungNhanhBatThuong',
          value: `1 - ${so(SO_ANH_BANG_CHUNG)}`,
          unit: 'anh',
        },
        {
          ma: 'anhPhien.anhKemKhiMoHoSoKhieuNai',
          value: so(SO_ANH_MO_KHIEU_NAI),
          unit: 'anh',
        },
      ],
    },
    {
      key: 'danhGiaChat',
      cot: 'trai',
      coDongDaChuyen: true,
      items: [
        {
          ma: 'danhGiaChat.hanChuNuoiGuiDanhGia',
          value: so(NGAY_DUOC_DANH_GIA),
          unit: 'ngay',
        },
        {
          ma: 'danhGiaChat.hanNguoiChamDapDanhGia',
          value: so(NGAY_DUOC_PHAN_HOI),
          unit: 'ngay',
        },
        {
          ma: 'danhGiaChat.anhToiDaMoiDanhGia',
          value: so(SO_ANH_DANH_GIA),
          unit: 'anh',
        },
        {
          ma: 'danhGiaChat.danhGiaMoiLanTai',
          value: so(DANH_GIA_MOI_TRANG),
          unit: 'muc',
        },
        {
          ma: 'danhGiaChat.tinNhanMoiLanTai',
          value: so(TRANG_TIN),
          unit: 'tin',
        },
        {
          ma: 'danhGiaChat.thongBaoMoiLanTai',
          value: so(THONG_BAO_MOI_TRANG),
          unit: 'muc',
        },
        {
          ma: 'danhGiaChat.anhToiDaMoiLuotGuiChat',
          value: so(SO_ANH_MOI_LUOT),
          unit: 'anh',
        },
      ],
    },
  ];
}
