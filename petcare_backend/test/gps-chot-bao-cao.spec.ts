import { PrismaService } from '../src/prisma/prisma.service';
import { GpsService } from '../src/modules/gps/gps.service';

const BAT_DAU = new Date('2026-08-07T01:00:00.000Z');
const KET_THUC = new Date('2026-08-07T01:30:00.000Z');

const DIEM = [
  { latitude: 10.0, longitude: 106.0, clientTs: BAT_DAU },
  { latitude: 10.01, longitude: 106.0, clientTs: KET_THUC },
];

function dungGhi() {
  const daGhi: Array<Record<string, unknown>> = [];
  const daTao: Array<Record<string, unknown>> = [];
  const prisma = {
    daGhi,
    daTao,
    booking: {
      findUnique: () =>
        Promise.resolve({
          id: 'don-1',
          startedAt: BAT_DAU,
          endedAt: KET_THUC,
          service: { type: 'WALKING' },
        }),
    },
    locationTrack: {
      findMany: () => Promise.resolve(DIEM),
      count: () => Promise.resolve(0),
    },
    bookingGpsReport: {
      upsert: (arg: {
        update: Record<string, unknown>;
        create: Record<string, unknown>;
      }) => {
        daGhi.push(arg.update);
        daTao.push(arg.create);
        return Promise.resolve({ id: 'gps-1' });
      },
    },
  };
  const service = new GpsService(prisma as unknown as PrismaService);
  return { service, prisma };
}

describe('Chốt báo cáo lộ trình', () => {
  it('ghi quãng đường và thời lượng đo được từ lộ trình', async () => {
    const { service, prisma } = dungGhi();

    await service.chotBaoCao('don-1');

    expect(prisma.daGhi[0]).toMatchObject({
      totalWaypoints: 2,
      durationMinutes: 30,
    });
    expect(prisma.daGhi[0].totalDistanceM).toBeGreaterThan(1000);
  });

  it('không đụng cờ soát, đó là kết luận của quản trị viên', async () => {
    const { service, prisma } = dungGhi();

    await service.chotBaoCao('don-1');

    expect(prisma.daGhi[0]).not.toHaveProperty('flaggedForReview');
    expect(prisma.daGhi[0]).not.toHaveProperty('suspicionNote');
    expect(prisma.daTao[0]).toMatchObject({ flaggedForReview: false });
  });
});
