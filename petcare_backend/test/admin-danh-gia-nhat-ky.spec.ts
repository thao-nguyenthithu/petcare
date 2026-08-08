import { PrismaService } from '../src/prisma/prisma.service';
import { AdminReviewsReadService } from '../src/modules/admin/reviews/admin-reviews-read.service';
import { AdminAuditLogsService } from '../src/modules/admin/nhat-ky/admin-audit-logs.service';
import { HANH_DONG_NHAT_KY } from '../src/modules/admin/chung/hanh-dong-nhat-ky';

function dungDanhGia(
  dong: Array<Record<string, unknown>> = [],
  diemTrungBinh: number | null = 4.5,
) {
  const dieuKienDaHoi: unknown[] = [];
  const prisma = {
    review: {
      count: (arg?: { where?: unknown }) => {
        dieuKienDaHoi.push(arg?.where ?? null);
        return Promise.resolve(dong.length);
      },
      aggregate: () => Promise.resolve({ _avg: { rating: diemTrungBinh } }),
      findMany: (arg: { where: unknown }) => {
        dieuKienDaHoi.push(arg.where);
        return Promise.resolve(dong);
      },
    },
  };
  const service = new AdminReviewsReadService(
    prisma as unknown as PrismaService,
  );
  return { service, dieuKienDaHoi };
}

function danhGia(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'dg-1',
    rating: 5,
    comment: 'Bé về sạch sẽ',
    photos: [],
    reply: null,
    replyAt: null,
    createdAt: new Date('2026-08-01T03:00:00.000Z'),
    reviewer: { fullName: 'Trần Minh Anh', avatarUrl: null },
    booking: {
      code: 'PC001',
      durationMinutes: 60,
      service: { name: 'Dắt đi dạo', type: 'WALKING' },
      sitter: { legalName: 'Đặng Khắc Duy', user: { fullName: 'Duy Đặng' } },
    },
    ...ghiDe,
  };
}

describe('Danh sách đánh giá của quản trị viên', () => {
  it('tab 1-2 sao lọc bằng khoảng ở máy chủ, không cắt thêm ở màn', async () => {
    const { service, dieuKienDaHoi } = dungDanhGia([danhGia()]);

    await service.danhSach({ ratingTo: 2 });

    expect(dieuKienDaHoi[0]).toMatchObject({ rating: { lte: 2 } });
  });

  it('hạn đáp suy từ lúc gửi đánh giá, đúng bảy ngày của bộ luật', async () => {
    const { service } = dungDanhGia([danhGia()]);

    const ketQua = await service.danhSach({});
    const dong = ketQua.items[0];

    expect(dong.replyDeadline.toISOString()).toBe('2026-08-08T03:00:00.000Z');
  });

  it('điểm trung bình lấy từ chính bảng đánh giá', async () => {
    const { service } = dungDanhGia([danhGia()]);

    const ketQua = await service.danhSach({});

    expect(ketQua.avgRating).toBe(4.5);
  });

  it('tập lọc rỗng thì trả điểm trung bình RỖNG, không lấp 0 sao', async () => {
    const { service } = dungDanhGia([], null);

    const ketQua = await service.danhSach({});

    expect(ketQua.avgRating).toBeNull();
  });

  it('tab chưa ai đáp chỉ đếm đánh giá còn hạn đáp', async () => {
    const { service, dieuKienDaHoi } = dungDanhGia([]);

    await service.demTab();

    const dieuNoReply = dieuKienDaHoi[3] as {
      reply: null;
      createdAt: { gt: Date };
    };
    expect(dieuNoReply.reply).toBeNull();
    expect(dieuNoReply.createdAt.gt).toBeInstanceOf(Date);
  });
});

describe('Nhật ký thao tác', () => {
  it('hai ô lọc lấy đúng mã đã có bản ghi, không dựng tập riêng', async () => {
    const prisma = {
      adminAuditLog: {
        groupBy: (arg: { by: string[] }) =>
          Promise.resolve(
            arg.by[0] === 'action'
              ? [{ action: 'KET_LUAN_KHIEU_NAI' }, { action: 'GO_CO_GPS' }]
              : [{ targetType: 'DISPUTE' }],
          ),
      },
    };
    const service = new AdminAuditLogsService(
      prisma as unknown as PrismaService,
    );

    const ketQua = await service.boLoc();

    expect(ketQua.actions).toEqual(['GO_CO_GPS', 'KET_LUAN_KHIEU_NAI']);
    expect(ketQua.targetTypes).toEqual(['DISPUTE']);
  });

  it('bảng nhật ký không kéo về uuid của quản trị viên hay của đối tượng', async () => {
    const daHoi: Array<Record<string, unknown>> = [];
    const prisma = {
      adminAuditLog: {
        count: () => Promise.resolve(1),
        findMany: (arg: Record<string, unknown>) => {
          daHoi.push(arg);
          return Promise.resolve([
            { id: 'log-1', action: 'GO_CO_GPS', admin: { fullName: 'Kendra' } },
          ]);
        },
      },
    };
    const service = new AdminAuditLogsService(
      prisma as unknown as PrismaService,
    );

    const ketQua = await service.danhSach({});

    const chon = daHoi[0].select as Record<string, unknown>;
    expect(chon.adminId).toBeUndefined();
    expect(chon.targetId).toBeUndefined();
    expect(Object.keys(ketQua.items[0])).not.toContain('adminId');
    expect(Object.keys(ketQua.items[0])).not.toContain('targetId');
  });

  it('mã lượt này sinh ra nằm trong tập đã khai', () => {
    expect(HANH_DONG_NHAT_KY).toContain('KET_LUAN_KHIEU_NAI');
    // Quản trị viên không duyệt ảnh check-in nên mã này không được phép tồn tại
    expect(HANH_DONG_NHAT_KY).not.toContain('CHAP_NHAN_ANH');
  });
});
