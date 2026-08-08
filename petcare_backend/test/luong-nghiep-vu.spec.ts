import { chiaDem, phiHuy, phiNenTang } from '../src/common/tien';
import { mocVn } from '../src/common/thoi-gian-vn';
import {
  DonXetHuy,
  hanHuyMienPhiAt,
  phanChiaPhiHuy,
  phiHuyCuaDon,
  xetMienPhi,
} from '../src/modules/bookings/booking-cancel';
import { tinhKetThucSom } from '../src/modules/bookings/booking-pricing';
import {
  DEM_TAN_NOI_MINUTES,
  DEM_WALKING_MINUTES,
  PHUT_GIU_CHO_TRA_TIEN,
  conGiuCho,
  demGiuaHaiDon,
  hanGiuCho,
  hanNhanDonPhut,
  phiGiuThem,
  phutGiuThem,
  phutTreCuaKy,
} from '../src/modules/bookings/booking-time';
import { PHI_CHUYEN } from '../src/modules/wallet/wallet.constants';
import { NEN_TANG, PHI_HUY, SO_LAN_RUT_MOI_NGAY } from './tham-so-mac-dinh';

// Đi theo trình tự người dùng gặp, để bắt chỗ hai luật đúng riêng lẻ mà ghép lại thì sai

const MOT_PHUT = 60_000;
const MOT_GIO = 3_600_000;

function don(p: Partial<DonXetHuy> = {}): DonXetHuy {
  return {
    loai: 'walking',
    batDau: mocVn('2026-09-10', '08:00'),
    soDem: 0,
    tongTien: 200_000,
    dangCho: false,
    taoLuc: mocVn('2026-09-01', '10:00'),
    acceptedAt: mocVn('2026-09-01', '10:05'),
    arrivedAt: null,
    departedAt: null,
    ...p,
  };
}

describe('luồng đặt đơn', () => {
  it('đệm giữa hai đơn tách theo dịch vụ, dắt ngắn hơn hai loại phải di chuyển', () => {
    expect(demGiuaHaiDon('walking')).toBe(DEM_WALKING_MINUTES);
    expect(demGiuaHaiDon('grooming')).toBe(DEM_TAN_NOI_MINUTES);
    expect(demGiuaHaiDon('boarding')).toBe(DEM_TAN_NOI_MINUTES);
    expect(DEM_WALKING_MINUTES).toBeLessThan(DEM_TAN_NOI_MINUTES);
  });

  it('hạn trả lời co lại khi đơn càng gần giờ hẹn', () => {
    expect(hanNhanDonPhut(5 * 60)).toBe(30);
    expect(hanNhanDonPhut(20 * 60)).toBe(120);
    expect(hanNhanDonPhut(3 * 24 * 60)).toBe(12 * 60);
    expect(hanNhanDonPhut(30 * 24 * 60)).toBe(24 * 60);
  });

  it('hạn trả lời không bao giờ dài hơn thời gian còn lại tới giờ hẹn', () => {
    // Đơn gấp nhất được đặt là trước 2 giờ, hạn trả lời phải nằm gọn trong đó
    for (const conLai of [120, 200, 6 * 60, 24 * 60, 7 * 24 * 60]) {
      expect(hanNhanDonPhut(conLai)).toBeLessThanOrEqual(conLai);
    }
  });

  it('giữ chỗ chờ trả tiền hết sau đúng 10 phút', () => {
    const taoLuc = mocVn('2026-09-01', '10:00');
    expect(PHUT_GIU_CHO_TRA_TIEN).toBe(10);
    expect(hanGiuCho(taoLuc).getTime()).toBe(
      taoLuc.getTime() + PHUT_GIU_CHO_TRA_TIEN * MOT_PHUT,
    );
  });

  it('đơn chờ hết hiệu lực đúng theo bậc hạn trả lời của chính nó', () => {
    const datLuc = mocVn('2026-09-01', '10:00');
    // Cách giờ hẹn 4 ngày nên hạn là 12 giờ, không phải 10 phút giữ chỗ
    const henXa = mocVn('2026-09-05', '08:00');
    expect(conGiuCho(datLuc, henXa, datLuc.getTime() + 11 * MOT_GIO)).toBe(
      true,
    );
    expect(conGiuCho(datLuc, henXa, datLuc.getTime() + 13 * MOT_GIO)).toBe(
      false,
    );
    // Cách giờ hẹn 5 giờ thì hạn co lại còn 30 phút
    const henGan = mocVn('2026-09-01', '15:00');
    expect(conGiuCho(datLuc, henGan, datLuc.getTime() + 29 * MOT_PHUT)).toBe(
      true,
    );
    expect(conGiuCho(datLuc, henGan, datLuc.getTime() + 31 * MOT_PHUT)).toBe(
      false,
    );
  });
});

