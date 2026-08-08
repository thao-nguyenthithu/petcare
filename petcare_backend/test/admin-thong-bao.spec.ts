import { BadRequestException, ConflictException } from '@nestjs/common';
import { Queue } from 'bullmq';
import { NotificationRole, UserRole } from '../generated/prisma/enums';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { AdminBroadcastProcessor } from '../src/modules/admin/notifications/admin-broadcast.processor';
import { AdminNotificationsReadService } from '../src/modules/admin/notifications/admin-notifications-read.service';
import { AdminNotificationsWriteService } from '../src/modules/admin/notifications/admin-notifications-write.service';
import { lopNguoiNhan } from '../src/modules/admin/notifications/nguoi-nhan';
import { FirebaseService } from '../src/modules/firebase/firebase.service';
import { PrismaService } from '../src/prisma/prisma.service';

type BanGhi = Record<string, unknown>;

function nhanhTransaction(prisma: BanGhi) {
  return (lenh: unknown) =>
    typeof lenh === 'function'
      ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
      : Promise.all(lenh as Promise<unknown>[]);
}

const TIN = {
  title: 'Bảo trì hệ thống 02:00 ngày 08/08',
  body: 'Hệ thống tạm dừng nhận đơn mới từ 02:00 tới 03:00 ngày 08/08.',
};

type CauHinhGui = {
  soNguoi?: number;
  luotTrung?: BanGhi | null;
  nguoiNhan?: BanGhi | null;
};

