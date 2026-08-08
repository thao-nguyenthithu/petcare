import { ConflictException } from '@nestjs/common';
import { PaymentStatus, WithdrawalStatus } from '../generated/prisma/enums';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { AdminFinanceSummaryService } from '../src/modules/admin/finance/admin-finance-summary.service';
import { AdminRefundsWriteService } from '../src/modules/admin/finance/admin-refunds-write.service';
import { AdminWithdrawalsService } from '../src/modules/admin/finance/admin-withdrawals.service';
import {
  suyLyDoHoan,
  tinhTienHoan,
} from '../src/modules/admin/finance/hoan-tien-chung';
import { SystemSettingsService } from '../src/modules/admin/system-settings.service';
import { WalletLedgerService } from '../src/modules/wallet/wallet-ledger.service';
import { PrismaService } from '../src/prisma/prisma.service';

type BanGhi = Record<string, unknown>;

function nhanhTransaction(prisma: BanGhi) {
  return (lenh: unknown) =>
    typeof lenh === 'function'
      ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
      : Promise.resolve(lenh);
}

function dungHoanTay(trangThai: PaymentStatus) {
  const nhatKy: BanGhi[] = [];
  const daDoi: BanGhi[] = [];
  const prisma: BanGhi = {
    payment: {
      findUnique: () =>
        Promise.resolve({
          id: 'pm-1',
          txnRef: 'PC001-1',
          status: trangThai,
          booking: { code: 'PC001' },
        }),
      updateMany: (arg: { where: BanGhi; data: BanGhi }) => {
        daDoi.push(arg.data);
        return Promise.resolve({
          count: arg.where.status === trangThai ? 1 : 0,
        });
      },
    },
    adminAuditLog: {
      create: (arg: { data: BanGhi }) => {
        nhatKy.push(arg.data);
        return Promise.resolve({ id: 'log-1' });
      },
    },
  };
  prisma.$transaction = nhanhTransaction(prisma);

  const service = new AdminRefundsWriteService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
  );
  return { service, nhatKy, daDoi };
}

describe('Đánh dấu hoàn tay là lối duy nhất sang REFUNDED', () => {
  it('ghi đủ ba cột mới rồi ghi nhật ký trong cùng lượt', async () => {
    const { service, nhatKy, daDoi } = dungHoanTay(PaymentStatus.REFUNDING);

    const ket = await service.danhDauHoanTay(
      'PC001-1',
      { reference: 'FT2608071234', note: 'Chuyển tay ở cổng merchant' },
      'admin-1',
    );

    expect(daDoi[0]).toMatchObject({
      status: PaymentStatus.REFUNDED,
      refundReference: 'FT2608071234',
      refundNote: 'Chuyển tay ở cổng merchant',
    });
    expect(daDoi[0].refundedAt).toBeInstanceOf(Date);
    expect(nhatKy[0]).toMatchObject({
      action: 'DANH_DAU_HOAN_TIEN',
      targetType: 'PAYMENT',
      targetCode: 'PC001-1',
    });
    expect(ket.refundedAt).toEqual(daDoi[0].refundedAt);
  });

  it('bấm lần hai trên khoản đã hoàn thì chặn, không đè mã tham chiếu cũ', async () => {
    const { service, daDoi, nhatKy } = dungHoanTay(PaymentStatus.REFUNDED);

    await expect(
      service.danhDauHoanTay('PC001-1', { reference: 'FT999' }, 'admin-1'),
    ).rejects.toThrow(ConflictException);
    expect(daDoi).toHaveLength(0);
    expect(nhatKy).toHaveLength(0);
  });

  it('khoản chưa vào nhánh hoàn cũng bị chặn bằng đúng mã lỗi', async () => {
    const { service } = dungHoanTay(PaymentStatus.HELD);

    await expect(
      service.danhDauHoanTay('PC001-1', { reference: 'FT999' }, 'admin-1'),
    ).rejects.toMatchObject({
      response: { code: 'TRANG_THAI_KHONG_HOP_LE' },
    });
  });
});

