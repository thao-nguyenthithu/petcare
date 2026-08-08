import { mocVn } from '../src/common/thoi-gian-vn';
import {
  DonXetHuy,
  PHUT_QUA_HEN_NCC,
  hanHuyMienPhiAt,
  laDatGap,
  mocTuHuyNccChuaToi,
  phanChiaPhiHuy,
  phiHuyCuaDon,
  xetMienPhi,
} from '../src/modules/bookings/booking-cancel';
import { tinhKetThucSom } from '../src/modules/bookings/booking-pricing';
import { NEN_TANG, PHI_HUY } from './tham-so-mac-dinh';

// Chính sách huỷ (bộ luật mục 3 và 4); đổi một hằng số là các test này đổ

function don(p: Partial<DonXetHuy> = {}): DonXetHuy {
  return {
    loai: 'walking',
    batDau: mocVn('2026-07-23', '08:00'),
    soDem: 0,
    tongTien: 150000,
    dangCho: false,
    taoLuc: mocVn('2026-07-20', '09:00'),
    acceptedAt: mocVn('2026-07-20', '09:05'),
    arrivedAt: null,
    departedAt: null,
    ...p,
  };
}

describe('mốc huỷ miễn phí', () => {
  it('dắt và grooming: 12:00 trưa ngày hôm trước', () => {
    const han = hanHuyMienPhiAt('walking', mocVn('2026-07-23', '08:00'), 0);
    expect(han.toISOString()).toBe(mocVn('2026-07-22', '12:00').toISOString());
  });

  it('trông giữ tối đa 7 đêm: vẫn lùi 1 ngày', () => {
    const han = hanHuyMienPhiAt('boarding', mocVn('2026-07-25', '08:00'), 7);
    expect(han.toISOString()).toBe(mocVn('2026-07-24', '12:00').toISOString());
  });

  it('trông giữ trên 7 đêm: lùi 7 ngày', () => {
    const han = hanHuyMienPhiAt('boarding', mocVn('2026-07-25', '08:00'), 8);
    expect(han.toISOString()).toBe(mocVn('2026-07-18', '12:00').toISOString());
  });

  it('đơn đặt sau mốc là đơn đặt gấp', () => {
    const han = hanHuyMienPhiAt('walking', mocVn('2026-07-23', '08:00'), 0);
    expect(laDatGap(mocVn('2026-07-22', '18:00'), han)).toBe(true);
    expect(laDatGap(mocVn('2026-07-22', '09:00'), han)).toBe(false);
  });
});

describe('bất biến 3 — đơn PENDING không bao giờ tính phí huỷ', () => {
  it('còn chờ người chăm nhận thì miễn phí kể cả đã quá mốc', () => {
    const xet = xetMienPhi(
      don({ dangCho: true, acceptedAt: null }),
      mocVn('2026-07-23', '07:00').getTime(),
    );
    expect(xet.mienPhi).toBe(true);
  });
});

describe('cửa miễn phí của đơn đã nhận', () => {
  it('huỷ trước mốc thì 0đ', () => {
    const xet = xetMienPhi(don(), mocVn('2026-07-22', '11:59').getTime());
    expect(xet.mienPhi).toBe(true);
  });

  it('huỷ sau mốc thì mất phí', () => {
    const xet = xetMienPhi(don(), mocVn('2026-07-22', '12:01').getTime());
    expect(xet.mienPhi).toBe(false);
  });

  it('đơn đặt gấp: miễn phí trong 30 phút kể từ khi người chăm nhận', () => {
    const gap = don({
      taoLuc: mocVn('2026-07-22', '18:00'),
      acceptedAt: mocVn('2026-07-22', '18:10'),
    });
    expect(
      xetMienPhi(gap, mocVn('2026-07-22', '18:39').getTime()).mienPhi,
    ).toBe(true);
    expect(
      xetMienPhi(gap, mocVn('2026-07-22', '18:41').getTime()).mienPhi,
    ).toBe(false);
  });

  it('cửa 30 phút ĐÓNG khi người chăm đã bấm xuất phát', () => {
    const gap = don({
      taoLuc: mocVn('2026-07-22', '18:00'),
      acceptedAt: mocVn('2026-07-22', '18:10'),
      departedAt: mocVn('2026-07-22', '18:20'),
    });
    // Vẫn trong 30 phút kể từ lúc nhận, nhưng người chăm đã lên đường
    expect(
      xetMienPhi(gap, mocVn('2026-07-22', '18:25').getTime()).mienPhi,
    ).toBe(false);
  });

  it('ma trận dòng 16: quá hẹn 15 phút mà chưa tới nơi thì lỗi thuộc người chăm', () => {
    const xet = xetMienPhi(don(), mocVn('2026-07-23', '08:15').getTime());
    expect(xet.mienPhi).toBe(true);
    expect(xet.doNguoiCham).toBe(true);
  });

  it('trông giữ không có điểm đón nên không đi nhánh quá hẹn', () => {
    const xet = xetMienPhi(
      don({ loai: 'boarding', soDem: 3 }),
      mocVn('2026-07-23', '08:15').getTime(),
    );
    expect(xet.doNguoiCham).toBe(false);
  });
});

