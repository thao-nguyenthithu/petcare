import { BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { AdminSittersWriteService } from '../src/modules/admin/sitters/admin-sitters-write.service';
import { SitterPenaltyService } from '../src/modules/bookings/sitter-penalty.service';
import { NotificationsService } from '../src/modules/notifications/notifications.service';

const ADMIN_ID = 'admin-1';

function dungGhi(status: string | null) {
  const nhatKy: Array<Record<string, unknown>> = [];
  const daCapNhat: Array<Record<string, unknown>> = [];
  const tinDaGui: Array<Record<string, unknown>> = [];
  const prisma = {
    sitter: {
      findUnique: () =>
        Promise.resolve(
          status
            ? {
                id: 'ncc-1',
                userId: 'u-ncc',
                legalName: 'Nam',
                status,
                hiddenUntil: null,
                hiddenCount: 0,
                bannedAt: null,
              }
            : null,
        ),
      update: (arg: { data: Record<string, unknown> }) => {
        daCapNhat.push(arg.data);
        return Promise.resolve({ id: 'ncc-1' });
      },
    },
    booking: { count: () => Promise.resolve(0) },
    adminAuditLog: {
      create: (arg: { data: Record<string, unknown> }) => {
        nhatKy.push(arg.data);
        return Promise.resolve({ id: 'log-1' });
      },
    },
    $transaction: (lenh: unknown) =>
      typeof lenh === 'function'
        ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
        : Promise.resolve(lenh),
  };
  const service = new AdminSittersWriteService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
    {} as unknown as SitterPenaltyService,
    {
      tao: (tin: Record<string, unknown>) => {
        tinDaGui.push(tin);
        return Promise.resolve({ id: 'tin-1' });
      },
    } as unknown as NotificationsService,
  );
  return { service, nhatKy, daCapNhat, tinDaGui };
}

describe('Yêu cầu người chăm bổ sung hồ sơ', () => {
  it('không đổi trạng thái, hồ sơ vẫn nằm chờ duyệt', async () => {
    const { service, daCapNhat } = dungGhi('PENDING');
    const ket = await service.yeuCauBoSung('ncc-1', 'Ảnh mặt sau mờ', ADMIN_ID);
    expect(ket).toEqual({ id: 'ncc-1' });
    expect(daCapNhat).toHaveLength(0);
  });

  it('ghi nhật ký đúng mã hành động kèm lý do', async () => {
    const { service, nhatKy } = dungGhi('PENDING');
    await service.yeuCauBoSung('ncc-1', 'Ảnh mặt sau mờ', ADMIN_ID);
    expect(nhatKy[0]).toMatchObject({
      adminId: ADMIN_ID,
      action: 'YEU_CAU_BO_SUNG_HO_SO_NCC',
      targetType: 'SITTER',
      targetId: 'ncc-1',
      reason: 'Ảnh mặt sau mờ',
    });
  });

  it('gửi tin hồ sơ cho người chăm, nói rõ thiếu gì', async () => {
    const { service, tinDaGui } = dungGhi('PENDING');
    await service.yeuCauBoSung('ncc-1', 'Ảnh mặt sau mờ', ADMIN_ID);
    expect(tinDaGui[0]).toMatchObject({
      userId: 'u-ncc',
      type: 'HO_SO',
      role: 'NGUOI_CHAM',
      urgent: true,
    });
    expect(String(tinDaGui[0].body)).toContain('Ảnh mặt sau mờ');
  });

  it('hồ sơ đã duyệt hoặc đã từ chối thì chặn, không gửi tin', async () => {
    for (const status of ['APPROVED', 'REJECTED']) {
      const { service, tinDaGui, nhatKy } = dungGhi(status);
      await expect(
        service.yeuCauBoSung('ncc-1', 'Ảnh mặt sau mờ', ADMIN_ID),
      ).rejects.toBeInstanceOf(BadRequestException);
      expect(tinDaGui).toHaveLength(0);
      expect(nhatKy).toHaveLength(0);
    }
  });

  it('không có hồ sơ thì báo không tìm thấy', async () => {
    const { service } = dungGhi(null);
    await expect(
      service.yeuCauBoSung('ncc-1', 'Ảnh mặt sau mờ', ADMIN_ID),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});
