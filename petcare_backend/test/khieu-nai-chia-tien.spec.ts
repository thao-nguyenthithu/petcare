import { AdminRefundsReadService } from '../src/modules/admin/finance/admin-refunds-read.service';
import {
  suyLyDoHoan,
  tinhTienHoan,
} from '../src/modules/admin/finance/hoan-tien-chung';
import { AnhTaiLenService } from '../src/modules/media/anh-tai-len.service';
import { DisputeService } from '../src/modules/wallet/dispute.service';
import { WalletLedgerService } from '../src/modules/wallet/wallet-ledger.service';
import { PrismaService } from '../src/prisma/prisma.service';
import { anhKyGia } from './anh-ky-gia';
import { dungKetLuan } from './khieu-nai-gia';
import { NEN_TANG } from './tham-so-mac-dinh';

const KET_LUAN_GOC = {
  resolution: 'Người chăm về sớm hơn giờ đã hẹn',
  resolutionReason: 'Log GPS cho thấy phiên ngắn hơn 25 phút',
  refundAmount: 0,
};

const DON = {
  status: 'REVIEWING',
  totalPrice: 500_000,
  platformFeePercent: 15,
};

describe('Kết luận có hoàn tiền thì tiền rời chỗ giữ ngay trong cùng transaction', () => {
  it('hoàn một phần: khoản giữ sang REFUNDING, ví nhận phần còn lại sau phễu', async () => {
    const { service, khoanDoi, donDoi, dongVi } = dungKetLuan(DON);

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, refundAmount: 200_000 },
      'admin-1',
    );

    expect(khoanDoi[0].data).toEqual({ status: 'REFUNDING' });
    expect(donDoi[0]).toEqual({ sitterPayout: 255_000, platformFee: 45_000 });
    expect(dongVi[0]).toMatchObject({
      kind: 'TIEN_VAO',
      amount: 255_000,
      bookingId: 'don-1',
      disputeCode: 'KN-PC001',
    });
  });

  it('ba phần cộng lại khớp tuyệt đối với số chủ nuôi đã trả', async () => {
    const { service, donDoi } = dungKetLuan(DON);

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, refundAmount: 200_000 },
      'admin-1',
    );

    const chia = donDoi[0] as { sitterPayout: number; platformFee: number };
    expect(200_000 + chia.platformFee + chia.sitterPayout).toBe(DON.totalPrice);
  });

  it('phí nền tảng làm tròn XUỐNG, phần lẻ về người chăm (bộ luật mục 2)', async () => {
    // Nhân trước chia sau: 11400 * (29/100) dạng số thực cho ra 3305, đáp số đúng là 3306
    const { service, donDoi } = dungKetLuan({
      status: 'OPEN',
      totalPrice: 20_000,
      platformFeePercent: 29,
    });

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, refundAmount: 8_600 },
      'admin-1',
    );

    expect(donDoi[0]).toEqual({ sitterPayout: 8_094, platformFee: 3_306 });
  });

  it('đơn chưa đóng băng phần trăm thì rơi về mặc định bộ khai', async () => {
    const { service, donDoi } = dungKetLuan({
      status: 'OPEN',
      totalPrice: 500_000,
      platformFeePercent: null,
    });

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, refundAmount: 100_000 },
      'admin-1',
    );

    const nenTang = Math.floor((400_000 * NEN_TANG) / 100);
    expect(donDoi[0]).toEqual({
      sitterPayout: 400_000 - nenTang,
      platformFee: nenTang,
    });
  });

  it('hoàn toàn phần thì người chăm nhận 0 và ví không có dòng nào', async () => {
    const { service, khoanDoi, donDoi, dongVi } = dungKetLuan(DON);

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, refundAmount: 500_000 },
      'admin-1',
    );

    expect(khoanDoi[0].data).toEqual({ status: 'REFUNDING' });
    expect(donDoi[0]).toEqual({ sitterPayout: 0, platformFee: 0 });
    expect(dongVi).toHaveLength(0);
  });

  it('bác khiếu nại thì không đụng khoản giữ, để escrow nhả như thường', async () => {
    const { service, khoanDoi, donDoi, dongVi, daCapNhat, luotDocKhoan } =
      dungKetLuan(DON);

    await service.ketLuan('KN-PC001', KET_LUAN_GOC, 'admin-1');

    expect(daCapNhat[0]).toMatchObject({ status: 'RESOLVED', refundAmount: 0 });
    expect(khoanDoi).toHaveLength(0);
    expect(donDoi).toHaveLength(0);
    expect(dongVi).toHaveLength(0);
    // Nhánh không đụng tiền thì cũng không được tốn thêm lượt đi về nào
    expect(luotDocKhoan).toHaveLength(0);
  });

  it('nhật ký ghi cả phần người chăm nhận, không chỉ khoản hoàn', async () => {
    const { service, nhatKy } = dungKetLuan(DON);

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, refundAmount: 200_000 },
      'admin-1',
    );

    expect(nhatKy[0].newValue).toContain('hoan=200000');
    expect(nhatKy[0].newValue).toContain('nccNhan=255000');
  });
});