function dungLenhRut(trangThai: WithdrawalStatus) {
  const nhatKy: BanGhi[] = [];
  const daDoi: BanGhi[] = [];
  const soVi: unknown[][] = [];
  const prisma: BanGhi = {
    withdrawal: {
      findUnique: () =>
        Promise.resolve({
          id: 'wd-1',
          sitterId: 'ncc-1',
          amount: 250000,
          status: trangThai,
        }),
      updateMany: (arg: { data: BanGhi }) => {
        daDoi.push(arg.data);
        return Promise.resolve({ count: 1 });
      },
    },
    adminAuditLog: {
      create: (arg: { data: BanGhi }) => {
        nhatKy.push(arg.data);
        return Promise.resolve({ id: 'log-1' });
      },
    },
  };
  prisma.$transaction = nhanhTransaction(prisma);

  const vi = {
    ghi: (...doiSo: unknown[]) => {
      soVi.push(doiSo);
      return Promise.resolve({ code: 'DC-1', balanceAfter: 250000 });
    },
  };

  const service = new AdminWithdrawalsService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
    vi as unknown as WalletLedgerService,
  );
  return { service, nhatKy, daDoi, soVi };
}

describe('Ba lối chuyển của lệnh rút', () => {
  it('đang chờ chuyển sang đã chuyển, kèm mã tham chiếu và mốc gửi', async () => {
    const { service, daDoi, nhatKy, soVi } = dungLenhRut(
      WithdrawalStatus.PENDING,
    );

    await service.doiTrangThai(
      'wd-1',
      { status: 'SENT', reference: 'FT88112233' },
      'admin-1',
    );

    expect(daDoi[0]).toMatchObject({
      status: WithdrawalStatus.SENT,
      reference: 'FT88112233',
    });
    expect(daDoi[0].sentAt).toBeInstanceOf(Date);
    expect(nhatKy[0]).toMatchObject({
      action: 'CHUYEN_TIEN_RUT',
      targetType: 'WITHDRAWAL',
    });
    expect(soVi).toHaveLength(0);
  });

  it('đã chuyển sang xong thì chỉ đóng mốc, không đụng sổ ví', async () => {
    const { service, daDoi, nhatKy, soVi } = dungLenhRut(WithdrawalStatus.SENT);

    await service.doiTrangThai('wd-1', { status: 'DONE' }, 'admin-1');

    expect(daDoi[0]).toMatchObject({ status: WithdrawalStatus.DONE });
    expect(daDoi[0].doneAt).toBeInstanceOf(Date);
    expect(nhatKy[0]).toMatchObject({ action: 'HOAN_TAT_LENH_RUT' });
    expect(soVi).toHaveLength(0);
  });

  it('từ chối thì hoàn số dư bằng một dòng sổ mới cùng lượt ghi', async () => {
    const { service, daDoi, nhatKy, soVi } = dungLenhRut(
      WithdrawalStatus.PENDING,
    );

    await service.doiTrangThai(
      'wd-1',
      { status: 'REJECTED', rejectReason: 'Sai số tài khoản nhận' },
      'admin-1',
    );

    expect(daDoi[0]).toMatchObject({
      status: WithdrawalStatus.REJECTED,
      rejectReason: 'Sai số tài khoản nhận',
    });
    expect(soVi).toHaveLength(1);
    expect(soVi[0][0]).toBe('ncc-1');
    expect(soVi[0][1]).toMatchObject({ loai: 'DIEU_CHINH', soTien: 250000 });
    expect(nhatKy[0]).toMatchObject({ action: 'TU_CHOI_LENH_RUT' });
  });

  it('lối không có trong ba lối kia bị chặn trước khi ghi gì', async () => {
    const { service, daDoi, soVi } = dungLenhRut(WithdrawalStatus.PENDING);

    await expect(
      service.doiTrangThai('wd-1', { status: 'DONE' }, 'admin-1'),
    ).rejects.toMatchObject({
      response: { code: 'TRANG_THAI_KHONG_HOP_LE' },
    });
    expect(daDoi).toHaveLength(0);
    expect(soVi).toHaveLength(0);
  });

  it('đánh dấu đã chuyển mà bỏ trống mã tham chiếu thì không ghi gì', async () => {
    const { service, daDoi } = dungLenhRut(WithdrawalStatus.PENDING);

    await expect(
      service.doiTrangThai('wd-1', { status: 'SENT' }, 'admin-1'),
    ).rejects.toMatchObject({ response: { code: 'THIEU_MA_THAM_CHIEU' } });
    expect(daDoi).toHaveLength(0);
  });
});

