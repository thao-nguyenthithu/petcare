import { ConflictException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { AdminDisputesReadService } from '../src/modules/admin/disputes/admin-disputes-read.service';
import { dieuKienTab } from '../src/modules/admin/disputes/khieu-nai-chung';
import {
  dungCau,
  type KhoaTin,
  type ThamSoTin,
} from '../src/modules/notifications/thong-bao-i18n';
import { dungKetLuan } from './khieu-nai-gia';

const BAY_GIO = new Date('2026-08-07T03:00:00.000Z');

describe('Ba tình trạng khiếu nại suy ở máy chủ', () => {
  it('hồ sơ không có hạn đáp thuộc nhóm chờ quản trị viên, không phải quá hạn', () => {
    const cho = dieuKienTab('waitingSupport', BAY_GIO);
    const nhanh = JSON.stringify(cho);

    expect(nhanh).toContain('"replyDeadline":null');
    // Nhóm chờ người chăm đáp phải đòi hạn còn hiệu lực, null không lọt vào đây
    const dap = JSON.stringify(dieuKienTab('waitingSitter', BAY_GIO));
    expect(dap).toContain('"gt"');
    expect(dap).not.toContain('null');
  });

  it('ba nhóm không chồng nhau ở trạng thái RESOLVED', () => {
    expect(JSON.stringify(dieuKienTab('resolved', BAY_GIO))).toContain(
      'RESOLVED',
    );
    expect(JSON.stringify(dieuKienTab('waitingSitter', BAY_GIO))).not.toContain(
      'RESOLVED',
    );
    expect(
      JSON.stringify(dieuKienTab('waitingSupport', BAY_GIO)),
    ).not.toContain('RESOLVED');
  });
});

function dungDanhSach() {
  const daHoi: Array<Record<string, unknown>> = [];
  const prisma = {
    violationReport: {
      count: () => Promise.resolve(0),
      findMany: (arg: Record<string, unknown>) => {
        daHoi.push(arg);
        return Promise.resolve([]);
      },
    },
  };
  const service = new AdminDisputesReadService(
    prisma as unknown as PrismaService,
  );
  return { service, daHoi };
}

describe('Thứ tự danh sách khiếu nại', () => {
  it('hồ sơ chưa kết luận lên đầu, mở sớm nhất là gấp nhất', async () => {
    const { service, daHoi } = dungDanhSach();

    await service.danhSach({ tab: 'waitingSupport' });

    expect(daHoi[0].orderBy).toEqual([
      { resolvedAt: { sort: 'asc', nulls: 'first' } },
      { createdAt: 'asc' },
    ]);
  });

  it('tab đã kết luận xếp theo mốc mở mới nhất', async () => {
    const { service, daHoi } = dungDanhSach();

    await service.danhSach({ tab: 'resolved' });

    expect(daHoi[0].orderBy).toEqual([
      { resolvedAt: { sort: 'asc', nulls: 'first' } },
      { createdAt: 'desc' },
    ]);
  });
});

const KET_LUAN_GOC = {
  resolution: 'Xác nhận người chăm trễ giờ hẹn',
  resolutionReason: 'Log GPS cho thấy tới muộn 40 phút',
  refundAmount: 0,
};

describe('Ghi kết luận khiếu nại', () => {
  it('hoàn 0 đồng vẫn chốt được và vẫn ghi lý do', async () => {
    const { service, daCapNhat } = dungKetLuan({
      status: 'OPEN',
      totalPrice: 180000,
    });

    await service.ketLuan('KN-PC001', KET_LUAN_GOC, 'admin-1');

    expect(daCapNhat[0]).toMatchObject({
      status: 'RESOLVED',
      refundAmount: 0,
      resolutionReason: 'Log GPS cho thấy tới muộn 40 phút',
    });
  });

  it('khoản hoàn vượt giá trị đơn thì chặn trước khi ghi gì', async () => {
    const { service, daCapNhat } = dungKetLuan({
      status: 'OPEN',
      totalPrice: 180000,
    });

    await expect(
      service.ketLuan(
        'KN-PC001',
        { ...KET_LUAN_GOC, refundAmount: 200000 },
        'admin-1',
      ),
    ).rejects.toThrow('Khoản hoàn không được vượt giá trị đơn');
    expect(daCapNhat).toHaveLength(0);
  });

  it('hồ sơ đã kết luận thì không chốt lại được', async () => {
    const { service } = dungKetLuan({ status: 'RESOLVED', totalPrice: 180000 });

    await expect(
      service.ketLuan('KN-PC001', KET_LUAN_GOC, 'admin-1'),
    ).rejects.toThrow(ConflictException);
  });

  it('người khác chốt xen vào thì dừng, không phạt người chăm lần thứ hai', async () => {
    // Kẹp trạng thái cũ vào where: thiếu thì hai lượt cùng lúc ghi phạt hai lần
    const { service, nhatKy, dieuKienGhi, goiPhat } = dungKetLuan(
      { status: 'OPEN', totalPrice: 180000 },
      { soDongDoi: 0 },
    );

    await expect(
      service.ketLuan(
        'KN-PC001',
        { ...KET_LUAN_GOC, penalty: 'WARNING' },
        'admin-1',
      ),
    ).rejects.toMatchObject({ response: { code: 'HO_SO_DA_KET_LUAN' } });
    expect(dieuKienGhi[0]).toMatchObject({ status: { not: 'RESOLVED' } });
    expect(goiPhat).toHaveLength(0);
    expect(nhatKy).toHaveLength(0);
  });

  it('chọn tạm ẩn thì để thang bậc tự tính ngày, không ép con số nào', async () => {
    const { service, goiPhat } = dungKetLuan({
      status: 'REVIEWING',
      totalPrice: 180000,
    });

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, penalty: 'HIDE' },
      'admin-1',
    );

    const goi = goiPhat.find((g) => g.ten === 'tamAn');
    expect(goi).toBeDefined();
    // Đối số thứ năm là số ngày ép, để trống thì bậc 3-7-14 tự chạy (bộ luật mục 6)
    expect(goi?.doiSo[4]).toBeUndefined();
  });

  it('cảnh cáo đi qua đúng đường ghi phạt để thang leo vẫn chạy', async () => {
    const { service, goiPhat } = dungKetLuan({
      status: 'OPEN',
      totalPrice: 180000,
    });

    await service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, penalty: 'WARNING' },
      'admin-1',
    );

    const goi = goiPhat.find((g) => g.ten === 'ghiPhat');
    expect(goi?.doiSo[2]).toEqual({
      tinhTyLeHuy: false,
      canhCao: true,
      treoChoSoat: false,
    });
  });

  it('ghi nhật ký đúng mã và loại đối tượng của cụm khiếu nại', async () => {
    const { service, nhatKy } = dungKetLuan({
      status: 'OPEN',
      totalPrice: 180000,
    });

    await service.ketLuan('KN-PC001', KET_LUAN_GOC, 'admin-1');

    expect(nhatKy[0]).toMatchObject({
      action: 'KET_LUAN_KHIEU_NAI',
      targetType: 'DISPUTE',
      targetCode: 'KN-PC001',
    });
  });

  it('không bật báo hai vai thì không bắn thông báo nào', async () => {
    const tat = dungKetLuan({ status: 'OPEN', totalPrice: 180000 });
    const bat = dungKetLuan({ status: 'OPEN', totalPrice: 180000 });

    await tat.service.ketLuan('KN-PC001', KET_LUAN_GOC, 'admin-1');
    await bat.service.ketLuan(
      'KN-PC001',
      { ...KET_LUAN_GOC, notifyBoth: true },
      'admin-1',
    );

    expect(tat.daBao).toHaveLength(0);
    expect(bat.daBao).toHaveLength(2);
    const tin = bat.daBao[0] as { bodyKey: KhoaTin; params: ThamSoTin };
    expect(dungCau(tin.bodyKey, tin.params)).toContain(
      'không có khoản hoàn nào',
    );
  });
});
