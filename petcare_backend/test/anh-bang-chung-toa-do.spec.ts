import { PetSafetyScanReadService } from '../src/modules/sitter/orders/pet-safety-scan-read.service';
import { type PrismaService } from '../src/prisma/prisma.service';

type DongGhi = {
  slotIndex?: number | null;
  photoLat?: number | null;
  photoLng?: number | null;
};

// Toạ độ nằm ở PetSafetyScan, ảnh bằng chứng là bản sao sang SessionPhoto; sao thiếu thì mất bằng chứng mà không ai báo
function dungService(quet: unknown[], xacNhan: unknown[]) {
  const daGhi: DongGhi[] = [];
  const prisma = {
    checkinScanBatch: {
      findFirst: () =>
        Promise.resolve({ anhCaDanUrl: 'https://kho/ca-dan.jpg' }),
    },
    petSafetyScan: { findMany: () => Promise.resolve(quet) },
    checkinSlotXacNhan: { findMany: () => Promise.resolve(xacNhan) },
    sessionPhoto: {
      createMany: (arg: { data: DongGhi[] }) => {
        daGhi.push(...arg.data);
        return Promise.resolve({ count: arg.data.length });
      },
    },
  };
  const service = new PetSafetyScanReadService(
    prisma as unknown as PrismaService,
    {} as never,
    { nhaAi: () => 'anthropic' } as never,
    {} as never,
  );
  return { service, daGhi };
}

function dongQuet(slot: number, lat: number | null, lng: number | null) {
  return {
    slotIndex: slot,
    trangThai: 'DAT',
    code: 'DAT',
    confidence: 0.9,
    canhDaiPx: 2000,
    tinhLuot: true,
    photoUrl: `https://kho/be-${slot}.jpg`,
    lat,
    lng,
  };
}

describe('Toạ độ của ảnh bằng chứng check-in', () => {
  it('chép toạ độ từ lượt quét sang ảnh bằng chứng', async () => {
    const { service, daGhi } = dungService(
      [dongQuet(1, 21.0278, 105.8342)],
      [],
    );

    await service.luuAnhBangChung('don-1', 1);

    const cuaBe = daGhi.find((d) => d.slotIndex === 1);
    expect(cuaBe?.photoLat).toBe(21.0278);
    expect(cuaBe?.photoLng).toBe(105.8342);
  });

  it('máy không bắt được vị trí thì để trống, không lấy toạ độ của bé khác', async () => {
    const { service, daGhi } = dungService(
      [dongQuet(1, 21.0278, 105.8342), dongQuet(2, null, null)],
      [],
    );

    await service.luuAnhBangChung('don-1', 2);

    expect(daGhi.find((d) => d.slotIndex === 2)?.photoLat).toBeNull();
  });

  it('tấm cả đàn không mang toạ độ vì lô ảnh không giữ cột nào', async () => {
    const { service, daGhi } = dungService(
      [dongQuet(1, 21.0278, 105.8342)],
      [],
    );

    await service.luuAnhBangChung('don-1', 1);

    const caDan = daGhi.find((d) => d.slotIndex === 0);
    expect(caDan?.photoLat).toBeUndefined();
  });
});
