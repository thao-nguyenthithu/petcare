import {
  phanChiaPhiHuy,
  phiHuyCuaDon,
} from '../src/modules/bookings/booking-cancel';
import {
  DEPART_WINDOW_MINUTES,
  GEAR_WAIT,
  HAN_PHAN_DOI_HOURS,
  NO_SHOW_WAIT,
  START_WINDOW_MINUTES,
} from '../src/modules/bookings/booking-compensation';
import { chuyenDuoc, daKhepLai } from '../src/modules/bookings/booking-state';
import {
  BAC_NGAY_TAM_AN,
  SO_LAN_TAM_AN_KHOA,
  mucPhat,
  ngayTamAn,
} from '../src/modules/bookings/sitter-penalty-rules';
import {
  CANH_CAO_TAM_AN,
  GIO_GIU_TIEN,
  NEN_TANG,
  NGAY_CUA_SO,
  PHI_HUY,
} from './tham-so-mac-dinh';

// Luật phía người chăm (bộ luật mục 5 và 6); đổi một hằng số là các test này đổ

describe('máy trạng thái đơn', () => {
  it('không nhảy bậc: chưa nhận đơn thì không vào phiên được', () => {
    expect(chuyenDuoc('PENDING', 'IN_PROGRESS')).toBe(false);
    expect(chuyenDuoc('PENDING', 'CONFIRMED')).toBe(true);
  });

  it('kỳ trông giữ chốt thẳng COMPLETED, hai dịch vụ kia qua bước chờ chốt', () => {
    expect(chuyenDuoc('IN_PROGRESS', 'COMPLETED')).toBe(true);
    expect(chuyenDuoc('IN_PROGRESS', 'AWAITING_OWNER_CONFIRM')).toBe(true);
    expect(chuyenDuoc('AWAITING_OWNER_CONFIRM', 'COMPLETED')).toBe(true);
  });

  it('đơn đã bắt đầu thì không còn đường huỷ', () => {
    expect(chuyenDuoc('IN_PROGRESS', 'CANCELLED_BY_SITTER')).toBe(false);
    expect(chuyenDuoc('IN_PROGRESS', 'CANCELLED_BY_OWNER')).toBe(false);
  });

  it('vắng mặt chỉ xảy ra khi đơn đã được nhận', () => {
    expect(chuyenDuoc('CONFIRMED', 'CANCELLED_NO_SHOW')).toBe(true);
    expect(chuyenDuoc('PENDING', 'CANCELLED_NO_SHOW')).toBe(false);
  });

  it('bốn kết cục huỷ là điểm cuối', () => {
    expect(daKhepLai('CANCELLED_BY_OWNER')).toBe(true);
    expect(daKhepLai('CANCELLED_BY_SITTER')).toBe(true);
    expect(daKhepLai('CANCELLED_EXPIRED')).toBe(true);
    expect(daKhepLai('CANCELLED_NO_SHOW')).toBe(true);
    expect(daKhepLai('CONFIRMED')).toBe(false);
  });
});

// Ranh giới là đã bấm Xuất phát hay chưa, KHÔNG có mốc 24 giờ (bộ luật mục 6)
describe('thang ba mức khi người chăm bỏ đơn đã nhận', () => {
  it('mức 1: chưa xuất phát thì chỉ cộng tỷ lệ huỷ, dù còn bao nhiêu giờ', () => {
    expect(mucPhat('huyChuaXuatPhat')).toEqual({
      tinhTyLeHuy: true,
      canhCao: false,
      treoChoSoat: false,
    });
  });

  it('mức 2: đã xuất phát thì LUÔN treo chờ đội hỗ trợ soát', () => {
    expect(mucPhat('daXuatPhat')).toEqual({
      tinhTyLeHuy: true,
      canhCao: true,
      treoChoSoat: true,
    });
  });

  it('mức 3: im lặng bỏ đơn thì áp thẳng, không qua soát', () => {
    expect(mucPhat('imLang')).toEqual({
      tinhTyLeHuy: true,
      canhCao: true,
      treoChoSoat: false,
    });
  });

  it('cảnh cáo CHỈ sinh ở mức 2 và 3', () => {
    expect(mucPhat('huyChuaXuatPhat').canhCao).toBe(false);
    expect(mucPhat('daXuatPhat').canhCao).toBe(true);
    expect(mucPhat('imLang').canhCao).toBe(true);
  });
});

describe('ngưỡng ẩn hồ sơ', () => {
  it('bốn cảnh cáo trong cửa sổ 90 ngày', () => {
    expect(CANH_CAO_TAM_AN).toBe(4);
    expect(NGAY_CUA_SO).toBe(90);
  });

  it('tạm ẩn theo bậc 3, 7, 14 ngày rồi giữ mức nặng nhất', () => {
    expect(BAC_NGAY_TAM_AN).toEqual([3, 7, 14]);
    expect(ngayTamAn(1)).toBe(3);
    expect(ngayTamAn(2)).toBe(7);
    expect(ngayTamAn(3)).toBe(14);
    expect(ngayTamAn(9)).toBe(14);
  });

  it('khoá hẳn ở lần tạm ẩn thứ tư, để nấc 14 ngày có chỗ dùng', () => {
    expect(SO_LAN_TAM_AN_KHOA).toBe(4);
  });
});

// Mọi nhánh khép đơn bất thường dùng CHUNG công thức phí huỷ (bộ luật mục 5)
describe('tiền của nhánh khép đơn bất thường', () => {
  it('thiếu dụng cụ tính đúng 50% giá đơn, không phụ thuộc khoảng cách', () => {
    expect(phiHuyCuaDon('walking', 150000, 0, PHI_HUY)).toBe(75000);
    expect(phiHuyCuaDon('walking', 40000, 0, PHI_HUY)).toBe(20000);
  });

  it('người chăm nhận 85% của phí huỷ, phần còn lại là phí nền tảng', () => {
    expect(phanChiaPhiHuy(75000, NEN_TANG)).toEqual({
      nccNhan: 63750,
      nenTang: 11250,
    });
  });

  it('đúng hai mốc chờ của luật', () => {
    expect(NO_SHOW_WAIT).toBe(15);
    expect(GEAR_WAIT).toBe(10);
  });

  it('cửa sổ xuất phát 2 giờ, nút bắt đầu 15 phút', () => {
    expect(DEPART_WINDOW_MINUTES).toBe(120);
    expect(START_WINDOW_MINUTES).toBe(15);
  });

  it('hạn phản đối NGẮN HƠN mốc nhả tiền để không chạy đua với công việc nền', () => {
    expect(HAN_PHAN_DOI_HOURS).toBe(24);
    expect(GIO_GIU_TIEN).toBe(48);
    expect(HAN_PHAN_DOI_HOURS).toBeLessThan(GIO_GIU_TIEN);
  });
});
