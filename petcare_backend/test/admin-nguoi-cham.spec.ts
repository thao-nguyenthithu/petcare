import { BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { AdminSittersWriteService } from '../src/modules/admin/sitters/admin-sitters-write.service';
import { AdminPenaltiesService } from '../src/modules/admin/sitters/admin-penalties.service';
import { SitterPenaltyService } from '../src/modules/bookings/sitter-penalty.service';
import { NotificationsService } from '../src/modules/notifications/notifications.service';
import { SystemSettingsService } from '../src/modules/admin/system-settings.service';

const ADMIN_ID = 'admin-1';

type HoSo = {
  status: string;
  hiddenUntil: Date | null;
  hiddenCount: number;
  bannedAt: Date | null;
};

const DA_DUYET: HoSo = {
  status: 'APPROVED',
  hiddenUntil: null,
  hiddenCount: 0,
  bannedAt: null,
};

function dungGhi(
  hoSo: HoSo | null,
  soDonDangChay = 0,
  soMocAn = 0,
  soDongDoi = 1,
) {
  const nhatKy: Array<Record<string, unknown>> = [];
  const daCapNhat: Array<Record<string, unknown>> = [];
  const dieuKienGhi: Array<Record<string, unknown>> = [];
  const tinDaGui: Array<Record<string, unknown>> = [];
  const daMien: Array<Record<string, unknown>> = [];
  const prisma = {
    nhatKy,
    daCapNhat,
    dieuKienGhi,
    sitterPenalty: {
      updateMany: (arg: Record<string, unknown>) => {
        daMien.push(arg);
        return Promise.resolve({ count: soMocAn });
      },
    },
    sitter: {
      findUnique: () =>
        Promise.resolve(
          hoSo
            ? { id: 'ncc-1', userId: 'u-ncc', legalName: 'Nam', ...hoSo }
            : null,
        ),
      updateMany: (arg: {
        where: Record<string, unknown>;
        data: Record<string, unknown>;
      }) => {
        dieuKienGhi.push(arg.where);
        if (soDongDoi === 0) return Promise.resolve({ count: 0 });
        daCapNhat.push(arg.data);
        return Promise.resolve({ count: soDongDoi });
      },
      update: (arg: { data: Record<string, unknown> }) => {
        daCapNhat.push(arg.data);
        return Promise.resolve({ id: 'ncc-1', hiddenCount: 1 });
      },
    },
    booking: { count: () => Promise.resolve(soDonDangChay) },
    adminAuditLog: {
      create: (arg: { data: Record<string, unknown> }) => {
        nhatKy.push(arg.data);
        return { __lenh: 'audit' };
      },
    },
    $transaction: (lenh: unknown) =>
      typeof lenh === 'function'
        ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
        : Promise.resolve(lenh),
  };
  const phat = {
    tamAn: (
      _id: string,
      _luc: number,
      _lyDo: string,
      _db: unknown,
      soNgay?: number,
    ) =>
      Promise.resolve({
        soNgay: soNgay ?? 3,
        khoa: false,
        hiddenCount: (hoSo?.hiddenCount ?? 0) + 1,
        soLanAnGanDay: 1,
      }),
  };
  const service = new AdminSittersWriteService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
    phat as unknown as SitterPenaltyService,
    {
      tao: (tin: Record<string, unknown>) => {
        tinDaGui.push(tin);
        return Promise.resolve({ id: 'tin-1' });
      },
    } as unknown as NotificationsService,
  );
  return {
    service,
    prisma,
    nhatKy,
    daCapNhat,
    dieuKienGhi,
    tinDaGui,
    daMien,
  };
}

const SAU_MOT_NGAY = () => new Date(Date.now() + 86_400_000);

