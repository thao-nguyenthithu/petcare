import { PrismaService } from '../src/prisma/prisma.service';
import { GpsService } from '../src/modules/gps/gps.service';

const BAT_DAU = new Date('2026-08-07T01:00:00.000Z');
const KET_THUC = new Date('2026-08-07T01:30:00.000Z');

// Hai điểm cách nhau chừng 1,1 km trong khi app khai 3 km nên thừa sức bật cờ
const DIEM = [
  { latitude: 10.0, longitude: 106.0, clientTs: BAT_DAU },
  { latitude: 10.01, longitude: 106.0, clientTs: KET_THUC },
];

function dungGhi(reviewedAt: Date | null) {
  const daGhi: Array<Record<string, unknown>> = [];
  const prisma = {
    daGhi,
    booking: {
      findUnique: () =>
        Promise.resolve({
          id: 'don-1',
          distanceKm: 3,
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
      findUnique: () => Promise.resolve({ reviewedAt }),
      upsert: (arg: { update: Record<string, unknown> }) => {
        daGhi.push(arg.update);
        return Promise.resolve({ id: 'gps-1' });
      },
    },
  };
  const service = new GpsService(prisma as unknown as PrismaService);
  return { service, prisma };
}

describe('Chốt lại báo cáo lộ trình khi có batch tới muộn', () => {
  it('chưa ai soát thì máy chốt cả cờ lẫn ghi chú', async () => {
    const { service, prisma } = dungGhi(null);

    await service.chotBaoCao('don-1');

    expect(prisma.daGhi[0]).toMatchObject({ flaggedForReview: true });
    expect(prisma.daGhi[0].suspicionNote).toEqual(expect.any(String));
  });

  it('đã soát rồi thì batch muộn chỉ cập nhật con số, không đụng cờ và ghi chú', async () => {
    const { service, prisma } = dungGhi(new Date('2026-08-07T02:00:00.000Z'));

    await service.chotBaoCao('don-1');

    // Ghi đè hai trường này là xoá mất kết luận của người soát, thứ dùng khi có khiếu nại
    expect(prisma.daGhi[0]).not.toHaveProperty('flaggedForReview');
    expect(prisma.daGhi[0]).not.toHaveProperty('suspicionNote');
    expect(prisma.daGhi[0]).toMatchObject({ totalWaypoints: 2 });
  });
});
