import { tienVn } from '../src/common/dinh-dang-tien';
import { chiaDem, dong, phiHuy, phiNenTang, soDong } from '../src/common/tien';
import {
  phanChiaPhiHuy,
  phanTramNenTangCuaDon,
  phanTramPhiHuyCuaDon,
  phiHuyCuaDon,
} from '../src/modules/bookings/booking-cancel';
import {
  tinhGiaBoarding,
  tinhGiaGrooming,
  tinhGiaWalking,
  tinhKetThucSom,
} from '../src/modules/bookings/booking-pricing';
import { phiGiuThem } from '../src/modules/bookings/booking-time';
import { mocVn } from '../src/common/thoi-gian-vn';
import { WalletLedgerService } from '../src/modules/wallet/wallet-ledger.service';
import { PaymentsService } from '../src/modules/payments/payments.service';
import { PrismaService } from '../src/prisma/prisma.service';
import { NEN_TANG, PHI_HUY } from './tham-so-mac-dinh';

// Đồng Việt Nam không có phần lẻ nên không phép tính nào ở đây được sinh số thực

const TONG_THU: number[] = [
  1, 99, 100, 999, 11_400, 49_999, 99_999, 150_000, 1_000_000, 1_234_567,
];
const PHAN_TRAM_NEN_TANG = [5, 10, 15, 20, 25, 29, 30];
const PHAN_TRAM_PHI_HUY = [20, 35, 50, 57, 69, 70];

describe('phí nền tảng làm tròn xuống, phần lẻ về người chăm', () => {
  it('15% của 99.999 là 14.999,85 nên nền tảng chỉ lấy 14.999', () => {
    expect(phiNenTang(99_999, NEN_TANG)).toBe(14_999);
    expect(99_999 - phiNenTang(99_999, NEN_TANG)).toBe(85_000);
  });

  // Nhân với 29/100 dạng số thực cho ra 3305, thiếu đúng một đồng của nền tảng
  it('nhân phần trăm nguyên chứ không nhân tỷ lệ thực', () => {
    expect(Math.floor(11_400 * (29 / 100))).toBe(3305);
    expect(phiNenTang(11_400, 29)).toBe(3306);
    expect(Math.floor(10_250 * (70 / 100))).toBe(7174);
    expect(phiHuy(10_250, 70)).toBe(7175);
  });

  it('không bao giờ thu quá phần trăm đã chốt, phần lẻ luôn về người chăm', () => {
    for (const tong of TONG_THU) {
      for (const phanTram of PHAN_TRAM_NEN_TANG) {
        const phi = phiNenTang(tong, phanTram);
        expect(Number.isInteger(phi)).toBe(true);
        expect(phi * 100).toBeLessThanOrEqual(tong * phanTram);
        expect((phi + 1) * 100).toBeGreaterThan(tong * phanTram);
      }
    }
  });
});

describe('phí huỷ muộn làm tròn xuống', () => {
  it('50% của 99.999 là 49.999,5 nên chủ nuôi chỉ chịu 49.999', () => {
    expect(phiHuy(99_999, PHI_HUY)).toBe(49_999);
  });

  it('mọi tỷ lệ trong khoảng cho phép đều cắt xuống', () => {
    for (const tong of TONG_THU) {
      for (const phanTram of PHAN_TRAM_PHI_HUY) {
        const phi = phiHuy(tong, phanTram);
        expect(Number.isInteger(phi)).toBe(true);
        expect(phi * 100).toBeLessThanOrEqual(tong * phanTram);
      }
    }
  });

  it('phí huỷ chia qua phễu nền tảng vẫn khớp từng đồng', () => {
    for (const tong of TONG_THU) {
      const phi = phiHuyCuaDon('walking', tong, 0, PHI_HUY);
      const chia = phanChiaPhiHuy(phi, NEN_TANG);
      expect(chia.nccNhan + chia.nenTang).toBe(phi);
      expect(Number.isInteger(chia.nccNhan)).toBe(true);
      expect(Number.isInteger(chia.nenTang)).toBe(true);
    }
  });

  it('tỷ lệ đóng băng của đơn cũ vẫn là số nguyên phần trăm', () => {
    expect(phanTramNenTangCuaDon(null)).toBe(NEN_TANG);
    expect(phanTramPhiHuyCuaDon(null)).toBe(PHI_HUY);
    expect(phanTramNenTangCuaDon(29)).toBe(29);
  });
});