describe('luồng huỷ đơn phía chủ nuôi', () => {
  it('cửa 1: người chăm chưa nhận thì huỷ lúc nào cũng 0 đồng', () => {
    const d = don({ dangCho: true, acceptedAt: null });
    expect(xetMienPhi(d, mocVn('2026-09-09', '23:00').getTime()).mienPhi).toBe(
      true,
    );
  });

  it('cửa 2: mốc miễn phí là 12 giờ trưa hôm trước, không trôi theo giờ đặt', () => {
    const han = hanHuyMienPhiAt('walking', mocVn('2026-09-10', '08:00'), 0);
    expect(han.getTime()).toBe(mocVn('2026-09-09', '12:00').getTime());
    const d = don();
    expect(xetMienPhi(d, han.getTime() - MOT_PHUT).mienPhi).toBe(true);
    expect(xetMienPhi(d, han.getTime() + MOT_PHUT).mienPhi).toBe(false);
  });

  it('kỳ trông giữ trên 7 đêm thì mốc lùi hẳn 7 ngày trước ngày bắt đầu', () => {
    const ngan = hanHuyMienPhiAt('boarding', mocVn('2026-09-10', '08:00'), 5);
    const dai = hanHuyMienPhiAt('boarding', mocVn('2026-09-10', '08:00'), 10);
    expect(ngan.getTime()).toBe(mocVn('2026-09-09', '12:00').getTime());
    expect(dai.getTime()).toBe(mocVn('2026-09-03', '12:00').getTime());
  });

  it('cửa 3: đơn đặt gấp được 30 phút kể từ lúc người chăm nhận', () => {
    const batDau = mocVn('2026-09-10', '08:00');
    // Đặt sau mốc 12 giờ trưa hôm trước nên là đơn đặt gấp
    const taoLuc = mocVn('2026-09-09', '18:00');
    const d = don({ batDau, taoLuc, acceptedAt: mocVn('2026-09-09', '18:05') });
    const nhanLuc = d.acceptedAt!.getTime();
    expect(xetMienPhi(d, nhanLuc + 29 * MOT_PHUT).mienPhi).toBe(true);
    expect(xetMienPhi(d, nhanLuc + 31 * MOT_PHUT).mienPhi).toBe(false);
  });

  it('cửa 3 ĐÓNG ngay khi người chăm bấm Xuất phát, dù chưa hết 30 phút', () => {
    const batDau = mocVn('2026-09-10', '08:00');
    const taoLuc = mocVn('2026-09-09', '18:00');
    const acceptedAt = mocVn('2026-09-09', '18:05');
    const chuaDi = don({ batDau, taoLuc, acceptedAt });
    const daDi = don({
      batDau,
      taoLuc,
      acceptedAt,
      departedAt: mocVn('2026-09-09', '18:10'),
    });
    const luc = acceptedAt.getTime() + 15 * MOT_PHUT;
    expect(xetMienPhi(chuaDi, luc).mienPhi).toBe(true);
    // Cùng thời điểm, chỉ khác đã lên đường: huỷ trắng người đang đi là không được
    expect(xetMienPhi(daDi, luc).mienPhi).toBe(false);
  });

  it('cửa 4: quá giờ hẹn 15 phút mà người chăm chưa tới thì lỗi ghi cho họ', () => {
    const batDau = mocVn('2026-09-10', '08:00');
    const d = don({ batDau });
    const truoc = xetMienPhi(d, batDau.getTime() + 14 * MOT_PHUT);
    const sau = xetMienPhi(d, batDau.getTime() + 16 * MOT_PHUT);
    expect(truoc.mienPhi).toBe(false);
    expect(sau).toEqual({ mienPhi: true, doNguoiCham: true });
  });

  it('trông giữ KHÔNG có cửa 4 vì bên phải đi lại là chủ nuôi', () => {
    const batDau = mocVn('2026-09-10', '08:00');
    const d = don({ loai: 'boarding', soDem: 3, batDau });
    expect(xetMienPhi(d, batDau.getTime() + 60 * MOT_PHUT).mienPhi).toBe(false);
  });

  it('huỷ muộn mất đúng 50%, người chăm nhận 85% của khoản đó', () => {
    const phi = phiHuyCuaDon('walking', 200_000, 0, PHI_HUY);
    expect(phi).toBe(100_000);
    expect(phanChiaPhiHuy(phi, NEN_TANG)).toEqual({
      nccNhan: 85_000,
      nenTang: 15_000,
    });
  });

  it('huỷ kỳ trông giữ: đêm chịu phí đếm từ LÚC BẤM, báo càng sớm càng nhẹ', () => {
    const batDau = mocVn('2026-09-10', '12:00');
    const tong = 1_000_000;
    const soDem = 10;
    // Bấm sát ngày bắt đầu: 7 đêm đầu rơi trong 7 ngày tới
    const satNgay = mocVn('2026-09-09', '13:00').getTime();
    expect(tinhKetThucSom(tong, soDem, PHI_HUY, batDau, 0, satNgay).K).toBe(7);
    // Bấm trước 4 ngày: cửa sổ 7 ngày chỉ với tới 4 đêm đầu
    const truoc4Ngay = mocVn('2026-09-06', '13:00').getTime();
    expect(tinhKetThucSom(tong, soDem, PHI_HUY, batDau, 0, truoc4Ngay).K).toBe(
      4,
    );
    // Ranh giới đúng một giờ: bấm lúc 11:00 thì đêm thứ tư rơi ra ngoài cửa sổ
    const som1Gio = mocVn('2026-09-06', '11:00').getTime();
    expect(tinhKetThucSom(tong, soDem, PHI_HUY, batDau, 0, som1Gio).K).toBe(3);
    // Báo càng sớm càng nhẹ, đó là điều luật này muốn thưởng
    const truoc9Ngay = mocVn('2026-09-01', '13:00').getTime();
    expect(tinhKetThucSom(tong, soDem, PHI_HUY, batDau, 0, truoc9Ngay).K).toBe(
      0,
    );
  });

  it('kết thúc sớm giữa kỳ: trả đủ đêm đã ở, nửa tiền đêm cắt trong cửa sổ', () => {
    const batDau = mocVn('2026-09-01', '12:00');
    // Kỳ 14 đêm, ở tới đêm 8, bấm chốt vào đêm thứ 8
    const bamLuc = mocVn('2026-09-09', '10:00').getTime();
    const kq = tinhKetThucSom(1_400_000, 14, PHI_HUY, batDau, 8, bamLuc);
    expect(kq.O).toBe(8);
    expect(kq.C).toBe(6);
    // Sáu đêm còn lại đều nằm trong 7 ngày kể từ lúc bấm
    expect(kq.K).toBe(6);
    expect(kq.chuNuoiTra).toBe(800_000 + 300_000);
    expect(kq.duocHoan).toBe(1_400_000 - kq.chuNuoiTra);
  });

  it('tổng tiền luôn khớp tuyệt đối dù cắt kỳ ở bất kỳ đêm nào', () => {
    const batDau = mocVn('2026-09-01', '12:00');
    const bamLuc = mocVn('2026-09-02', '10:00').getTime();
    // 1.000.000 chia 7 đêm ra số lẻ, đây là chỗ dễ lệch một đồng nhất
    for (let o = 0; o < 7; o++) {
      const kq = tinhKetThucSom(1_000_000, 7, PHI_HUY, batDau, o, bamLuc);
      expect(kq.chuNuoiTra + kq.duocHoan).toBe(1_000_000);
    }
  });

  it('đón muộn: bậc cuối MỞ, mỗi 24 giờ tiếp theo cộng thêm một đêm', () => {
    const giaDem = 300_000;
    expect(phiGiuThem(90, giaDem)).toBe(0);
    expect(phiGiuThem(300, giaDem)).toBe(150_000);
    expect(phiGiuThem(10 * 60, giaDem)).toBe(300_000);
    // Muộn hai ngày rưỡi phải đắt hơn muộn một ngày, không được dừng ở một đêm
    expect(phiGiuThem(36 * 60, giaDem)).toBe(600_000);
    expect(phiGiuThem(60 * 60, giaDem)).toBe(900_000);
  });

  it('đón muộn đếm bằng mốc thật, không so phút trong ngày', () => {
    const nhan = mocVn('2026-09-01', '08:00');
    const traHaiNgay = mocVn('2026-09-03', '09:00');
    expect(phutGiuThem(nhan, traHaiNgay)).toBe(2 * 24 * 60 + 60);
    // Kỳ 2 đêm thì phần quá hạn chỉ là 1 giờ
    expect(phutTreCuaKy(nhan, 2, traHaiNgay)).toBe(60);
  });
});

