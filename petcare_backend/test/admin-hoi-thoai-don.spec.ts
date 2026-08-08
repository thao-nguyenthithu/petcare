import { NotFoundException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import {
  AdminBookingConversationService,
  TRAN_TIN_TRA_SOAT,
} from '../src/modules/admin/bookings/admin-booking-conversation.service';

const MOC = new Date('2026-08-06T03:00:00.000Z');

type TinGia = {
  id?: string;
  role: string;
  kind?: string;
  text?: string;
  images?: string[];
  soAnhThem?: number | null;
  masked?: boolean;
};

function tin(t: TinGia, thuTu = 0) {
  return {
    id: t.id ?? `tin-${thuTu}`,
    role: t.role,
    kind: t.kind ?? 'TEXT',
    text: t.text ?? 'noi dung',
    images: t.images ?? [],
    soAnhThem: t.soAnhThem ?? null,
    masked: t.masked ?? false,
    createdAt: new Date(MOC.getTime() + thuTu * 60_000),
  };
}

type Don = {
  status: string;
  completedAt?: Date | null;
  cancelledAt?: Date | null;
  coHoiThoai?: boolean;
  tin?: TinGia[];
};

function dungGoi(don: Don | null) {
  const daHoi: Array<Record<string, unknown>> = [];
  const prisma = {
    booking: {
      findUnique: (arg: Record<string, unknown>) => {
        daHoi.push(arg);
        if (!don) return Promise.resolve(null);
        return Promise.resolve({
          code: 'PC-001',
          status: don.status,
          completedAt: don.completedAt ?? null,
          cancelledAt: don.cancelledAt ?? null,
          owner: { fullName: 'Lê Thị Hoa' },
          sitter: {
            legalName: 'Trịnh Văn Nam',
            user: { fullName: 'Nam Trịnh' },
          },
          conversation:
            don.coHoiThoai === false
              ? null
              : {
                  createdAt: MOC,
                  messages: (don.tin ?? []).map((t, i) => tin(t, i)),
                },
        });
      },
    },
  };
  const service = new AdminBookingConversationService(
    prisma as unknown as PrismaService,
  );
  return { service, daHoi };
}

describe('Hội thoại của đơn ở màn tra soát', () => {
  it('đổi vai PROVIDER của bảng lưu sang SITTER cho khớp cụm quản trị', async () => {
    const { service } = dungGoi({
      status: 'IN_PROGRESS',
      tin: [{ role: 'OWNER' }, { role: 'PROVIDER' }, { role: 'SYSTEM' }],
    });

    const ketQua = await service.hoiThoai('PC-001');

    expect(ketQua.entries.map((e) => e.sender)).toEqual([
      'OWNER',
      'SITTER',
      'SYSTEM',
    ]);
  });

  it('đọc bản chữ của chủ nuôi, không trộn bản của người chăm', async () => {
    const { service, daHoi } = dungGoi({
      status: 'IN_PROGRESS',
      tin: [{ role: 'SYSTEM', text: 'Nam đã nhận đơn' }],
    });

    const ketQua = await service.hoiThoai('PC-001');

    expect(ketQua.entries[0].content).toBe('Nam đã nhận đơn');
    const chonTin = (
      daHoi[0] as {
        select: { conversation: { select: { messages: { select: object } } } };
      }
    ).select.conversation.select.messages.select;
    expect(chonTin).not.toHaveProperty('textSitter');
  });

  it('đếm cả ảnh phần dư của lô chứ không chỉ ảnh đính kèm', async () => {
    const { service } = dungGoi({
      status: 'COMPLETED',
      completedAt: MOC,
      tin: [{ role: 'SYSTEM', images: ['a', 'b', 'c'], soAnhThem: 5 }],
    });

    const ketQua = await service.hoiThoai('PC-001');

    expect(ketQua.entries[0].photoCount).toBe(8);
  });

  it('đơn đã khép thì mốc khoá là mốc khép thật, không cộng hạn giữ tiền', async () => {
    const ketThuc = new Date('2026-08-06T05:00:00.000Z');
    const { service } = dungGoi({
      status: 'COMPLETED',
      completedAt: ketThuc,
      tin: [{ role: 'OWNER' }],
    });

    const ketQua = await service.hoiThoai('PC-001');

    expect(ketQua.closedAt).toEqual(ketThuc);
  });

  it('đơn huỷ lấy mốc huỷ, đơn đang chạy thì chưa khoá', async () => {
    const mocHuy = new Date('2026-08-06T04:00:00.000Z');
    const daHuy = dungGoi({
      status: 'CANCELLED_BY_ADMIN',
      cancelledAt: mocHuy,
      tin: [{ role: 'OWNER' }],
    });
    const dangChay = dungGoi({
      status: 'IN_PROGRESS',
      tin: [{ role: 'OWNER' }],
    });

    expect((await daHuy.service.hoiThoai('PC-001')).closedAt).toEqual(mocHuy);
    expect((await dangChay.service.hoiThoai('PC-001')).closedAt).toBeNull();
  });

  it('đơn chưa có hội thoại thì trả rỗng chứ không phải lỗi', async () => {
    const { service } = dungGoi({ status: 'PENDING', coHoiThoai: false });

    const ketQua = await service.hoiThoai('PC-001');

    expect(ketQua.entries).toEqual([]);
    expect(ketQua.openedAt).toBeNull();
    expect(ketQua.truncated).toBe(false);
  });

  it('chạm trần thì cắt và nói ra, im lặng là hỏng bằng chứng', async () => {
    const qua = Array.from({ length: TRAN_TIN_TRA_SOAT + 1 }, () => ({
      role: 'OWNER',
    }));
    const { service } = dungGoi({ status: 'COMPLETED', tin: qua });

    const ketQua = await service.hoiThoai('PC-001');

    expect(ketQua.entries).toHaveLength(TRAN_TIN_TRA_SOAT);
    expect(ketQua.truncated).toBe(true);
  });

  it('không có đơn thì trả mã lỗi tra được, không trả hội thoại rỗng', async () => {
    const { service } = dungGoi(null);

    await expect(service.hoiThoai('PC-404')).rejects.toThrow(NotFoundException);
  });
});