function dungGui(cauHinh: CauHinhGui = {}) {
  const nhatKy: BanGhi[] = [];
  const daTao: BanGhi[] = [];
  const daXoa: string[] = [];
  const job: BanGhi[] = [];

  const prisma: BanGhi = {
    user: {
      count: () => Promise.resolve(cauHinh.soNguoi ?? 12094),
      findFirst: () => Promise.resolve(cauHinh.nguoiNhan ?? null),
    },
    notificationCampaign: {
      findFirst: () => Promise.resolve(cauHinh.luotTrung ?? null),
      findUnique: () => Promise.resolve(cauHinh.luotTrung ?? null),
      create: (arg: { data: BanGhi }) => {
        daTao.push(arg.data);
        return Promise.resolve({ id: 'cmp-1' });
      },
      delete: (arg: { where: { id: string } }) => {
        daXoa.push(arg.where.id);
        return Promise.resolve({ id: arg.where.id });
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

  const hangDoi = {
    add: (ten: string, duLieu: BanGhi, tuyChon: BanGhi) => {
      job.push({ ten, duLieu, tuyChon });
      return Promise.resolve({ id: 'job-1' });
    },
    remove: (id: string) => {
      job.push({ goBo: id });
      return Promise.resolve(1);
    },
  };

  const doc = new AdminNotificationsReadService(
    prisma as unknown as PrismaService,
  );
  const service = new AdminNotificationsWriteService(
    prisma as unknown as PrismaService,
    doc,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
    hangDoi as unknown as Queue,
  );
  return { service, nhatKy, daTao, daXoa, job };
}

describe('Gửi thông báo hệ thống là thao tác không lùi được', () => {
  it('tạo lượt gửi, ghi nhật ký cùng lượt rồi mới xếp vào hàng đợi', async () => {
    const { service, daTao, nhatKy, job } = dungGui({ soNguoi: 12094 });

    const ket = await service.gui(
      { ...TIN, audienceKind: 'ALL_OWNERS', urgent: true },
      'admin-1',
    );

    expect(ket).toEqual({ id: 'cmp-1', scheduledAt: null });
    // Số người ước tính chỉ vào nhật ký, màn không đọc nên không trả ra đáp ứng
    expect(nhatKy[0].newValue).toBe('12094');
    expect(daTao[0]).toMatchObject({
      adminId: 'admin-1',
      role: NotificationRole.CHU_NUOI,
      audienceKind: 'ALL_OWNERS',
      urgent: true,
      scheduledAt: null,
    });
    // recipientCount chỉ chốt lúc gửi xong nên lúc tạo không được ghi số ước tính
    expect(daTao[0].recipientCount).toBeUndefined();
    expect(nhatKy[0]).toMatchObject({
      action: 'GUI_THONG_BAO_HE_THONG',
      targetType: 'NOTIFICATION',
      targetId: 'cmp-1',
      targetCode: TIN.title,
      newValue: '12094',
    });
    expect(job[0]).toMatchObject({
      ten: 'gui-thong-bao-he-thong',
      duLieu: { campaignId: 'cmp-1' },
    });
    expect((job[0].tuyChon as BanGhi).jobId).toBe('thong-bao-cmp-1');
  });

  it('lượt trước còn đang chạy thì chặn, không tạo và không xếp job', async () => {
    const { service, daTao, job } = dungGui({
      luotTrung: { sentAt: null, scheduledAt: null },
    });

    await expect(
      service.gui({ ...TIN, audienceKind: 'BOTH' }, 'admin-1'),
    ).rejects.toMatchObject({ response: { code: 'LUOT_GUI_DANG_CHAY' } });
    expect(daTao).toHaveLength(0);
    expect(job).toHaveLength(0);
  });

  it('bấm lần hai với đúng tiêu đề vừa gửi thì chặn bằng mã riêng', async () => {
    const { service, daTao } = dungGui({
      luotTrung: { sentAt: new Date(), scheduledAt: null },
    });

    await expect(
      service.gui({ ...TIN, audienceKind: 'ALL_OWNERS' }, 'admin-1'),
    ).rejects.toBeInstanceOf(ConflictException);
    expect(daTao).toHaveLength(0);
  });

  it('nhóm không còn tài khoản nào thì chặn trước khi ghi gì', async () => {
    const { service, daTao, job } = dungGui({ soNguoi: 0 });

    await expect(
      service.gui({ ...TIN, audienceKind: 'ALL_SITTERS' }, 'admin-1'),
    ).rejects.toMatchObject({ response: { code: 'KHONG_CO_NGUOI_NHAN' } });
    expect(daTao).toHaveLength(0);
    expect(job).toHaveLength(0);
  });

  it('nhóm theo tỉnh mà bỏ trống tỉnh thì báo thiếu tham số', async () => {
    const { service } = dungGui();

    await expect(
      service.gui({ ...TIN, audienceKind: 'OWNERS_BY_PROVINCE' }, 'admin-1'),
    ).rejects.toMatchObject({ response: { code: 'THIEU_THAM_SO_NHOM_NHAN' } });
  });

  it('mốc hẹn nằm ở quá khứ thì chặn chứ không âm thầm gửi ngay', async () => {
    const { service, job } = dungGui();

    await expect(
      service.gui(
        {
          ...TIN,
          audienceKind: 'ALL_OWNERS',
          scheduledAt: '2020-01-01T00:00:00+07:00',
        },
        'admin-1',
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(job).toHaveLength(0);
  });

  it('hẹn giờ thì job mang đúng độ trễ và lượt gửi lưu mốc hẹn', async () => {
    const { service, daTao, job } = dungGui();
    const moc = new Date(Date.now() + 3_600_000);

    const ket = await service.gui(
      { ...TIN, audienceKind: 'BOTH', scheduledAt: moc.toISOString() },
      'admin-1',
    );

    expect(ket.scheduledAt).toBe(moc.toISOString());
    expect(daTao[0].scheduledAt).toEqual(moc);
    expect((job[0].tuyChon as { delay: number }).delay).toBeGreaterThan(
      3_500_000,
    );
  });

  it('gửi cho một người thì vai của tin lấy theo vai tài khoản đó', async () => {
    const { service, daTao } = dungGui({
      nguoiNhan: { role: UserRole.PROVIDER },
    });

    await service.gui(
      { ...TIN, audienceKind: 'SINGLE_USER', audienceValue: 'user-9' },
      'admin-1',
    );

    expect(daTao[0]).toMatchObject({
      role: NotificationRole.NGUOI_CHAM,
      audienceValue: 'user-9',
    });
  });

  it('người nhận đã bị khoá thì báo không tìm thấy, không tạo lượt gửi', async () => {
    const { service, daTao } = dungGui({ nguoiNhan: null });

    await expect(
      service.gui(
        { ...TIN, audienceKind: 'SINGLE_USER', audienceValue: 'user-9' },
        'admin-1',
      ),
    ).rejects.toMatchObject({
      response: { code: 'KHONG_TIM_THAY_NGUOI_NHAN' },
    });
    expect(daTao).toHaveLength(0);
  });
});

describe('Huỷ lượt gửi còn đang hẹn giờ', () => {
  it('xoá bản ghi, ghi nhật ký rồi mới gỡ job khỏi hàng đợi', async () => {
    const moc = new Date(Date.now() + 3_600_000);
    const { service, daXoa, nhatKy, job } = dungGui({
      luotTrung: {
        id: 'cmp-1',
        title: TIN.title,
        sentAt: null,
        scheduledAt: moc,
      },
    });

    await service.huyLich('cmp-1', 'admin-1');

    expect(daXoa).toEqual(['cmp-1']);
    expect(nhatKy[0]).toMatchObject({
      action: 'HUY_LICH_THONG_BAO',
      targetType: 'NOTIFICATION',
      targetCode: TIN.title,
      oldValue: moc.toISOString(),
    });
    expect(job[0]).toEqual({ goBo: 'thong-bao-cmp-1' });
  });

  it('tin đã tới tay người nhận thì không thu hồi được', async () => {
    const { service, daXoa } = dungGui({
      luotTrung: {
        id: 'cmp-1',
        title: TIN.title,
        sentAt: new Date(),
        scheduledAt: null,
      },
    });

    await expect(service.huyLich('cmp-1', 'admin-1')).rejects.toMatchObject({
      response: { code: 'DA_GUI_KHONG_HUY_DUOC' },
    });
    expect(daXoa).toHaveLength(0);
  });

  it('lượt đang chạy dở cũng không huỷ được', async () => {
    const { service } = dungGui({
      luotTrung: {
        id: 'cmp-1',
        title: TIN.title,
        sentAt: null,
        scheduledAt: null,
      },
    });

    await expect(service.huyLich('cmp-1', 'admin-1')).rejects.toMatchObject({
      response: { code: 'DANG_GUI_KHONG_HUY_DUOC' },
    });
  });

  it('không còn bản ghi thì báo không tìm thấy', async () => {
    const { service } = dungGui({ luotTrung: null });

    await expect(service.huyLich('cmp-1', 'admin-1')).rejects.toMatchObject({
      response: { code: 'KHONG_TIM_THAY_LUOT_GUI' },
    });
  });
});

function dongLuot(id: string, ghiDe: BanGhi = {}) {
  return {
    id,
    title: TIN.title,
    body: TIN.body,
    role: NotificationRole.CHU_NUOI,
    audienceKind: 'ALL_OWNERS',
    audienceValue: null,
    urgent: false,
    recipientCount: 120,
    sentAt: new Date('2026-08-06T01:20:00Z'),
    scheduledAt: null,
    createdAt: new Date('2026-08-06T01:12:00Z'),
    ...ghiDe,
  };
}

describe('Lịch sử lượt gửi', () => {
  function dungDoc(rows: BanGhi[]) {
    const luot: string[] = [];
    const prisma: BanGhi = {
      notificationCampaign: {
        count: () => {
          luot.push('count');
          return Promise.resolve(rows.length);
        },
        findMany: (arg: BanGhi) => {
          luot.push(`findMany:${String(arg.take)}`);
          return Promise.resolve(rows);
        },
      },
      notification: {
        groupBy: () => {
          luot.push('groupBy');
          return Promise.resolve([
            { campaignId: 'cmp-1', _count: { _all: 61 } },
          ]);
        },
      },
    };
    return {
      service: new AdminNotificationsReadService(
        prisma as unknown as PrismaService,
      ),
      luot,
    };
  }

  it('đếm đã đọc bằng một lượt gộp, không hỏi từng dòng', async () => {
    const { service, luot } = dungDoc([dongLuot('cmp-1'), dongLuot('cmp-2')]);

    const ket = await service.danhSachLuot({});

    expect(ket.items[0].readCount).toBe(61);
    // Dòng chưa ai đọc phải là 0 chứ không mượn số của dòng khác
    expect(ket.items[1].readCount).toBe(0);
    expect(luot.filter((l) => l === 'groupBy')).toHaveLength(1);
    expect(ket.items[0].sentAt).toBe('2026-08-06T01:20:00.000Z');
  });

  it('trang rỗng thì không gọi groupBy thêm một lượt vô ích', async () => {
    const { service, luot } = dungDoc([]);

    const ket = await service.danhSachLuot({ page: 3 });

    expect(ket.items).toHaveLength(0);
    expect(luot).not.toContain('groupBy');
  });

  it('số dòng mỗi trang bị kẹp về trần 50 của mọi danh sách quản trị', async () => {
    const { service, luot } = dungDoc([]);

    const ket = await service.danhSachLuot({ limit: 500 });

    expect(ket.limit).toBe(50);
    expect(luot).toContain('findMany:50');
  });
});

describe('Nhóm người nhận', () => {
  it('cả hai vai tách thành hai lớp, mỗi lớp một vai của tin', () => {
    const lop = lopNguoiNhan('BOTH', null, NotificationRole.CHU_NUOI);

    expect(lop).toHaveLength(2);
    expect(lop[0].role).toBe(NotificationRole.CHU_NUOI);
    expect(lop[1].role).toBe(NotificationRole.NGUOI_CHAM);
    expect(lop[1].where.sitter).toEqual({ status: 'APPROVED' });
  });

  it('theo tỉnh thì lọc chủ nuôi có địa chỉ mặc định ở tỉnh đó', () => {
    const [lop] = lopNguoiNhan(
      'OWNERS_BY_PROVINCE',
      'Thành phố Hà Nội',
      NotificationRole.CHU_NUOI,
    );

    expect(lop.where.addresses).toEqual({
      some: { isDefault: true, province: 'Thành phố Hà Nội' },
    });
  });
});

type CauHinhLo = { soNguoi: number; luot?: BanGhi | null };

function dungProcessor(cauHinh: CauHinhLo) {
  const daGhi: BanGhi[][] = [];
  const daChot: BanGhi[] = [];
  let conLai = cauHinh.soNguoi;
  let stt = 0;

  const prisma: BanGhi = {
    notificationCampaign: {
      findUnique: () =>
        Promise.resolve(
          cauHinh.luot === undefined
            ? dongLuot('cmp-1', { sentAt: null })
            : cauHinh.luot,
        ),
      update: (arg: { data: BanGhi }) => {
        daChot.push(arg.data);
        return Promise.resolve({ id: 'cmp-1' });
      },
    },
    user: {
      findMany: (arg: { take: number }) => {
        const lay = Math.min(arg.take, conLai);
        conLai -= lay;
        return Promise.resolve(
          Array.from({ length: lay }, () => ({ id: `u-${(stt += 1)}` })),
        );
      },
    },
    notification: {
      createMany: (arg: { data: BanGhi[] }) => {
        daGhi.push(arg.data);
        return Promise.resolve({ count: arg.data.length });
      },
    },
    deviceToken: {
      findMany: () => Promise.resolve([{ token: 'tk-1' }]),
      deleteMany: () => Promise.resolve({ count: 0 }),
    },
  };

  const firebase = { guiPush: () => Promise.resolve([]) };
  const processor = new AdminBroadcastProcessor(
    prisma as unknown as PrismaService,
    firebase as unknown as FirebaseService,
  );
  return { processor, daGhi, daChot };
}

function job(ten = 'gui-thong-bao-he-thong') {
  return { name: ten, data: { campaignId: 'cmp-1' } };
}

describe('Worker gửi hàng loạt', () => {
  it('chia lô 500 và chốt số người nhận sau khi ghi xong', async () => {
    const { processor, daGhi, daChot } = dungProcessor({ soNguoi: 1200 });

    await processor.process(job() as never);

    expect(daGhi.map((lo) => lo.length)).toEqual([500, 500, 200]);
    expect(daGhi[0][0]).toMatchObject({
      campaignId: 'cmp-1',
      type: 'NOI_DUNG',
      role: NotificationRole.CHU_NUOI,
      title: TIN.title,
    });
    expect(daChot[0].recipientCount).toBe(1200);
    expect(daChot[0].sentAt).toBeInstanceOf(Date);
  });

  it('lượt gửi đã bị huỷ lịch thì worker không ghi gì', async () => {
    const { processor, daGhi, daChot } = dungProcessor({
      soNguoi: 10,
      luot: null,
    });

    await processor.process(job() as never);

    expect(daGhi).toHaveLength(0);
    expect(daChot).toHaveLength(0);
  });

  it('lượt đã chốt rồi thì chạy lại job cũng không gửi thêm lần nữa', async () => {
    const { processor, daGhi } = dungProcessor({
      soNguoi: 10,
      luot: dongLuot('cmp-1'),
    });

    await processor.process(job() as never);

    expect(daGhi).toHaveLength(0);
  });

  it('job của việc khác trong cùng hàng đợi thì bỏ qua', async () => {
    const { processor, daGhi } = dungProcessor({ soNguoi: 10 });

    await processor.process(job('viec-khac') as never);

    expect(daGhi).toHaveLength(0);
  });
});