describe('chia tiền theo đêm dồn dư vào đêm cuối', () => {
  it('một triệu chia ba đêm thì đêm cuối gánh phần dư', () => {
    const ds = chiaDem(1_000_000, 3);
    expect(ds).toEqual([333_333, 333_333, 333_334]);
    expect(ds.reduce((a, b) => a + b, 0)).toBe(1_000_000);
  });

  it('tổng các đêm luôn khớp tuyệt đối với số chủ nuôi đã trả', () => {
    for (const tong of TONG_THU) {
      for (const soDem of [1, 2, 3, 7, 13, 14, 30]) {
        const ds = chiaDem(tong, soDem);
        expect(ds).toHaveLength(soDem);
        expect(ds.reduce((a, b) => a + b, 0)).toBe(tong);
        for (const x of ds) expect(Number.isInteger(x)).toBe(true);
        // Dư dồn vào đêm cuối nên các đêm trước đều bằng nhau
        expect(new Set(ds.slice(0, -1)).size).toBeLessThanOrEqual(1);
        expect(ds[soDem - 1]).toBeGreaterThanOrEqual(ds[0]);
      }
    }
  });

  it('cắt kỳ ở bất kỳ đêm nào thì trả cộng hoàn vẫn bằng số đã trả', () => {
    const batDau = mocVn('2026-09-10', '08:00');
    const bamLuc = mocVn('2026-09-09', '10:00').getTime();
    for (const tong of [1_000_001, 1_234_567, 999_999]) {
      for (const soDem of [3, 7, 14]) {
        for (let daO = 0; daO < soDem; daO++) {
          const kq = tinhKetThucSom(tong, soDem, PHI_HUY, batDau, daO, bamLuc);
          expect(kq.chuNuoiTra + kq.duocHoan).toBe(tong);
          expect(Number.isInteger(kq.chuNuoiTra)).toBe(true);
          expect(Number.isInteger(kq.duocHoan)).toBe(true);
        }
      }
    }
  });

  it('huỷ cả kỳ là trường hợp O bằng 0 của cùng công thức', () => {
    const batDau = mocVn('2026-09-10', '08:00');
    const satNgay = mocVn('2026-09-09', '13:00').getTime();
    const phi = phiHuyCuaDon(
      'boarding',
      1_000_001,
      10,
      PHI_HUY,
      batDau,
      satNgay,
    );
    expect(Number.isInteger(phi)).toBe(true);
    expect(phi).toBe(350_000);
  });
});

describe('không phép tính nào trong luồng tiền sinh ra số thực', () => {
  const giaDat = {
    priceByDuration: { 30: 60_000, 60: 100_001 },
    additionalPetFee: 25_001,
    maxPets: 3,
  };

  it('giá đơn dắt và phụ phí bé thêm đều nguyên', () => {
    const gia = tinhGiaWalking(giaDat, 3, 60);
    expect(gia.total).toBe(100_001 + 25_001 * 2);
    for (const d of gia.lines) expect(Number.isInteger(d.amount)).toBe(true);
  });

  it('giá kỳ trông giữ kèm phí giữ thêm đều nguyên', () => {
    const pricing = { pricePerDay: 200_001, additionalPetFee: 30_001 };
    for (const phutTre of [0, 121, 300, 481, 1500, 3000]) {
      const gia = tinhGiaBoarding(pricing, 2, 3, phutTre);
      expect(Number.isInteger(gia.total)).toBe(true);
      for (const d of gia.lines) expect(Number.isInteger(d.amount)).toBe(true);
    }
  });

  it('nửa đêm của phí giữ thêm cắt xuống chứ không ra số lẻ', () => {
    expect(phiGiuThem(300, 200_001)).toBe(100_000);
    expect(phiGiuThem(0, 200_001)).toBe(0);
    expect(phiGiuThem(600, 200_001)).toBe(200_001);
  });

  it('giá grooming từng bé đều nguyên', () => {
    const pricing = {
      priceByPackage: { bath: { duoi5: 150_001, tu5den10: 220_001 } },
      durationByPackage: { bath: { duoi5: 60, tu5den10: 75 } },
    };
    const gia = tinhGiaGrooming(pricing, [
      { id: 'p1', weightKg: 4, packageCode: 'bath' },
      { id: 'p2', weightKg: 8, packageCode: 'bath' },
    ]);
    expect(gia.total).toBe(370_002);
    for (const be of gia.perPet) expect(Number.isInteger(be.price)).toBe(true);
  });

  it('số lẻ lọt vào cột pricing thì cắt xuống chứ không đội giá lên', () => {
    const gia = tinhGiaWalking(
      { priceByDuration: { 30: 60_000.9 }, maxPets: 1 },
      1,
      30,
    );
    expect(gia.total).toBe(60_000);
  });

  it('dong cắt xuống, soDong quy bigint của SUM về số thường', () => {
    expect(dong(1_000.9)).toBe(1_000);
    expect(dong(null)).toBe(0);
    expect(dong(Number.NaN)).toBe(0);
    expect(soDong(428_600_000n)).toBe(428_600_000);
    expect(soDong(null)).toBe(0);
    expect(soDong('123')).toBe(123);
  });

  it('chuỗi tiền hiện ra màn không nuốt phần lẻ của số hỏng', () => {
    expect(tienVn(1_500_000)).toBe('1.500.000đ');
    expect(tienVn(0)).toBe('0đ');
  });
});

