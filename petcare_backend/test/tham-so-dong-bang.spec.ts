import { mocVn } from '../src/common/thoi-gian-vn';
import { phiNenTang } from '../src/common/tien';
import {
  phanChiaPhiHuy,
  phanTramNenTangCuaDon,
  phanTramPhiHuyCuaDon,
  phiHuyCuaDon,
} from '../src/modules/bookings/booking-cancel';
import {
  gioGiuTienCuaDon,
  mocNhaTien,
} from '../src/modules/bookings/booking-compensation';
import { khoanNccNhan } from '../src/modules/wallet/wallet-booking.mapper';
import { NEN_TANG, PHI_HUY } from './tham-so-mac-dinh';

// Con số áp cho một đơn là con số tại lúc chốt đơn (bộ luật mục 15)

describe('phí nền tảng đóng băng theo đơn', () => {
  // Đơn cũ tạo lúc phí nền tảng còn 15%
  const donCu = {
    totalPrice: 500_000,
    platformFee: 75_000,
    platformFeePercent: 15,
    sitterPayout: null,
  };

  it('người chăm nhận đúng phần cũ dù cấu hình đã lên 30%', () => {
    expect(khoanNccNhan(donCu)).toBe(425_000);
    // Nhân lại tỷ lệ đang chạy sẽ ra 350.000, tức bốc mất 75.000 của người chăm
    expect(phiNenTang(donCu.totalPrice, 30)).toBe(150_000);
  });

  it('phí huỷ của đơn cũ vẫn qua phễu 15% đã chốt', () => {
    const phi = 100_000;
    expect(phanChiaPhiHuy(phi, phanTramNenTangCuaDon(15))).toEqual({
      nccNhan: 85_000,
      nenTang: 15_000,
    });
    expect(phanChiaPhiHuy(phi, phanTramNenTangCuaDon(30))).toEqual({
      nccNhan: 70_000,
      nenTang: 30_000,
    });
  });

  it('nhánh khép bất thường đã chốt sẵn thì lấy thẳng số đã chốt', () => {
    expect(khoanNccNhan({ ...donCu, sitterPayout: 42_500 })).toBe(42_500);
  });

  it('đơn trước đợt đóng băng không có cột thì lấy mặc định của bộ khai', () => {
    expect(phanTramNenTangCuaDon(null)).toBe(NEN_TANG);
    expect(phanTramPhiHuyCuaDon(null)).toBe(PHI_HUY);
  });
});

describe('phí huỷ đóng băng theo đơn', () => {
  const batDau = mocVn('2026-09-10', '08:00');

  it('đơn dắt cũ vẫn mất 50% dù cấu hình đã lên 70%', () => {
    expect(phiHuyCuaDon('walking', 200_000, 0, phanTramPhiHuyCuaDon(50))).toBe(
      100_000,
    );
    // Đơn tạo SAU khi đổi mới ăn tỷ lệ mới
    expect(phiHuyCuaDon('walking', 200_000, 0, phanTramPhiHuyCuaDon(70))).toBe(
      140_000,
    );
  });

  it('kỳ trông giữ cũ tính đúng nửa tiền của bảy đêm chịu phí', () => {
    const satNgay = mocVn('2026-09-09', '13:00').getTime();
    const phi = phiHuyCuaDon(
      'boarding',
      1_000_000,
      10,
      phanTramPhiHuyCuaDon(50),
      batDau,
      satNgay,
    );
    expect(phi).toBe(350_000);
  });
});

describe('mốc nhả tiền đóng băng theo đơn', () => {
  const ketThuc = mocVn('2026-09-10', '18:00');

  it('mốc chốt tại lúc đơn kết thúc, không cộng lại về sau', () => {
    const moc = mocNhaTien(ketThuc, 48);
    expect(moc.toISOString()).toBe(mocVn('2026-09-12', '18:00').toISOString());
  });

  it('đơn cũ giữ nguyên 48 giờ dù cấu hình đã lên 96', () => {
    const donCu = {
      endedAt: ketThuc,
      escrowReleaseAt: mocNhaTien(ketThuc, 48),
    };
    expect(gioGiuTienCuaDon(donCu)).toBe(48);
    const donMoi = {
      endedAt: ketThuc,
      escrowReleaseAt: mocNhaTien(ketThuc, 96),
    };
    expect(gioGiuTienCuaDon(donMoi)).toBe(96);
  });

  it('đơn chưa kết thúc thì rơi về mặc định chứ không ném lỗi', () => {
    expect(gioGiuTienCuaDon({ endedAt: null, escrowReleaseAt: null })).toBe(48);
  });
});
