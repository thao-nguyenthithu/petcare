import { AnhKyService } from '../src/modules/media/anh-ky.service';
import { AnhTaiLenService } from '../src/modules/media/anh-tai-len.service';
import { SystemSettingsService } from '../src/modules/admin/system-settings.service';
import { SitterCancelService } from '../src/modules/sitter/orders/sitter-cancel.service';
import { SitterOrderStore } from '../src/modules/sitter/orders/sitter-order-store.service';
import { DisputeService } from '../src/modules/wallet/dispute.service';
import { WalletLedgerService } from '../src/modules/wallet/wallet-ledger.service';
import { PrismaService } from '../src/prisma/prisma.service';
import { anhKyGia } from './anh-ky-gia';
import { GIO_GIU_TIEN, NEN_TANG, PHI_HUY } from './tham-so-mac-dinh';

const MOT_GIO_MS = 3_600_000;
const TONG = 500_000;

type Lenh = { where?: unknown; data?: unknown };

function dungStore() {
  const donDoi: Lenh[] = [];
  const khoanDoi: Lenh[] = [];
  const db = {
    booking: {
      update: (arg: Lenh) => {
        donDoi.push(arg);
        return Promise.resolve({});
      },
    },
    payment: {
      updateMany: (arg: Lenh) => {
        khoanDoi.push(arg);
        return Promise.resolve({ count: 1 });
      },
    },
  };
  const prisma = {
    ...db,
    $transaction: (lenh: unknown) =>
      typeof lenh === 'function'
        ? (lenh as (tx: unknown) => Promise<unknown>)(db)
        : Promise.resolve(lenh),
  };
  const store = new SitterOrderStore(
    prisma as unknown as PrismaService,
    {} as unknown as AnhTaiLenService,
    {} as unknown as AnhKyService,
    { so: () => GIO_GIU_TIEN } as unknown as SystemSettingsService,
  );
  return { store, donDoi, khoanDoi };
}

describe('Khép đơn phía người chăm phải khai khoản chủ nuôi đã trả đi đâu', () => {
  it('nhánh hoàn ngay đẩy khoản giữ sang REFUNDING trong cùng transaction', async () => {
    const { store, khoanDoi } = dungStore();

    await store.khepDon('don-1', {
      trangThai: 'CANCELLED_BY_SITTER',
      lyDo: 'xeHong',
      chuNuoiChiu: 0,
      nccNhan: 0,
      tienDi: 'hoanNgay',
    });

    expect(khoanDoi).toHaveLength(1);
    expect(khoanDoi[0]).toEqual({
      where: { bookingId: 'don-1', status: 'HELD' },
      data: { status: 'REFUNDING' },
    });
  });

  it('nhánh hoàn ngay không đặt mốc nhả tiền vì không còn gì để nhả', async () => {
    const { store, donDoi } = dungStore();

    await store.khepDon('don-1', {
      trangThai: 'CANCELLED_BY_SITTER',
      lyDo: 'xeHong',
      chuNuoiChiu: 0,
      nccNhan: 0,
      tienDi: 'hoanNgay',
    });

    expect(donDoi[0].data).not.toHaveProperty('escrowReleaseAt');
  });

  it('nhánh giữ chờ phản đối để nguyên khoản giữ, chỉ đặt mốc nhả tiền', async () => {
    const { store, donDoi, khoanDoi } = dungStore();

    await store.khepDon('don-1', {
      trangThai: 'CANCELLED_NO_SHOW',
      lyDo: 'chuNuoiVangMat',
      chuNuoiChiu: 250_000,
      nccNhan: 212_500,
      tienDi: 'giuChoPhanDoi',
    });

    expect(khoanDoi).toHaveLength(0);
    const data = donDoi[0].data as { cancelledAt: Date; escrowReleaseAt: Date };
    expect(data.escrowReleaseAt.getTime() - data.cancelledAt.getTime()).toBe(
      GIO_GIU_TIEN * MOT_GIO_MS,
    );
  });

  it('ba phần cộng lại khớp tuyệt đối với số chủ nuôi đã trả', async () => {
    const { store, donDoi } = dungStore();

    await store.khepDon('don-1', {
      trangThai: 'CANCELLED_NO_SHOW',
      lyDo: 'chuNuoiVangMat',
      chuNuoiChiu: 250_000,
      nccNhan: 212_500,
      tienDi: 'giuChoPhanDoi',
    });

    const data = donDoi[0].data as {
      cancellationFee: number;
      sitterPayout: number;
      platformFee: number;
    };
    const hoanChoChuNuoi = TONG - data.cancellationFee;
    expect(hoanChoChuNuoi + data.sitterPayout + data.platformFee).toBe(TONG);
  });
});

