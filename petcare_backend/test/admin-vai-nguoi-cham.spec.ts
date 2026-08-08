import { AdminUsersReadService } from '../src/modules/admin/users/admin-users-read.service';
import { PrismaService } from '../src/prisma/prisma.service';

type HoSoNcc = { status: string; bannedAt: Date | null } | null;

function dungDoc(sitter: HoSoNcc) {
  const locDem: Array<Record<string, unknown>> = [];
  const locDanhSach: Array<Record<string, unknown>> = [];
  const prisma = {
    user: {
      count: (arg?: { where?: Record<string, unknown> }) => {
        locDem.push(arg?.where ?? {});
        return Promise.resolve(1);
      },
      findMany: (arg: { where?: Record<string, unknown> }) => {
        locDanhSach.push(arg.where ?? {});
        return Promise.resolve([
          {
            id: 'u-1',
            fullName: 'Chani',
            email: 'chani@example.com',
            phone: null,
            role: 'OWNER',
            avatarUrl: null,
            isActive: true,
            isVerified: true,
            createdAt: new Date('2026-08-01T00:00:00.000Z'),
            addresses: [],
            sitter,
            _count: { pets: 0, bookingsAsOwner: 0 },
          },
        ]);
      },
    },
  };
  const service = new AdminUsersReadService(prisma as unknown as PrismaService);
  return { service, locDem, locDanhSach };
}

describe('Vai người chăm suy từ hồ sơ Sitter, KHÔNG từ cột role', () => {
  it('hồ sơ đã duyệt thì là người chăm dù cột role vẫn là OWNER', async () => {
    const { service } = dungDoc({ status: 'APPROVED', bannedAt: null });

    const trang = await service.danhSach({});

    expect(trang.items[0]).toMatchObject({ role: 'OWNER', isSitter: true });
  });

  it('hồ sơ chờ duyệt thì chưa phải người chăm', async () => {
    const { service } = dungDoc({ status: 'PENDING', bannedAt: null });

    const trang = await service.danhSach({});

    expect(trang.items[0].isSitter).toBe(false);
  });

  it('khoá hồ sơ vĩnh viễn là mất vai người chăm, vẫn còn vai chủ nuôi', async () => {
    const { service } = dungDoc({
      status: 'APPROVED',
      bannedAt: new Date('2026-08-07T00:00:00.000Z'),
    });

    const trang = await service.danhSach({});

    expect(trang.items[0]).toMatchObject({ role: 'OWNER', isSitter: false });
  });

  it('người chưa từng nộp hồ sơ thì không phải người chăm', async () => {
    const { service } = dungDoc(null);

    const trang = await service.danhSach({});

    expect(trang.items[0].isSitter).toBe(false);
  });
});

describe('Tab và bộ lọc vai đi theo quan hệ Sitter', () => {
  it('lọc tab Người chăm hỏi theo hồ sơ đã duyệt chứ không hỏi cột role', async () => {
    const { service, locDanhSach } = dungDoc(null);

    await service.danhSach({ role: 'PROVIDER' });

    expect(locDanhSach[0]).toEqual({
      sitter: { is: { status: 'APPROVED', bannedAt: null } },
    });
  });

  it('lọc tab Chủ nuôi loại bỏ người đã là người chăm', async () => {
    const { service, locDanhSach } = dungDoc(null);

    await service.danhSach({ role: 'OWNER' });

    expect(locDanhSach[0]).toMatchObject({
      role: 'OWNER',
      sitter: { isNot: { status: 'APPROVED', bannedAt: null } },
    });
  });

  it('số đếm bốn tab cũng đếm theo hồ sơ, không đếm theo cột role', async () => {
    const { service, locDem } = dungDoc(null);

    const dem = await service.demTab();

    expect(dem).toEqual({ all: 1, owner: 1, provider: 1, locked: 1 });
    expect(locDem).toContainEqual({
      sitter: { is: { status: 'APPROVED', bannedAt: null } },
    });
  });
});