describe('Lý do hoàn suy từ con số, không từ chuỗi lý do huỷ', () => {
  it('có kết luận khiếu nại kèm khoản hoàn thì là nhánh khiếu nại', () => {
    const don = {
      totalPrice: 180000,
      cancellationFee: 90000,
      ketLuan: { refundAmount: 120000 },
    };

    expect(suyLyDoHoan(don)).toBe('DISPUTE_RESOLUTION');
    expect(tinhTienHoan(don, 'DISPUTE_RESOLUTION', 180000)).toBe(120000);
  });

  it('có phí huỷ muộn thì hoàn phần còn lại của giá đơn', () => {
    const don = {
      totalPrice: 180000,
      cancellationFee: 90000,
      ketLuan: null,
    };

    expect(suyLyDoHoan(don)).toBe('LATE_CANCEL');
    expect(tinhTienHoan(don, 'LATE_CANCEL', 180000)).toBe(90000);
  });

  it('không phí huỷ và không kết luận thì hoàn trọn giá đơn', () => {
    const don = { totalPrice: 180000, cancellationFee: null, ketLuan: null };

    expect(suyLyDoHoan(don)).toBe('FULL_CANCEL');
    expect(tinhTienHoan(don, 'FULL_CANCEL', 180000)).toBe(180000);
  });

  it('kết luận hoàn 0 đồng là bác khiếu nại, không phải nhánh khiếu nại', () => {
    const don = {
      totalPrice: 180000,
      cancellationFee: null,
      ketLuan: { refundAmount: 0 },
    };

    expect(suyLyDoHoan(don)).toBe('FULL_CANCEL');
  });

  it('số hoàn không bao giờ vượt số chủ nuôi đã trả', () => {
    const don = { totalPrice: 500000, cancellationFee: null, ketLuan: null };

    expect(tinhTienHoan(don, 'FULL_CANCEL', 180000)).toBe(180000);
  });
});

type SoLieuKy = {
  totalPrice: number | null;
  platformFee: number | null;
  count: number;
  giu: number | null;
};

function dungTongQuan(nay: SoLieuKy, truoc: SoLieuKy) {
  const luot: string[] = [];
  const theoKy = [nay, truoc];
  let lanDon = 0;
  let lanKhoan = 0;

  const prisma = {
    booking: {
      aggregate: () => {
        const ky = theoKy[lanDon];
        lanDon += 1;
        luot.push('booking.aggregate');
        return Promise.resolve({
          _sum: { totalPrice: ky.totalPrice, platformFee: ky.platformFee },
          _count: ky.count,
        });
      },
    },
    payment: {
      groupBy: () => {
        const ky = theoKy[lanKhoan];
        lanKhoan += 1;
        luot.push('payment.groupBy');
        return Promise.resolve(
          ky.giu === null
            ? []
            : [
                {
                  status: PaymentStatus.HELD,
                  _sum: { amount: ky.giu },
                  _count: 1,
                },
              ],
        );
      },
    },
    $queryRaw: () => {
      luot.push('queryRaw');
      return Promise.resolve([]);
    },
  };
  const thamSo = { so: () => 15 };

  const service = new AdminFinanceSummaryService(
    prisma as unknown as PrismaService,
    thamSo as unknown as SystemSettingsService,
  );
  return { service, luot };
}

const KY_RONG: SoLieuKy = {
  totalPrice: null,
  platformFee: null,
  count: 0,
  giu: null,
};
const KY_CO_SO: SoLieuKy = {
  totalPrice: 1000000,
  platformFee: 150000,
  count: 4,
  giu: 300000,
};

describe('Bốn chỉ số doanh thu và mức so kỳ trước', () => {
  it('kỳ trước không có dữ liệu thì trả null chứ không phải 0', async () => {
    const { service } = dungTongQuan(KY_CO_SO, KY_RONG);

    const ket = await service.tongQuan({});

    expect(ket.deltas).toEqual({
      totalOrderValue: null,
      commission: null,
      escrowHeld: null,
      releasedToWallet: null,
    });
    expect(ket.totalOrderValue).toBe(1000000);
    expect(ket.escrowHeld).toBe(300000);
  });

  it('kỳ trước có dữ liệu thì trả phần trăm chênh lệch', async () => {
    const { service } = dungTongQuan(KY_CO_SO, {
      totalPrice: 500000,
      platformFee: 150000,
      count: 2,
      giu: 600000,
    });

    const ket = await service.tongQuan({});

    expect(ket.deltas.totalOrderValue).toBe(100);
    expect(ket.deltas.commission).toBe(0);
    expect(ket.deltas.escrowHeld).toBe(-50);
  });

  it('tỷ lệ hoa hồng đọc từ cấu hình, cả màn chỉ tốn sáu lượt đi về', async () => {
    const { service, luot } = dungTongQuan(KY_CO_SO, KY_RONG);

    const ket = await service.tongQuan({});

    expect(ket.commissionRate).toBe(15);
    expect(luot).toHaveLength(6);
  });
});