function dungEscrow(don: {
  cancellationFee: number | null;
  sitterPayout: number | null;
}) {
  const dongVi: Array<Record<string, unknown>> = [];
  const khoanDoi: Lenh[] = [];
  const prisma = {
    booking: {
      findUnique: () =>
        Promise.resolve({
          id: 'don-1',
          code: 'PC001',
          sitterId: 'ncc-1',
          totalPrice: TONG,
          platformFee: 37_500,
          owner: { fullName: 'Chủ nuôi A' },
          reports: [],
          ...don,
        }),
    },
    payment: {
      findFirst: () => Promise.resolve({ id: 'pay-1', amount: TONG }),
      updateMany: (arg: Lenh) => {
        khoanDoi.push(arg);
        return Promise.resolve({ count: 1 });
      },
    },
    wallet: {
      upsert: () => Promise.resolve({ id: 'vi-1', balance: 212_500 }),
    },
    walletTransaction: {
      create: (arg: { data: Record<string, unknown> }) => {
        dongVi.push(arg.data);
        return Promise.resolve(arg.data);
      },
    },
    $transaction: (lenh: unknown) =>
      typeof lenh === 'function'
        ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
        : Promise.resolve(lenh),
  };
  const soVi = new WalletLedgerService(prisma as unknown as PrismaService);
  return { soVi, dongVi, khoanDoi };
}

describe('Nhả escrow của đơn khép bất thường phải trả lại phần chủ nuôi không chịu', () => {
  it('chủ nuôi chịu một nửa: ví nhận phần người chăm, khoản giữ sang REFUNDING', async () => {
    const { soVi, dongVi, khoanDoi } = dungEscrow({
      cancellationFee: 250_000,
      sitterPayout: 212_500,
    });

    await expect(soVi.nhaEscrow('don-1')).resolves.toBe(true);
    expect(khoanDoi[0].data).toEqual({ status: 'REFUNDING' });
    expect(dongVi[0]).toMatchObject({ amount: 212_500, bookingId: 'don-1' });
  });

  it('đơn xong bình thường vẫn sang RELEASED chứ không lạc sang nhánh hoàn', async () => {
    const { soVi, khoanDoi, dongVi } = dungEscrow({
      cancellationFee: null,
      sitterPayout: null,
    });

    await expect(soVi.nhaEscrow('don-1')).resolves.toBe(true);
    expect(khoanDoi[0].data).toMatchObject({ status: 'RELEASED' });
    expect(dongVi).toHaveLength(1);
  });

  it('chủ nuôi chịu trọn giá đơn thì không còn gì hoàn, giữ nhánh RELEASED', async () => {
    const { soVi, khoanDoi } = dungEscrow({
      cancellationFee: TONG,
      sitterPayout: 425_000,
    });

    await expect(soVi.nhaEscrow('don-1')).resolves.toBe(true);
    expect(khoanDoi[0].data).toMatchObject({ status: 'RELEASED' });
  });

  it('người chăm nhận 0 mà vẫn còn phần hoàn thì khoản giữ vẫn phải rời HELD', async () => {
    const { soVi, khoanDoi, dongVi } = dungEscrow({
      cancellationFee: 0,
      sitterPayout: 0,
    });

    await expect(soVi.nhaEscrow('don-1')).resolves.toBe(true);
    expect(khoanDoi[0].data).toEqual({ status: 'REFUNDING' });
    expect(dongVi).toHaveLength(0);
  });
});

const NGUOI_CHAM = 'user-ncc';

function dungHuy(loai: 'WALKING' | 'BOARDING') {
  const khep: Array<{ id: string; tin: Record<string, unknown> }> = [];
  const luc = new Date('2026-08-08T10:00:00.000Z');
  const don = {
    id: 'don-1',
    status: 'CONFIRMED',
    scheduledAt: new Date(luc.getTime() - 20 * 60_000),
    arrivedAt: new Date(luc.getTime() - 10 * 60_000),
    ownerArrivedAt: null,
    gearReportedAt: new Date(luc.getTime() - 20 * 60_000),
    totalPrice: TONG,
    platformFeePercent: NEN_TANG,
    cancelFeePercent: PHI_HUY,
    priceBreakdown: null,
    sitterId: 'ncc-1',
    service: { type: loai },
  };
  const store = {
    timDon: () => Promise.resolve({ ncc: { id: 'ncc-1' }, don }),
    khepDon: (id: string, tin: Record<string, unknown>) => {
      khep.push({ id, tin });
      return Promise.resolve();
    },
    dayAnhLenStorage: () => Promise.resolve(['anh/1.jpg']),
    kyAnhMang: () => Promise.resolve(['https://ky/1.jpg']),
  };
  const rong = new Proxy({}, { get: () => () => Promise.resolve() });
  const prisma = {
    booking: { update: () => Promise.resolve({}) },
    $transaction: (lenh: unknown) =>
      typeof lenh === 'function'
        ? (lenh as (tx: unknown) => Promise<unknown>)(prisma)
        : Promise.resolve(lenh),
  };
  const service = new SitterCancelService(
    prisma as never,
    store as never,
    rong as never,
    rong as never,
    rong as never,
  );
  return { service, khep, luc };
}