describe('luồng rút tiền', () => {
  it('phí nền tảng làm tròn XUỐNG, phần lẻ về phía người chăm', () => {
    // 15% của 99.999 là 14.999,85 — làm tròn lên là thu quá của người chăm
    expect(phiNenTang(99_999, NEN_TANG)).toBe(14_999);
    expect(99_999 - phiNenTang(99_999, NEN_TANG)).toBe(85_000);
  });

  it('phí huỷ làm tròn xuống, không bao giờ thu quá của chủ nuôi', () => {
    expect(phiHuy(99_999, PHI_HUY)).toBe(49_999);
  });

  it('chia tiền theo đêm dồn phần dư vào đêm cuối, tổng khớp tuyệt đối', () => {
    const ds = chiaDem(1_000_000, 3);
    expect(ds).toEqual([333_333, 333_333, 333_334]);
    expect(ds.reduce((a, b) => a + b, 0)).toBe(1_000_000);
  });

  it('mọi khoản tiền là số nguyên đồng, không có phần lẻ ở bất kỳ đâu', () => {
    for (const tong of [99_999, 1_000_000, 1_234_567]) {
      for (const soDem of [1, 3, 7, 14]) {
        for (const x of chiaDem(tong, soDem)) {
          expect(Number.isInteger(x)).toBe(true);
        }
      }
      expect(Number.isInteger(phiNenTang(tong, NEN_TANG))).toBe(true);
      expect(Number.isInteger(phiHuy(tong, PHI_HUY))).toBe(true);
    }
  });

  it('rút miễn phí, trần 2 lệnh mỗi ngày', () => {
    expect(PHI_CHUYEN).toBe(0);
    expect(SO_LAN_RUT_MOI_NGAY).toBe(2);
  });

  it('tiền người chăm nhận từ một đơn xong bằng đúng 85% sau khi trừ phễu', () => {
    const tong = 500_000;
    const nenTang = phiNenTang(tong, NEN_TANG);
    expect(tong - nenTang).toBe(425_000);
    // Phí huỷ đi qua đúng phễu đó, không có khoản nào nhận trọn
    const phi = phiHuyCuaDon('walking', tong, 0, PHI_HUY);
    expect(phanChiaPhiHuy(phi, NEN_TANG).nccNhan).toBe(212_500);
  });
});
