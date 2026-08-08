import { NotFoundException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { AdminAccountService } from '../src/modules/admin/tai-khoan/admin-account.service';

const ADMIN_ID = 'admin-1';

const TAI_KHOAN = {
  id: ADMIN_ID,
  fullName: 'Kendra',
  email: 'kendra@petcare.vn',
  avatarUrl: null,
  createdAt: new Date('2026-05-12T03:00:00.000Z'),
  passwordChangedAt: new Date('2026-07-12T03:35:00.000Z'),
};

function dungGhi(taiKhoan: Record<string, unknown> | null = TAI_KHOAN) {
  const dieuKienDaHoi: Array<Record<string, unknown>> = [];
  const prisma = {
    dieuKienDaHoi,
    user: {
      findUnique: (arg: Record<string, unknown>) => {
        dieuKienDaHoi.push(arg);
        return Promise.resolve(taiKhoan);
      },
    },
    adminAuditLog: {
      aggregate: (arg: Record<string, unknown>) => {
        dieuKienDaHoi.push(arg);
        return Promise.resolve({
          _count: { _all: 7 },
          _max: { createdAt: new Date('2026-08-06T10:00:00.000Z') },
        });
      },
    },
  };
  const service = new AdminAccountService(prisma as unknown as PrismaService);
  return { service, prisma };
}

describe('GET /admin/account', () => {
  it('lấy hồ sơ theo đúng id nhận từ JWT', async () => {
    const { service, prisma } = dungGhi();

    const ketQua = await service.layCuaToi(ADMIN_ID);

    expect(ketQua.id).toBe(ADMIN_ID);
    expect(prisma.dieuKienDaHoi[0].where).toEqual({ id: ADMIN_ID });
    expect(prisma.dieuKienDaHoi[1].where).toEqual({ adminId: ADMIN_ID });
  });

  it('không trả mật khẩu băm và các trường riêng tư màn không cần', async () => {
    const { service, prisma } = dungGhi();

    const ketQua = await service.layCuaToi(ADMIN_ID);

    const chon = prisma.dieuKienDaHoi[0].select as Record<string, boolean>;
    ['passwordHash', 'phone', 'dateOfBirth', 'firebaseUid'].forEach((cot) => {
      expect(chon[cot]).toBeUndefined();
    });
    expect(Object.keys(ketQua)).toEqual([
      'id',
      'hoTen',
      'email',
      'avatarUrl',
      'taoLuc',
      'doiMatKhauLuc',
      'soThaoTacDaGhi',
      'thaoTacGanNhatLuc',
    ]);
  });

  it('chưa đổi mật khẩu lần nào thì để rỗng, không lấy ngày tạo lấp vào', async () => {
    const { service } = dungGhi({ ...TAI_KHOAN, passwordChangedAt: null });

    const ketQua = await service.layCuaToi(ADMIN_ID);

    expect(ketQua.doiMatKhauLuc).toBeNull();
    expect(ketQua.taoLuc).toEqual(TAI_KHOAN.createdAt);
  });

  it('đếm thao tác của chính tài khoản đang đăng nhập', async () => {
    const { service } = dungGhi();

    const ketQua = await service.layCuaToi(ADMIN_ID);

    expect(ketQua.soThaoTacDaGhi).toBe(7);
    expect(ketQua.thaoTacGanNhatLuc).toEqual(
      new Date('2026-08-06T10:00:00.000Z'),
    );
  });

  it('id trong token trỏ tới tài khoản không còn thì báo không tìm thấy', async () => {
    const { service } = dungGhi(null);

    await expect(service.layCuaToi(ADMIN_ID)).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});