describe('Vắng mặt và thiếu dụng cụ: chủ nuôi chịu 50%, phần còn lại là tiền của họ', () => {
  it('báo vắng mặt khép đơn ở nhánh giữ chờ phản đối', async () => {
    const { service, khep, luc } = dungHuy('WALKING');
    jest.spyOn(Date, 'now').mockReturnValue(luc.getTime());

    await service.baoVangMat(NGUOI_CHAM, 'don-1', [
      { buffer: Buffer.from('a'), mimetype: 'image/jpeg' },
    ]);

    const nenTang = Math.floor(((TONG * PHI_HUY) / 100) * (NEN_TANG / 100));
    expect(khep[0].tin).toMatchObject({
      trangThai: 'CANCELLED_NO_SHOW',
      chuNuoiChiu: (TONG * PHI_HUY) / 100,
      nccNhan: (TONG * PHI_HUY) / 100 - nenTang,
      tienDi: 'giuChoPhanDoi',
    });
  });

  it('huỷ vì thiếu dụng cụ cũng đi nhánh giữ, không bỏ rơi phần chênh', async () => {
    const { service, khep, luc } = dungHuy('WALKING');
    jest.spyOn(Date, 'now').mockReturnValue(luc.getTime());

    await service.huyViThieuDungCu(NGUOI_CHAM, 'don-1');

    expect(khep[0].tin).toMatchObject({
      trangThai: 'CANCELLED_BY_SITTER',
      lyDo: 'thieuDungCu',
      chuNuoiChiu: (TONG * PHI_HUY) / 100,
      tienDi: 'giuChoPhanDoi',
    });
  });

  it('bỏ đơn đã nhận thì chủ nuôi 0 đồng nên hoàn ngay', async () => {
    const { service, khep, luc } = dungHuy('WALKING');
    jest.spyOn(Date, 'now').mockReturnValue(luc.getTime());

    await service.huyDon(NGUOI_CHAM, 'don-1', { reason: 'xeHong' } as never);

    expect(khep[0].tin).toMatchObject({
      chuNuoiChiu: 0,
      nccNhan: 0,
      tienDi: 'hoanNgay',
    });
  });
});

function dungKhieuNai(don: {
  status: string;
  cancellationReason: string | null;
  cancelledAt: Date;
}) {
  const prisma = {
    booking: {
      findFirst: () =>
        Promise.resolve({
          id: 'don-1',
          code: 'PC001',
          endedAt: null,
          escrowReleaseAt: null,
          ...don,
        }),
    },
    violationReport: {
      findFirst: () => Promise.resolve(null),
      count: () => Promise.resolve(0),
      create: (arg: { data: Record<string, unknown> }) =>
        Promise.resolve({
          id: 'hs-1',
          code: 'KN-PC001',
          status: 'OPEN',
          ...arg.data,
        }),
    },
  };
  return new DisputeService(
    prisma as unknown as PrismaService,
    { dayLen: () => Promise.resolve([]) } as unknown as AnhTaiLenService,
    anhKyGia().service,
  );
}

describe('Chủ nuôi phản đối được cả hai nhánh mình bị tính phí (bộ luật mục 5)', () => {
  const MO_TA = { description: 'Tôi có mặt đúng giờ, người chăm không gọi' };

  it('nhánh thiếu dụng cụ mở được hồ sơ trong hạn phản đối', async () => {
    const service = dungKhieuNai({
      status: 'CANCELLED_BY_SITTER',
      cancellationReason: 'thieuDungCu',
      cancelledAt: new Date(Date.now() - MOT_GIO_MS),
    });

    await expect(
      service.mo('user-owner', 'don-1', MO_TA as never),
    ).resolves.toMatchObject({ code: 'KN-PC001' });
  });

  it('quá hạn phản đối thì từ chối, không mượn nhánh báo sự cố thường', async () => {
    const service = dungKhieuNai({
      status: 'CANCELLED_BY_SITTER',
      cancellationReason: 'thieuDungCu',
      cancelledAt: new Date(Date.now() - 30 * MOT_GIO_MS),
    });

    await expect(
      service.mo('user-owner', 'don-1', MO_TA as never),
    ).rejects.toMatchObject({ response: { code: 'QUA_HAN_PHAN_DOI' } });
  });

  it('người chăm bỏ đơn thì chủ nuôi không mất đồng nào nên không có gì để phản đối', async () => {
    const service = dungKhieuNai({
      status: 'CANCELLED_BY_SITTER',
      cancellationReason: 'xeHong',
      cancelledAt: new Date(Date.now() - MOT_GIO_MS),
    });

    await expect(
      service.mo('user-owner', 'don-1', MO_TA as never),
    ).rejects.toMatchObject({ response: { code: 'DON_CHUA_KET_THUC' } });
  });
});