describe('Chống ghi ví hai lượt khi hai quản trị viên bấm cùng lúc', () => {
  it('kẹp HELD vào where của khoản giữ', async () => {
    const { service, khoanDoi } = dungKetLuan(DON);

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, refundAmount: 200_000 },
      'admin-1',
    );

    expect(khoanDoi[0].where).toMatchObject({ id: 'pay-1', status: 'HELD' });
  });

  it('lượt sau thấy khoản giữ đã bị lấy thì dừng, không ghi ví lần hai', async () => {
    const { service, dongVi, donDoi, nhatKy } = dungKetLuan(DON, {
      soDongKhoan: 0,
    });

    await expect(
      service.ketLuan(
        'KN-PC001',
        { ...KET_LUAN_GOC, refundAmount: 200_000 },
        'admin-1',
      ),
    ).rejects.toMatchObject({ response: { code: 'KHONG_CON_KHOAN_GIU' } });
    expect(dongVi).toHaveLength(0);
    expect(donDoi).toHaveLength(0);
    expect(nhatKy).toHaveLength(0);
  });

  it('lượt sau thấy hồ sơ đã chốt thì dừng trước cả khi đụng tiền', async () => {
    const { service, khoanDoi, dongVi } = dungKetLuan(DON, { soDongDoi: 0 });

    await expect(
      service.ketLuan(
        'KN-PC001',
        { ...KET_LUAN_GOC, refundAmount: 200_000 },
        'admin-1',
      ),
    ).rejects.toMatchObject({ response: { code: 'HO_SO_DA_KET_LUAN' } });
    expect(khoanDoi).toHaveLength(0);
    expect(dongVi).toHaveLength(0);
  });

  it('đơn không còn khoản giữ thì từ chối chốt, không ghi con số chết vào hồ sơ', async () => {
    const { service, daCapNhat, dongVi } = dungKetLuan({
      ...DON,
      khoanGiu: null,
    });

    await expect(
      service.ketLuan(
        'KN-PC001',
        { ...KET_LUAN_GOC, refundAmount: 200_000 },
        'admin-1',
      ),
    ).rejects.toMatchObject({ response: { code: 'KHONG_CON_KHOAN_GIU' } });
    expect(daCapNhat).toHaveLength(0);
    expect(dongVi).toHaveLength(0);
  });

  it('không còn khoản giữ mà bác khiếu nại thì vẫn chốt được', async () => {
    const { service, daCapNhat } = dungKetLuan({ ...DON, khoanGiu: null });

    await service.ketLuan('KN-PC001', KET_LUAN_GOC, 'admin-1');

    expect(daCapNhat[0]).toMatchObject({ status: 'RESOLVED' });
  });
});