describe('Tạm ẩn hồ sơ người chăm bằng tay', () => {
  it('ép đúng số ngày quản trị viên chọn', async () => {
    const { service } = dungGhi(DA_DUYET);
    const ket = await service.tamAn('ncc-1', 7, 'nhiều khiếu nại', ADMIN_ID);
    expect(ket.hiddenDays).toBe(7);
  });

  it('nhật ký ghi rõ lần thứ mấy và số đơn đang chạy', async () => {
    const { service, nhatKy } = dungGhi({ ...DA_DUYET, hiddenCount: 2 }, 3);
    await service.tamAn('ncc-1', 7, 'nhiều khiếu nại', ADMIN_ID);
    expect(nhatKy[0]).toMatchObject({
      action: 'TAM_AN_HO_SO_NCC',
      targetType: 'SITTER',
      reason: 'nhiều khiếu nại',
      newValue: 'days=7|lanThu=3|donDangChay=3|khoaHan=false',
    });
  });

  it('trả số đơn đang chạy để dialog cảnh báo trước', async () => {
    const { service } = dungGhi(DA_DUYET, 2);
    const ket = await service.tamAn('ncc-1', 3, 'thử', ADMIN_ID);
    expect(ket.runningBookingCount).toBe(2);
  });

  it('hồ sơ đã khoá vĩnh viễn thì không tạm ẩn được nữa', async () => {
    const { service } = dungGhi({ ...DA_DUYET, bannedAt: new Date() });
    await expect(
      service.tamAn('ncc-1', 3, 'thử', ADMIN_ID),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('hồ sơ đang trong hạn tạm ẩn thì không ẩn chồng thêm được', async () => {
    const { service } = dungGhi({ ...DA_DUYET, hiddenUntil: SAU_MOT_NGAY() });
    await expect(
      service.tamAn('ncc-1', 3, 'thử', ADMIN_ID),
    ).rejects.toMatchObject({
      response: { code: 'HO_SO_DANG_BI_TAM_AN' },
    });
  });

  it('hết hạn tạm ẩn rồi thì ẩn tiếp được', async () => {
    const { service } = dungGhi({
      ...DA_DUYET,
      hiddenUntil: new Date(Date.now() - 86_400_000),
    });
    const ket = await service.tamAn('ncc-1', 3, 'thử', ADMIN_ID);
    expect(ket.hiddenDays).toBe(3);
  });

  it('không có hồ sơ thì báo không tìm thấy', async () => {
    const { service } = dungGhi(null);
    await expect(
      service.tamAn('ncc-1', 3, 'thử', ADMIN_ID),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('báo cho người chăm biết đơn đã nhận vẫn phải hoàn thành', async () => {
    const { service, tinDaGui } = dungGhi(DA_DUYET);
    await service.tamAn('ncc-1', 7, 'thử', ADMIN_ID);
    expect(String(tinDaGui[0].body)).toContain(
      'đơn đã nhận vẫn phải hoàn thành',
    );
  });
});

describe('Khoá vĩnh viễn và gỡ khoá', () => {
  it('khoá thì ghi mốc và ghi nhật ký', async () => {
    const { service, daCapNhat, nhatKy } = dungGhi(DA_DUYET);
    const ket = await service.datKhoaVinhVien(
      'ncc-1',
      true,
      'gian lận',
      ADMIN_ID,
    );
    expect(ket.banned).toBe(true);
    expect(daCapNhat[0].bannedAt).toBeInstanceOf(Date);
    expect(nhatKy[0]).toMatchObject({ action: 'KHOA_HO_SO_NCC' });
  });

  it('gỡ khoá xoá cả mốc tạm ẩn, không để người được gỡ vẫn biến mất', async () => {
    const { service, daCapNhat, nhatKy } = dungGhi({
      ...DA_DUYET,
      bannedAt: new Date(),
      hiddenUntil: SAU_MOT_NGAY(),
    });
    await service.datKhoaVinhVien('ncc-1', false, 'nhầm người', ADMIN_ID);
    expect(daCapNhat[0]).toEqual({ bannedAt: null, hiddenUntil: null });
    expect(nhatKy[0]).toMatchObject({ action: 'GO_KHOA_HO_SO_NCC' });
  });

  it('gỡ khoá miễn luôn các mốc ẩn trong cửa sổ, không thì ẩn tay lần sau khoá lại ngay', async () => {
    const { service, daMien } = dungGhi(
      { ...DA_DUYET, bannedAt: new Date(), hiddenCount: 4 },
      0,
      4,
    );
    const ket = await service.datKhoaVinhVien(
      'ncc-1',
      false,
      'nhầm người',
      ADMIN_ID,
    );
    expect(daMien[0].where).toMatchObject({
      sitterId: 'ncc-1',
      kind: 'HIDE',
      status: { not: 'WAIVED' },
    });
    expect(daMien[0].data).toMatchObject({ status: 'WAIVED' });
    expect(ket.waivedHides).toBe(4);
  });

  it('chỉ miễn mốc ẩn trong sáu tháng, mốc cũ hơn để nguyên làm hồ sơ', async () => {
    const { service, daMien } = dungGhi({ ...DA_DUYET, bannedAt: new Date() });
    await service.datKhoaVinhVien('ncc-1', false, 'nhầm người', ADMIN_ID);
    const moc = (daMien[0].where as { createdAt: { gte: Date } }).createdAt.gte;
    const soNgay = (Date.now() - moc.getTime()) / 86_400_000;
    expect(Math.round(soNgay)).toBe(180);
  });

  it('nhật ký ghi số mốc vừa miễn để soát lại được', async () => {
    const { service, nhatKy } = dungGhi(
      { ...DA_DUYET, bannedAt: new Date() },
      2,
      3,
    );
    await service.datKhoaVinhVien('ncc-1', false, 'nhầm người', ADMIN_ID);
    expect(nhatKy[0]).toMatchObject({
      action: 'GO_KHOA_HO_SO_NCC',
      newValue: 'false|mienMocAn=3|donDangChay=2',
    });
  });

  it('khoá thì KHÔNG đụng tới mốc ẩn nào', async () => {
    const { service, daMien } = dungGhi(DA_DUYET);
    await service.datKhoaVinhVien('ncc-1', true, 'gian lận', ADMIN_ID);
    expect(daMien).toHaveLength(0);
  });

  it('khoá lại hồ sơ đã khoá thì không ghi thêm nhật ký', async () => {
    const { service, nhatKy } = dungGhi({ ...DA_DUYET, bannedAt: new Date() });
    await service.datKhoaVinhVien('ncc-1', true, 'thử', ADMIN_ID);
    expect(nhatKy).toHaveLength(0);
  });

  it('nói rõ bị khoá hồ sơ vẫn đăng nhập và đặt dịch vụ được', async () => {
    const { service, tinDaGui } = dungGhi(DA_DUYET);
    await service.datKhoaVinhVien('ncc-1', true, 'gian lận', ADMIN_ID);
    expect(String(tinDaGui[0].body)).toContain('như chủ nuôi');
  });

  it('người khác khoá xen vào thì dừng, không bắn tin lần thứ hai', async () => {
    // Kẹp mốc khoá cũ vào where: thiếu thì hai lượt cùng lúc gửi hai tin cho người chăm
    const { service, dieuKienGhi, nhatKy, tinDaGui } = dungGhi(
      DA_DUYET,
      0,
      0,
      0,
    );

    await expect(
      service.datKhoaVinhVien('ncc-1', true, 'gian lận', ADMIN_ID),
    ).rejects.toMatchObject({ response: { code: 'TRANG_THAI_KHONG_HOP_LE' } });
    expect(dieuKienGhi[0]).toEqual({ id: 'ncc-1', bannedAt: null });
    expect(nhatKy).toHaveLength(0);
    expect(tinDaGui).toHaveLength(0);
  });

  it('người khác gỡ khoá xen vào thì dừng, không miễn mốc ẩn lần thứ hai', async () => {
    const { service, dieuKienGhi, daMien } = dungGhi(
      { ...DA_DUYET, bannedAt: new Date() },
      0,
      3,
      0,
    );

    await expect(
      service.datKhoaVinhVien('ncc-1', false, 'nhầm người', ADMIN_ID),
    ).rejects.toMatchObject({ response: { code: 'TRANG_THAI_KHONG_HOP_LE' } });
    expect(dieuKienGhi[0]).toEqual({ id: 'ncc-1', bannedAt: { not: null } });
    expect(daMien).toHaveLength(0);
  });
});

describe('Duyệt hồ sơ người chăm', () => {
  const CHO_DUYET: HoSo = { ...DA_DUYET, status: 'PENDING' };

  // onboardedAt là mốc người chăm tự bấm nhận đơn, lệnh duyệt không được đụng vào
  it('duyệt thì ghi mốc duyệt, không đụng mốc bắt đầu nhận đơn', async () => {
    const { service, daCapNhat } = dungGhi(CHO_DUYET);
    await service.duyetHoSo('ncc-1', { status: 'APPROVED' }, ADMIN_ID);
    expect(daCapNhat[0]).toMatchObject({ status: 'APPROVED' });
    expect(daCapNhat[0].approvedAt).toBeInstanceOf(Date);
    expect(daCapNhat[0].onboardedAt).toBeUndefined();
  });

  it('từ chối mà không ghi lý do thì bị chặn', async () => {
    const { service } = dungGhi(CHO_DUYET);
    await expect(
      service.duyetHoSo('ncc-1', { status: 'REJECTED' }, ADMIN_ID),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('hồ sơ đã xử lý rồi thì không duyệt lại', async () => {
    const { service } = dungGhi(DA_DUYET);
    await expect(
      service.duyetHoSo('ncc-1', { status: 'APPROVED' }, ADMIN_ID),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('người khác duyệt xen vào thì dừng, không bắn tin duyệt lần thứ hai', async () => {
    // Kẹp PENDING vào where: thiếu thì hai lượt duyệt cùng lúc gửi hai tin
    const { service, dieuKienGhi, nhatKy, tinDaGui } = dungGhi(
      CHO_DUYET,
      0,
      0,
      0,
    );

    await expect(
      service.duyetHoSo('ncc-1', { status: 'APPROVED' }, ADMIN_ID),
    ).rejects.toMatchObject({ response: { code: 'TRANG_THAI_KHONG_HOP_LE' } });
    expect(dieuKienGhi[0]).toEqual({ id: 'ncc-1', status: 'PENDING' });
    expect(nhatKy).toHaveLength(0);
    expect(tinDaGui).toHaveLength(0);
  });
});

describe('Soát đơn xin miễn phạt', () => {
  function dungSoat(ban: Record<string, unknown> | null, soDongDoi = 1) {
    const nhatKy: Array<Record<string, unknown>> = [];
    const daSua: Array<Record<string, unknown>> = [];
    const prisma = {
      sitterPenalty: {
        findUnique: () => Promise.resolve(ban),
        updateMany: (arg: Record<string, unknown>) => {
          daSua.push(arg);
          return Promise.resolve({ count: soDongDoi });
        },
      },
      adminAuditLog: {
        create: (arg: { data: Record<string, unknown> }) => {
          nhatKy.push(arg.data);
          return { __lenh: 'audit' };
        },
      },
      $transaction: (lenh: unknown) =>
        typeof lenh === 'function'
          ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
          : Promise.resolve(lenh),
    };
    const service = new AdminPenaltiesService(
      prisma as unknown as PrismaService,
      new NhatKyQuanTriService(prisma as unknown as PrismaService),
      { so: () => 90 } as unknown as SystemSettingsService,
    );
    return { service, nhatKy, daSua };
  }

  const TREO = {
    id: 'p-1',
    sitterId: 'ncc-1',
    bookingId: 'don-1',
    status: 'PENDING_REVIEW',
    kind: 'CANCEL_RATE',
    booking: { code: 'PC6Q5MT3' },
  };

  it('miễn một bản thì miễn luôn bản sinh cùng lần huỷ đó', async () => {
    const { service, daSua } = dungSoat(TREO);
    await service.soat('p-1', true, 'xe hỏng có ảnh', ADMIN_ID);
    expect(daSua[0].where).toEqual({
      sitterId: 'ncc-1',
      bookingId: 'don-1',
      status: 'PENDING_REVIEW',
    });
    expect(daSua[0].data).toMatchObject({ status: 'WAIVED' });
  });

  it('giữ nguyên hình phạt thì chuyển sang đang áp', async () => {
    const { service, daSua, nhatKy } = dungSoat(TREO);
    await service.soat('p-1', false, 'lý do không thuyết phục', ADMIN_ID);
    expect(daSua[0].data).toMatchObject({ status: 'ACTIVE' });
    expect(nhatKy[0]).toMatchObject({
      action: 'GIU_PHAT_NCC',
      targetCode: 'PC6Q5MT3',
    });
  });

  it('bản đã kết luận rồi thì không soát lại', async () => {
    const { service } = dungSoat({ ...TREO, status: 'ACTIVE' });
    await expect(
      service.soat('p-1', true, 'thử', ADMIN_ID),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('người khác soát xen vào thì không ghi dòng nhật ký cho lượt hụt', async () => {
    // Kẹp trạng thái vào where mà không đọc count là dựng chứng cho việc chưa xảy ra
    const { service, nhatKy } = dungSoat(TREO, 0);

    await expect(
      service.soat('p-1', true, 'xe hỏng có ảnh', ADMIN_ID),
    ).rejects.toMatchObject({ response: { code: 'BAN_GHI_DA_SOAT' } });
    expect(nhatKy).toHaveLength(0);
  });
});