describe('đối soát với cổng thanh toán khớp tuyệt đối', () => {
  function dungCong(soTienGhiSo: number, trangThaiDon = 'AWAITING_PAYMENT') {
    const daGhi: Record<string, unknown>[] = [];
    const tx = {
      $executeRaw: () => Promise.resolve(1),
      payment: {
        findUnique: () =>
          Promise.resolve({
            id: 'pm-1',
            bookingId: 'bk-1',
            amount: soTienGhiSo,
            status: 'PENDING',
            booking: { status: trangThaiDon },
          }),
        update: (arg: Record<string, unknown>) => {
          daGhi.push(arg);
          return Promise.resolve({});
        },
      },
      booking: { update: () => Promise.resolve({}) },
    };
    const prisma = {
      $transaction: (viec: (db: unknown) => Promise<unknown>) => viec(tx),
    } as unknown as PrismaService;
    const notify = { donMoi: () => Promise.resolve() };
    const dv = new PaymentsService(
      prisma,
      notify as never,
      null as never,
      null as never,
    );
    return { dv, daGhi };
  }

  const KET_QUA = {
    txnRef: 'PCABC123',
    thanhCong: true,
    maGiaoDich: '14257845',
    ngayTraCong: '20260806104530',
    bankCode: 'NCB',
    cardType: 'ATM',
    maPhanHoi: '00',
    duLieuGoc: {},
  };

  it('khớp đúng từng đồng thì mới giữ tiền', async () => {
    const { dv } = dungCong(150_000);
    const ket = await dv.xacNhanTra({ ...KET_QUA, soTien: 150_000 });
    expect(ket.ma).toBe('THANH_CONG');
  });

  it('lệch một đồng là lệch tiền, KHÔNG có ngưỡng dung sai', async () => {
    for (const soTien of [149_999, 150_001]) {
      const { dv, daGhi } = dungCong(150_000);
      const ket = await dv.xacNhanTra({ ...KET_QUA, soTien });
      expect(ket.ma).toBe('LECH_TIEN');
      expect(daGhi[0]).toMatchObject({ data: { status: 'FAILED' } });
    }
  });

  it('cổng trả số lẻ là lệch, không làm tròn về cho khớp', async () => {
    for (const soTien of [150_000.4, 149_999.6]) {
      const { dv } = dungCong(150_000);
      const ket = await dv.xacNhanTra({ ...KET_QUA, soTien });
      expect(ket.ma).toBe('LECH_TIEN');
    }
  });

  it('tiền về sau khi đơn giữ chỗ đã chết thì sang thẳng chờ hoàn', async () => {
    const { dv, daGhi } = dungCong(150_000, 'CANCELLED_UNPAID');
    const ket = await dv.xacNhanTra({ ...KET_QUA, soTien: 150_000 });
    expect(ket.ma).toBe('DON_DA_CHET');
    expect(daGhi[0]).toMatchObject({ data: { status: 'REFUNDING' } });
  });
});

describe('sổ ví chỉ nhận số nguyên đồng', () => {
  function dungVi() {
    const soSach: Record<string, unknown>[] = [];
    const tx = {
      wallet: {
        upsert: () => Promise.resolve({ id: 'vi-1', balance: 100_000 }),
      },
      walletTransaction: {
        create: (arg: { data: Record<string, unknown> }) => {
          soSach.push(arg.data);
          return Promise.resolve(arg.data);
        },
      },
    };
    const prisma = {
      $transaction: (viec: (db: unknown) => Promise<unknown>) => viec(tx),
    } as unknown as PrismaService;
    return { so: new WalletLedgerService(prisma), soSach };
  }

  it('ghi số lẻ vào sổ thì chặn ngay, không để Prisma ném lỗi khó đọc', async () => {
    const { so, soSach } = dungVi();
    await expect(
      so.ghi('ncc-1', { loai: 'TIEN_VAO', tieuDe: 'Đơn A', soTien: 1_000.5 }),
    ).rejects.toMatchObject({ response: { code: 'SO_TIEN_KHONG_NGUYEN' } });
    expect(soSach).toHaveLength(0);
  });

  it('số nguyên thì ghi thẳng, không qua bước làm tròn nào', async () => {
    const { so, soSach } = dungVi();
    await so.ghi('ncc-1', {
      loai: 'TIEN_VAO',
      tieuDe: 'Đơn A',
      soTien: 85_001,
    });
    expect(soSach[0]).toMatchObject({ amount: 85_001, balanceAfter: 100_000 });
  });
});
