import { ConflictException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { AnhTaiLenService } from '../src/modules/media/anh-tai-len.service';
import { DisputeService } from '../src/modules/wallet/dispute.service';
import { HAN_PHAN_DOI_HOURS } from '../src/modules/bookings/booking-compensation';
import { anhKyGia } from './anh-ky-gia';

const CHU_NUOI = 'u-chu-nuoi';
const NGUOI_CHAM = 'u-ncc';
const GIO_MS = 3_600_000;

type Don = {
  status: string;
  startedAt?: Date | null;
  endedAt?: Date | null;
  cancelledAt?: Date | null;
  escrowReleaseAt?: Date | null;
};

function dungGhi(don: Don | null, soHoSoCu = 0, coHoSoMo = false) {
  const daTao: Array<Record<string, unknown>> = [];
  const prisma = {
    daTao,
    sitter: {
      findUnique: () =>
        Promise.resolve({ id: 'ncc-1', userId: NGUOI_CHAM, bannedAt: null }),
    },
    booking: {
      findFirst: () =>
        Promise.resolve(
          don
            ? {
                id: 'don-1',
                code: 'PC-001',
                status: don.status,
                startedAt: don.startedAt ?? null,
                endedAt: don.endedAt ?? null,
                cancelledAt: don.cancelledAt ?? null,
                escrowReleaseAt: don.escrowReleaseAt ?? null,
              }
            : null,
        ),
    },
    violationReport: {
      findFirst: () => Promise.resolve(coHoSoMo ? { id: 'hs-cu' } : null),
      count: () => Promise.resolve(soHoSoCu),
      create: (arg: { data: Record<string, unknown> }) => {
        daTao.push(arg.data);
        return Promise.resolve({
          id: 'hs-1',
          code: arg.data.code,
          status: 'OPEN',
        });
      },
    },
  };
  const anhTaiLen = {
    dayLen: (_b: string, _t: string, files: unknown[]) =>
      Promise.resolve(files.map((_, i) => `https://kho/kn-${i}.jpg`)),
  };
  const service = new DisputeService(
    prisma as unknown as PrismaService,
    anhTaiLen as unknown as AnhTaiLenService,
    anhKyGia().service,
  );
  return { service, prisma };
}

describe('Chủ nuôi phản đối khi bị báo vắng mặt', () => {
  it('mở được hồ sơ trong hạn dù đơn không có endedAt', async () => {
    const { service, prisma } = dungGhi({
      status: 'CANCELLED_NO_SHOW',
      cancelledAt: new Date(Date.now() - 2 * GIO_MS),
    });

    const ket = await service.mo(CHU_NUOI, 'don-1', {
      description: 'Tôi có mặt ở nhà suốt, không ai bấm chuông',
    });

    expect(ket.code).toBe('KN-001');
    expect(prisma.daTao[0]).toMatchObject({ reporterId: CHU_NUOI });
  });

  it('quá hạn phản đối thì chặn, và câu lỗi đếm từ lúc khép đơn', async () => {
    const { service } = dungGhi({
      status: 'CANCELLED_NO_SHOW',
      cancelledAt: new Date(Date.now() - (HAN_PHAN_DOI_HOURS + 1) * GIO_MS),
    });

    await expect(
      service.mo(CHU_NUOI, 'don-1', { description: 'Phản đối muộn' }),
    ).rejects.toMatchObject({ response: { code: 'QUA_HAN_PHAN_DOI' } });
  });

  it('hạn đếm từ cancelledAt chứ không phải endedAt', async () => {
    // endedAt để rỗng đúng như khepDon đang ghi: phiên vắng mặt chưa từng chạy
    const { service } = dungGhi({
      status: 'CANCELLED_NO_SHOW',
      endedAt: null,
      cancelledAt: new Date(Date.now() - (HAN_PHAN_DOI_HOURS - 1) * GIO_MS),
    });

    await expect(
      service.mo(CHU_NUOI, 'don-1', { description: 'Vẫn còn trong hạn' }),
    ).resolves.toMatchObject({ status: 'OPEN' });
  });

  it('đơn thường vẫn đòi endedAt như cũ', async () => {
    const { service } = dungGhi({ status: 'COMPLETED', endedAt: null });

    await expect(
      service.mo(CHU_NUOI, 'don-1', { description: 'Đơn chưa xong' }),
    ).rejects.toMatchObject({ response: { code: 'DON_CHUA_KET_THUC' } });
  });
});

describe('Người chăm báo sự cố', () => {
  it('phiên đang chạy thì mở được hồ sơ, không cần ảnh', async () => {
    const { service, prisma } = dungGhi({
      status: 'IN_PROGRESS',
      startedAt: new Date(Date.now() - GIO_MS),
    });

    const ket = await service.moBoiNguoiCham(
      NGUOI_CHAM,
      'don-1',
      'Bé giật dây chạy mất, tôi đang đi tìm',
      [],
    );

    expect(ket.status).toBe('OPEN');
    expect(prisma.daTao[0]).toMatchObject({
      reporterId: NGUOI_CHAM,
      evidenceUrls: [],
    });
    // Không đặt hạn đáp lại: hồ sơ này do chính người chăm mở
    expect(prisma.daTao[0].replyDeadline).toBeUndefined();
  });

  it('phiên chưa bắt đầu thì chặn, đó là việc của huỷ hoặc thiếu dụng cụ', async () => {
    const { service } = dungGhi({ status: 'CONFIRMED', startedAt: null });

    await expect(
      service.moBoiNguoiCham(NGUOI_CHAM, 'don-1', 'Xe tôi hỏng giữa đường', []),
    ).rejects.toMatchObject({ response: { code: 'PHIEN_CHUA_CHAY' } });
  });

  it('quá hạn giữ tiền thì hết cửa báo sự cố', async () => {
    const { service } = dungGhi({
      status: 'COMPLETED',
      startedAt: new Date(Date.now() - 50 * GIO_MS),
      endedAt: new Date(Date.now() - 49 * GIO_MS),
      escrowReleaseAt: new Date(Date.now() - GIO_MS),
    });

    await expect(
      service.moBoiNguoiCham(NGUOI_CHAM, 'don-1', 'Báo muộn quá hạn', []),
    ).rejects.toThrow(ConflictException);
  });

  it('đơn đang có hồ sơ mở thì không mở thêm cái nữa', async () => {
    const { service } = dungGhi(
      { status: 'IN_PROGRESS', startedAt: new Date() },
      1,
      true,
    );

    await expect(
      service.moBoiNguoiCham(NGUOI_CHAM, 'don-1', 'Mở lần hai', []),
    ).rejects.toMatchObject({ response: { code: 'DA_CO_KHIEU_NAI' } });
  });

  it('đơn từng có hồ sơ đã khép thì mã mới không trùng mã cũ', async () => {
    const { service } = dungGhi(
      { status: 'IN_PROGRESS', startedAt: new Date() },
      1,
      false,
    );

    const ket = await service.moBoiNguoiCham(
      NGUOI_CHAM,
      'don-1',
      'Sự cố thứ hai của đơn này',
      [],
    );

    expect(ket.code).toBe('KN-001-2');
  });
});

describe('Lượt đáp của người chăm', () => {
  function dungDap(hs: {
    reporterId: string;
    sitterReplyAt?: Date | null;
    replyDeadline?: Date | null;
  }) {
    const prisma = {
      sitter: {
        findUnique: () =>
          Promise.resolve({ id: 'ncc-1', userId: NGUOI_CHAM, bannedAt: null }),
      },
      violationReport: {
        findUnique: () =>
          Promise.resolve({
            id: 'hs-1',
            status: 'OPEN',
            reporterId: hs.reporterId,
            sitterReplyAt: hs.sitterReplyAt ?? null,
            replyDeadline: hs.replyDeadline ?? null,
            bookingId: 'don-1',
            booking: { sitterId: 'ncc-1' },
          }),
      },
    };
    const anhTaiLen = { dayLen: () => Promise.resolve([]) };
    return new DisputeService(
      prisma as unknown as PrismaService,
      anhTaiLen as unknown as AnhTaiLenService,
      anhKyGia().service,
    );
  }

  it('hồ sơ do chính người chăm mở thì không có lượt đáp (bộ luật mục 7)', async () => {
    const service = dungDap({ reporterId: NGUOI_CHAM });

    await expect(
      service.phanHoi(NGUOI_CHAM, 'KN-001', {
        content: 'Tôi xin bổ sung thêm tình tiết',
      }),
    ).rejects.toMatchObject({
      response: { code: 'HO_SO_TU_MO_KHONG_CO_LUOT_DAP' },
    });
  });

  it('hồ sơ do chủ nuôi mở đã đáp rồi thì không đáp lần hai', async () => {
    const service = dungDap({
      reporterId: CHU_NUOI,
      sitterReplyAt: new Date(),
    });

    await expect(
      service.phanHoi(NGUOI_CHAM, 'KN-001', { content: 'Đáp lần thứ hai' }),
    ).rejects.toMatchObject({ response: { code: 'DA_PHAN_HOI' } });
  });
});
