import { PrismaService } from '../src/prisma/prisma.service';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { AdminPenaltiesService } from '../src/modules/admin/sitters/admin-penalties.service';
import { SystemSettingsService } from '../src/modules/admin/system-settings.service';

const CUA_SO_NGAY = 90;

// Mock phải phân biệt hai khoá: trả chung một số là cửa sổ ngày thành ngưỡng đơn
function thamSoGia(toiThieu: number) {
  return {
    so: (khoa: string) =>
      khoa === 'penalty.min_orders' ? toiThieu : CUA_SO_NGAY,
  } as unknown as SystemSettingsService;
}

type DongPhat = { sitterId: string; kind: string; _count: { _all: number } };

function dungDoc(theoPhat: DongPhat[], soDon: number, toiThieu = 5) {
  const dieuKienDem: Array<Record<string, unknown>> = [];
  const prisma = {
    sitterPenalty: {
      count: () => Promise.resolve(0),
      findMany: () =>
        Promise.resolve([
          {
            id: 'p-1',
            sitterId: 'ncc-1',
            kind: 'CANCEL_RATE',
            status: 'PENDING_REVIEW',
            reason: 'xe hỏng',
            createdAt: new Date('2026-08-07T02:00:00.000Z'),
            reviewedAt: null,
            booking: { code: 'PC6Q5MT3', service: { name: 'Dắt đi dạo' } },
            sitter: {
              legalName: 'Trịnh Văn Nam',
              hiddenUntil: null,
              hiddenCount: 1,
              bannedAt: null,
              user: { fullName: 'Nam Trịnh' },
            },
          },
        ]),
      groupBy: (arg: { where: { kind: string } }) => {
        dieuKienDem.push(arg.where);
        return Promise.resolve(
          theoPhat.filter((d) => d.kind === arg.where.kind),
        );
      },
    },
    booking: {
      groupBy: () =>
        Promise.resolve([{ sitterId: 'ncc-1', _count: { _all: soDon } }]),
    },
  };
  const service = new AdminPenaltiesService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
    thamSoGia(toiThieu),
  );
  return { service, dieuKienDem };
}

describe('Hồ sơ uy tín kèm theo mỗi dòng kỷ luật', () => {
  it('trả cả tỷ lệ huỷ lẫn số cảnh cáo của cùng cửa sổ', async () => {
    const { service } = dungDoc(
      [
        { sitterId: 'ncc-1', kind: 'CANCEL_RATE', _count: { _all: 2 } },
        { sitterId: 'ncc-1', kind: 'WARNING', _count: { _all: 3 } },
        { sitterId: 'ncc-1', kind: 'HIDE', _count: { _all: 1 } },
      ],
      8,
    );

    const ket = (await service.danhSach({})) as {
      items: Array<{ profile: Record<string, number> }>;
    };
    expect(ket.items[0].profile.cancelRate).toBeCloseTo(0.25);
    expect(ket.items[0].profile.warningCount).toBe(3);
    expect(ket.items[0].profile.hiddenTimesInWindow).toBe(1);
  });

  it('bản đã miễn rơi khỏi cả ba phép đếm', async () => {
    const { service, dieuKienDem } = dungDoc([], 8);

    const ket = (await service.danhSach({})) as {
      items: Array<{ profile: Record<string, number> }>;
    };
    // Không có bản nào chưa miễn thì để 0, đây là con số đếm thật chứ không phải chỗ trống
    expect(ket.items[0].profile.warningCount).toBe(0);
    for (const dieu of dieuKienDem) {
      expect(dieu).toMatchObject({ status: { not: 'WAIVED' } });
    }
  });
});

describe('Chưa đủ số đơn tối thiểu thì tỷ lệ huỷ để RỖNG (bộ luật mục 6)', () => {
  it('bốn đơn trên ngưỡng năm thì trả null chứ không phải 0', async () => {
    const { service } = dungDoc(
      [{ sitterId: 'ncc-1', kind: 'CANCEL_RATE', _count: { _all: 1 } }],
      4,
    );

    const ket = (await service.danhSach({})) as {
      items: Array<{ profile: { cancelRate: number | null } }>;
    };
    expect(ket.items[0].profile.cancelRate).toBeNull();
  });

  it('người chăm chưa có đơn nào cũng để rỗng, không đọc thành hồ sơ sạch', async () => {
    const { service } = dungDoc([], 0);

    const ket = (await service.danhSach({})) as {
      items: Array<{ profile: { cancelRate: number | null } }>;
    };
    expect(ket.items[0].profile.cancelRate).toBeNull();
  });

  it('đủ mẫu mà không có lần huỷ nào thì là 0 thật, khác hẳn ca rỗng', async () => {
    const { service } = dungDoc([], 5);

    const ket = (await service.danhSach({})) as {
      items: Array<{ profile: { cancelRate: number | null } }>;
    };
    expect(ket.items[0].profile.cancelRate).toBe(0);
  });
});