function dungEscrow(trangThaiKhoan: string) {
  const dongVi: Array<Record<string, unknown>> = [];
  const prisma = {
    booking: {
      findUnique: () =>
        Promise.resolve({
          id: 'don-1',
          code: 'PC001',
          sitterId: 'ncc-1',
          sitterPayout: 255_000,
          totalPrice: 500_000,
          platformFee: 45_000,
          owner: { fullName: 'Chủ nuôi A' },
          reports: [],
        }),
    },
    payment: {
      findFirst: (arg: { where: { status: string } }) =>
        Promise.resolve(
          arg.where.status === trangThaiKhoan
            ? { id: 'pay-1', amount: 500_000 }
            : null,
        ),
      updateMany: () => Promise.resolve({ count: 1 }),
    },
    wallet: {
      upsert: () => Promise.resolve({ id: 'vi-1', balance: 255_000 }),
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
  return { soVi, dongVi };
}

describe('Escrow không nhả chồng lượt lên khoản đã quyết hoàn', () => {
  it('đơn còn HELD thì nhả bình thường', async () => {
    const { soVi, dongVi } = dungEscrow('HELD');

    await expect(soVi.nhaEscrow('don-1')).resolves.toBe(true);
    expect(dongVi).toHaveLength(1);
  });

  it('đơn đang REFUNDING thì không nhả đồng nào', async () => {
    const { soVi, dongVi } = dungEscrow('REFUNDING');

    await expect(soVi.nhaEscrow('don-1')).resolves.toBe(false);
    expect(dongVi).toHaveLength(0);
  });
});

describe('Đơn đi qua kết luận khiếu nại hiện ra ở màn hoàn tiền', () => {
  const KHOAN = {
    txnRef: 'PC001-1',
    gatewayTxnNo: '14567890',
    gatewayPayDate: '20260807101500',
    bankCode: 'NCB',
    cardType: 'ATM',
    amount: 500_000,
    status: 'REFUNDING',
    refundReference: null,
    refundNote: null,
    refundedAt: null,
    updatedAt: new Date('2026-08-07T10:20:00.000Z'),
    booking: {
      id: 'don-1',
      code: 'PC001',
      totalPrice: 500_000,
      cancellationFee: null,
      cancelledAt: null,
      cancellationReason: null,
      cancellationNote: null,
      owner: { fullName: 'Chủ nuôi A', phone: '0900000000' },
      reports: [
        {
          resolvedAt: new Date('2026-08-07T10:20:00.000Z'),
          refundAmount: 200_000,
        },
      ],
    },
  };

  it('suy đúng lý do DISPUTE_RESOLUTION và đúng khoản hoàn', () => {
    const nguon = {
      totalPrice: 500_000,
      cancellationFee: null,
      ketLuan: { refundAmount: 200_000 },
    };

    expect(suyLyDoHoan(nguon)).toBe('DISPUTE_RESOLUTION');
    expect(tinhTienHoan(nguon, 'DISPUTE_RESOLUTION', 500_000)).toBe(200_000);
  });

  it('dòng ở GET /admin/refunds mang đúng lý do và số tiền hoàn', async () => {
    const prisma = {
      payment: {
        count: () => Promise.resolve(1),
        findMany: () => Promise.resolve([KHOAN]),
      },
    };
    const service = new AdminRefundsReadService(
      prisma as unknown as PrismaService,
    );

    const trang = await service.danhSach({});

    expect(trang.items[0]).toMatchObject({
      bookingCode: 'PC001',
      reason: 'DISPUTE_RESOLUTION',
      amount: 200_000,
      paymentAmount: 500_000,
      status: 'REFUNDING',
    });
  });
});

const NGUOI_CHAM = 'user-ncc';

function dungHoSoNcc(chia: {
  sitterPayout: number | null;
  platformFee: number;
  refundAmount: number | null;
}) {
  const prisma = {
    violationReport: {
      findUnique: () =>
        Promise.resolve({
          code: 'KN-PC001',
          status: chia.refundAmount === null ? 'REVIEWING' : 'RESOLVED',
          description: 'Phiên ngắn hơn giờ đã hẹn',
          evidenceUrls: [],
          sitterReply: null,
          sitterReplyAt: null,
          sitterReplyPhotos: [],
          replyDeadline: null,
          resolution: null,
          resolutionReason: null,
          refundAmount: chia.refundAmount,
          resolvedAt: chia.refundAmount === null ? null : new Date(),
          createdAt: new Date(),
          booking: {
            id: 'don-1',
            code: 'PC001',
            status: 'COMPLETED',
            scheduledAt: new Date(),
            scheduledEndAt: new Date(),
            endedAt: new Date(),
            durationMinutes: 60,
            totalPrice: 500_000,
            sitterPayout: chia.sitterPayout,
            platformFee: chia.platformFee,
            priceBreakdown: null,
            cancellationReason: null,
            owner: { fullName: 'Chủ nuôi A' },
            service: { name: 'Dắt đi dạo', type: 'WALKING' },
            pets: [{ pet: { name: 'Mun', species: 'DOG' } }],
            ownerId: 'user-owner',
            sitter: { userId: NGUOI_CHAM },
          },
        }),
    },
  };
  return new DisputeService(
    prisma as unknown as PrismaService,
    { dayLen: () => Promise.resolve([]) } as unknown as AnhTaiLenService,
    anhKyGia().service,
  );
}

describe('Bảng tiền hồ sơ khiếu nại bên người chăm', () => {
  it('chưa có kết luận thì cộng đúng bằng số chủ nuôi đã trả', async () => {
    const service = dungHoSoNcc({
      sitterPayout: null,
      platformFee: 75_000,
      refundAmount: null,
    });

    const hs = await service.theoMa(NGUOI_CHAM, 'KN-PC001');

    expect(hs.cacDongTien.map((d) => d.tien)).toEqual([500_000, -75_000, -0]);
    expect(hs.tongCuoi.tien).toBe(425_000);
  });

  it('sau kết luận thì đọc phần đã đóng băng, KHÔNG trừ khoản hoàn lần nữa', async () => {
    const service = dungHoSoNcc({
      sitterPayout: 255_000,
      platformFee: 45_000,
      refundAmount: 200_000,
    });

    const hs = await service.theoMa(NGUOI_CHAM, 'KN-PC001');

    expect(hs.cacDongTien.map((d) => d.tien)).toEqual([
      500_000, -45_000, -200_000,
    ]);
    expect(hs.tongCuoi.tien).toBe(255_000);
  });
});