// Chủ nuôi được bấm từ phút 15 nhưng không bắt buộc, mốc này là lúc máy khép thay họ
describe('mốc hệ thống tự huỷ khi người chăm chưa tới', () => {
  const batDau = mocVn('2026-07-23', '08:00');

  it('chốt ở phút 30 kể từ giờ hẹn, không phụ thuộc đã xuất phát hay chưa', () => {
    expect(mocTuHuyNccChuaToi(batDau).getTime()).toBe(
      mocVn('2026-07-23', '08:30').getTime(),
    );
  });

  it('mốc tự huỷ luôn sau mốc chủ nuôi được bấm', () => {
    const duocBam = batDau.getTime() + PHUT_QUA_HEN_NCC * 60000;
    expect(mocTuHuyNccChuaToi(batDau).getTime()).toBeGreaterThan(duocBam);
  });
});

// Trông giữ đếm đêm rơi trong 7 ngày KỂ TỪ LÚC BẤM, không phải 7 đêm đầu kỳ (mục 3)
describe('phí huỷ muộn', () => {
  const batDau = mocVn('2026-07-23', '08:00');
  // Bấm huỷ ngay sát ngày bắt đầu
  const satNgay = mocVn('2026-07-23', '00:00').getTime();

  it('dắt: 50% giá đơn', () => {
    expect(phiHuyCuaDon('walking', 150000, 0, PHI_HUY)).toBe(75000);
  });

  it('trông giữ kỳ 3 đêm huỷ sát ngày: cả kỳ nằm trong 7 ngày nên mất 50%', () => {
    expect(phiHuyCuaDon('boarding', 540000, 3, PHI_HUY, batDau, satNgay)).toBe(
      270000,
    );
  });

  it('trông giữ kỳ 10 đêm huỷ sát ngày: chịu phí đúng 7 đêm', () => {
    // 10 đêm × 100.000đ, phí = 50% của 7 đêm rơi trong 7 ngày tới
    expect(
      phiHuyCuaDon('boarding', 1000000, 10, PHI_HUY, batDau, satNgay),
    ).toBe(350000);
  });

  it('cũng kỳ 10 đêm mà huỷ trước 4 ngày thì chỉ chịu phí 3 đêm', () => {
    const truoc4Ngay = mocVn('2026-07-19', '08:00').getTime();
    expect(
      phiHuyCuaDon('boarding', 1000000, 10, PHI_HUY, batDau, truoc4Ngay),
    ).toBe(150000);
  });
});

// Huỷ cả kỳ chính là trường hợp O bằng 0 của công thức kết thúc sớm
describe('kết thúc sớm giữa kỳ', () => {
  const batDau = mocVn('2026-07-23', '08:00');

  it('kỳ 20 đêm, bấm ở đêm thứ 2 để cắt từ đêm 12: không đêm nào chịu phí', () => {
    const bamLuc = mocVn('2026-07-25', '08:00').getTime();
    const kq = tinhKetThucSom(2000000, 20, PHI_HUY, batDau, 12, bamLuc);
    expect(kq.K).toBe(0);
    // Trả đủ 12 đêm đã ở, 8 đêm còn lại hoàn nguyên
    expect(kq.chuNuoiTra).toBe(1200000);
    expect(kq.duocHoan).toBe(800000);
  });

  it('cắt sát ngày thì các đêm trong 7 ngày tới chịu nửa tiền', () => {
    const bamLuc = mocVn('2026-07-24', '08:00').getTime();
    const kq = tinhKetThucSom(1000000, 10, PHI_HUY, batDau, 2, bamLuc);
    // Đêm 2 tới đêm 7 rơi trong 7 ngày kể từ lúc bấm
    expect(kq.K).toBe(6);
    expect(kq.chuNuoiTra).toBe(200000 + 300000);
  });

  it('phần dư dồn vào đêm cuối nên tổng luôn khớp số đã trả', () => {
    const kq = tinhKetThucSom(1000001, 3, PHI_HUY, batDau, 3, batDau.getTime());
    expect(kq.chuNuoiTra).toBe(1000001);
    expect(kq.duocHoan).toBe(0);
  });
});

describe('bất biến 4 — phí huỷ chịu phí nền tảng 15%', () => {
  it('đơn 150.000đ: người chăm 63.750đ, nền tảng 11.250đ', () => {
    expect(phanChiaPhiHuy(75000, NEN_TANG)).toEqual({
      nccNhan: 63750,
      nenTang: 11250,
    });
  });

  it('kỳ 540.000đ: người chăm 229.500đ, nền tảng 40.500đ', () => {
    expect(phanChiaPhiHuy(270000, NEN_TANG)).toEqual({
      nccNhan: 229500,
      nenTang: 40500,
    });
  });
});
