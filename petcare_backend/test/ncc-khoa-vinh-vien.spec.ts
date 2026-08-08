import { PrismaService } from '../src/prisma/prisma.service';
import { SitterPenaltyService } from '../src/modules/bookings/sitter-penalty.service';
import { SitterWarningNotifyService } from '../src/modules/notifications/sitter-warning-notify.service';
import { SystemSettingsService } from '../src/modules/admin/system-settings.service';
import { SO_LAN_TAM_AN_KHOA } from '../src/modules/bookings/sitter-penalty-rules';

// Bộ luật mục 6: khoá hẳn khi đủ 4 LẦN TẠM ẨN TRONG 6 THÁNG, không phải trọn đời

const MOT_NGAY_MS = 24 * 3600_000;
const BAY_GIO = new Date('2026-08-07T10:00:00+07:00').getTime();

type BanGhi = { kind: string; status: string; createdAt: Date };

function dbGia(hiddenCountTruoc: number, mocAnCu: Date[]) {
  const banGhi: BanGhi[] = mocAnCu.map((createdAt) => ({
    kind: 'HIDE',
    status: 'ACTIVE',
    createdAt,
  }));
  const daCapNhat: Array<Record<string, unknown>> = [];
  let hiddenCount = hiddenCountTruoc;
  const db = {
    banGhi,
    daCapNhat,
    sitter: {
      update: (arg: { data: Record<string, unknown> }) => {
        daCapNhat.push(arg.data);
        if (arg.data.hiddenCount) hiddenCount += 1;
        return Promise.resolve({ hiddenCount });
      },
    },
    sitterPenalty: {
      create: (arg: { data: BanGhi }) => {
        banGhi.push({ ...arg.data, createdAt: new Date(BAY_GIO) });
        return Promise.resolve({ id: 'p-1' });
      },
      count: (arg: { where: { kind?: string; createdAt?: { gte: Date } } }) => {
        const tu = arg.where.createdAt?.gte;
        return Promise.resolve(
          banGhi.filter(
            (b) =>
              (!arg.where.kind || b.kind === arg.where.kind) &&
              (!tu || b.createdAt >= tu),
          ).length,
        );
      },
    },
  };
  return db;
}

function dungService() {
  return new SitterPenaltyService(
    {} as unknown as PrismaService,
    {
      daBiAn: () => Promise.resolve(undefined),
    } as unknown as SitterWarningNotifyService,
    { so: () => 4, tiLe: () => 0.2 } as unknown as SystemSettingsService,
  );
}

// Lần ẩn thứ n trong cửa sổ: truyền n-1 mốc cũ, hàm tự ghi mốc thứ n
function motLanAn(hiddenCountTruoc: number, mocAnCu: Date[]) {
  const db = dbGia(hiddenCountTruoc, mocAnCu);
  return dungService()
    .tamAn('ncc-1', BAY_GIO, 'thử', db as never)
    .then((ket) => ({ ket, db }));
}

const ngayTruoc = (n: number) => new Date(BAY_GIO - n * MOT_NGAY_MS);

describe('Khoá vĩnh viễn theo số lần tạm ẩn trong sáu tháng', () => {
  it('lần ẩn thứ tư trong sáu tháng thì khoá hẳn', async () => {
    const { ket, db } = await motLanAn(3, [
      ngayTruoc(150),
      ngayTruoc(90),
      ngayTruoc(30),
    ]);
    expect(ket.soLanAnGanDay).toBe(SO_LAN_TAM_AN_KHOA);
    expect(ket.khoa).toBe(true);
    expect(db.daCapNhat.some((d) => d.bannedAt)).toBe(true);
  });

  it('ẩn bốn lần nhưng rải quá sáu tháng thì KHÔNG khoá, dù bộ đếm trọn đời đã tới bốn', async () => {
    const { ket, db } = await motLanAn(3, [
      ngayTruoc(900),
      ngayTruoc(600),
      ngayTruoc(300),
    ]);
    expect(ket.hiddenCount).toBe(4);
    expect(ket.soLanAnGanDay).toBe(1);
    expect(ket.khoa).toBe(false);
    expect(db.daCapNhat.some((d) => d.bannedAt)).toBe(false);
  });

  it('ghi mốc tạm ẩn trước khi đếm nên chính lần này cũng được tính', async () => {
    const { db } = await motLanAn(0, []);
    expect(db.banGhi).toHaveLength(1);
    expect(db.banGhi[0].kind).toBe('HIDE');
  });

  it('bậc ngày vẫn leo theo bộ đếm trọn đời: lần ba là 14 ngày', async () => {
    const { ket } = await motLanAn(2, [ngayTruoc(60), ngayTruoc(30)]);
    expect(ket.soNgay).toBe(14);
  });

  it('lối tay ép được số ngày mà vẫn đếm chung một cửa sổ', async () => {
    const { ket } = await motLanAn(0, []);
    expect(ket.soNgay).toBe(3);
    const { ket: ep } = await dungService()
      .tamAn('ncc-1', BAY_GIO, 'tay', dbGia(0, []) as never, 5)
      .then((k) => ({ ket: k }));
    expect(ep.soNgay).toBe(5);
  });
});
