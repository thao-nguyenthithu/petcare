import { ServiceType } from '../../../generated/prisma/client';
import { LECH_VN_MS } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { TRANG_THAI_GIU_CHO, sucChua } from './sitter-search.helpers';


export async function demNgayNghi(
  prisma: PrismaService,
  nccIds: string[],
  khoang: { tu: Date; den: Date } | null,
) {
  const ket = new Map<string, number>();
  if (!khoang) return ket;
  const ngayNghi = await prisma.sitterDaySetting.groupBy({
    by: ['sitterId'],
    where: {
      sitterId: { in: nccIds },
      mode: 'OFF',
      date: { gte: khoang.tu, lte: khoang.den },
    },
    _count: { _all: true },
  });
  for (const e of ngayNghi) ket.set(e.sitterId, e._count._all);
  return ket;
}

export async function demNgayKinCho(
  prisma: PrismaService,
  ncc: { id: string; services: { type: ServiceType; pricing: unknown }[] }[],
  khoang: { tu: Date; den: Date; soNgay: number },
  loaiDv?: ServiceType,
) {
  const ket = new Map<string, number>();
  if (loaiDv !== 'BOARDING') return ket;
  const sucChuaTheoNcc = new Map<string, number>();
  for (const e of ncc) {
    const cho = e.services
      .filter((s) => s.type === 'BOARDING')
      .map((s) => sucChua(s.pricing))
      .find((v): v is number => v !== null);
    if (cho !== undefined) sucChuaTheoNcc.set(e.id, cho);
  }
  if (sucChuaTheoNcc.size === 0) return ket;

  const MOT_NGAY = 24 * 60 * 60 * 1000;
  const don = await prisma.booking.findMany({
    where: {
      sitterId: { in: [...sucChuaTheoNcc.keys()] },
      status: { in: [...TRANG_THAI_GIU_CHO] },
      scheduledAt: { lte: new Date(khoang.den.getTime() + MOT_NGAY) },
    },
    select: { sitterId: true, scheduledAt: true, endedAt: true },
  });

  const demTheoNgay = new Map<string, Map<number, number>>();
  for (const d of don) {
    const batDau = new Date(d.scheduledAt);
    const ketThuc = d.endedAt ? new Date(d.endedAt) : batDau;
    const theoNgay = demTheoNgay.get(d.sitterId) ?? new Map<number, number>();
    for (
      let ngay = Math.max(moc(batDau), moc(khoang.tu));
      ngay <= Math.min(moc(ketThuc), moc(khoang.den));
      ngay += MOT_NGAY
    ) {
      theoNgay.set(ngay, (theoNgay.get(ngay) ?? 0) + 1);
    }
    demTheoNgay.set(d.sitterId, theoNgay);
  }
  for (const [sitterId, cho] of sucChuaTheoNcc) {
    const theoNgay = demTheoNgay.get(sitterId);
    if (theoNgay === undefined) continue;
    let soNgayKin = 0;
    for (const so of theoNgay.values()) if (so >= cho) soNgayKin += 1;
    ket.set(sitterId, soNgayKin);
  }
  return ket;
}

export function moc(d: Date) {
  const vn = new Date(d.getTime() + LECH_VN_MS);
  return (
    Date.UTC(vn.getUTCFullYear(), vn.getUTCMonth(), vn.getUTCDate()) -
    LECH_VN_MS
  );
}

export async function tinhTyLeHuy(
  prisma: PrismaService,
  ncc: { id: string; userId: string }[],
  ngayCuaSo: number,
) {
  const ket = new Map<string, number>();
  if (ncc.length === 0) return ket;
  const ids = ncc.map((e) => e.id);

  const tuNgay = new Date(Date.now() - ngayCuaSo * 24 * 3600_000);
  const [tongDon, donHuy] = await Promise.all([
    prisma.booking.groupBy({
      by: ['sitterId'],
      where: { sitterId: { in: ids }, createdAt: { gte: tuNgay } },
      _count: { _all: true },
    }),
    prisma.sitterPenalty.groupBy({
      by: ['sitterId'],
      where: {
        sitterId: { in: ids },
        kind: 'CANCEL_RATE',
        status: { not: 'WAIVED' },
        createdAt: { gte: tuNgay },
      },
      _count: { _all: true },
    }),
  ]);

  const huyTheoNcc = new Map(donHuy.map((d) => [d.sitterId, d._count._all]));
  for (const e of tongDon) {
    const tong = e._count._all;
    ket.set(
      e.sitterId,
      tong === 0 ? 0 : (huyTheoNcc.get(e.sitterId) ?? 0) / tong,
    );
  }
  return ket;
}
