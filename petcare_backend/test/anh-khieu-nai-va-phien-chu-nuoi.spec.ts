import { PrismaService } from '../src/prisma/prisma.service';
import { AnhTaiLenService } from '../src/modules/media/anh-tai-len.service';
import { type UploadedImage } from '../src/modules/media/image-upload';
import { DisputeService } from '../src/modules/wallet/dispute.service';
import { raChiTiet } from '../src/modules/bookings/owner-booking-detail.mapper';
import { DIEM_MOI_LAN_GUI } from '../src/modules/gps/gps.constants';
import { anhKyGia } from './anh-ky-gia';

const CHU_NUOI = 'u-chu-nuoi';
const NGUOI_CHAM = 'u-ncc';

function anh(so: number): UploadedImage[] {
  return Array.from({ length: so }, () => ({}));
}

// Đủ mọi trường CHON_DON_VI của wallet-booking.mapper, thiếu một cái là raTheDon nổ
const DON_TRONG_HO_SO = {
  id: 'don-1',
  code: 'PC-001',
  status: 'COMPLETED',
  scheduledAt: new Date(),
  scheduledEndAt: new Date(),
  endedAt: new Date(),
  durationMinutes: 60,
  totalPrice: 200000,
  sitterPayout: 170000,
  platformFee: 30000,
  priceBreakdown: null,
  cancellationReason: null,
  owner: { fullName: 'Hoa' },
  service: { name: 'Dắt đi dạo', type: 'WALKING' },
  pets: [{ pet: { name: 'Mun', species: 'DOG' } }],
  ownerId: CHU_NUOI,
  sitter: { userId: NGUOI_CHAM },
};

function dungGhi(hoSo?: Record<string, unknown>) {
  const daTao: Array<Record<string, unknown>> = [];
  const daSua: Array<Record<string, unknown>> = [];
  const daDay: UploadedImage[][] = [];
  const prisma = {
    daTao,
    daSua,
    sitter: {
      findUnique: () =>
        Promise.resolve({ id: 'ncc-1', userId: NGUOI_CHAM, bannedAt: null }),
    },
    booking: {
      findFirst: () =>
        Promise.resolve({
          id: 'don-1',
          code: 'PC-001',
          status: 'COMPLETED',
          startedAt: new Date(),
          endedAt: new Date(),
          cancelledAt: null,
          escrowReleaseAt: new Date(Date.now() + 3_600_000),
        }),
    },
    violationReport: {
      findFirst: () => Promise.resolve(null),
      count: () => Promise.resolve(0),
      findUnique: () =>
        Promise.resolve(
          hoSo ?? {
            id: 'hs-1',
            status: 'OPEN',
            sitterReplyAt: null,
            replyDeadline: new Date(Date.now() + 3_600_000),
            bookingId: 'don-1',
            booking: { sitterId: 'ncc-1' },
          },
        ),
      create: (arg: { data: Record<string, unknown> }) => {
        daTao.push(arg.data);
        return Promise.resolve({ id: 'hs-1', code: 'KN-001', status: 'OPEN' });
      },
      update: (arg: { data: Record<string, unknown> }) => {
        daSua.push(arg.data);
        return Promise.resolve({
          id: 'hs-1',
          code: 'KN-001',
          status: 'REVIEWING',
          description: '',
          evidenceUrls: [],
          sitterReply: arg.data.sitterReply,
          sitterReplyAt: new Date(),
          sitterReplyPhotos: arg.data.sitterReplyPhotos,
          replyDeadline: null,
          resolution: null,
          resolutionReason: null,
          refundAmount: null,
          resolvedAt: null,
          createdAt: new Date(),
          booking: DON_TRONG_HO_SO,
        });
      },
    },
  };
  const anhTaiLen = {
    dayLen: (_b: string, _t: string, files: UploadedImage[]) => {
      daDay.push(files);
      return Promise.resolve(files.map((_, i) => `https://kho/kn-${i}.jpg`));
    },
  };
  const service = new DisputeService(
    prisma as unknown as PrismaService,
    anhTaiLen as unknown as AnhTaiLenService,
    anhKyGia().service,
  );
  return { service, prisma, daDay };
}

describe('Ảnh khiếu nại nhận tệp thẳng', () => {
  it('mở hồ sơ: ảnh thành URL do máy chủ sinh, không nhận URL từ client', async () => {
    const { service, prisma, daDay } = dungGhi();

    await service.mo(
      CHU_NUOI,
      'don-1',
      { description: 'Bé về nhà bị xước' },
      anh(2),
    );

    expect(daDay[0]).toHaveLength(2);
    expect(prisma.daTao[0].evidenceUrls).toEqual([
      'https://kho/kn-0.jpg',
      'https://kho/kn-1.jpg',
    ]);
  });

  it('mở hồ sơ không kèm ảnh vẫn được', async () => {
    const { service, prisma } = dungGhi();

    await service.mo(
      CHU_NUOI,
      'don-1',
      { description: 'Không có ảnh nào' },
      [],
    );

    expect(prisma.daTao[0].evidenceUrls).toEqual([]);
  });

  it('phản hồi: ảnh lưu vào cột riêng của lượt đáp', async () => {
    const { service, prisma } = dungGhi();

    await service.phanHoi(
      NGUOI_CHAM,
      'KN-001',
      { content: 'Tôi có ảnh lúc trả bé' },
      anh(1),
    );

    expect(prisma.daSua[0].sitterReplyPhotos).toEqual(['https://kho/kn-0.jpg']);
  });

  it('quá trần thì trả mã đọc được, không để Multer ném lỗi kỹ thuật', async () => {
    const { service } = dungGhi();

    await expect(
      service.mo(CHU_NUOI, 'don-1', { description: 'Gửi thừa ảnh' }, anh(7)),
    ).rejects.toMatchObject({ response: { code: 'VUOT_GIOI_HAN_ANH' } });
  });

  it('báo sự cố lưu mã lý do riêng, không nhét vào mô tả', async () => {
    const { service, prisma } = dungGhi();

    await service.moBoiNguoiCham(
      NGUOI_CHAM,
      'don-1',
      'Bé không chịu đi tiếp',
      [],
      'BE_KHONG_HOP_TAC',
    );

    expect(prisma.daTao[0]).toMatchObject({
      reasonCode: 'BE_KHONG_HOP_TAC',
      description: 'Bé không chịu đi tiếp',
    });
  });
});

// Dựng đơn tối thiểu đủ cho mapper chạy, chỉ quan tâm khối phiên
function donDat(gpsReport: Record<string, number> | null) {
  return {
    id: 'don-1',
    code: 'PC-001',
    status: 'COMPLETED',
    scheduledAt: new Date(),
    scheduledEndAt: new Date(),
    createdAt: new Date(),
    paidAt: new Date(),
    acceptedAt: new Date(),
    departedAt: null,
    arrivedAt: null,
    startedAt: new Date(),
    endedAt: new Date(),
    cancelledAt: null,
    durationMinutes: 60,
    specialNotes: null,
    priceBreakdown: null,
    totalPrice: 200000,
    platformFeePercent: 15,
    cancelFeePercent: 50,
    gpsReport,
    service: { name: 'Dắt đi dạo', type: 'WALKING' },
    sitter: {
      id: 'ncc-1',
      lat: null,
      lng: null,
      ratingAvg: 5,
      totalReviews: 2,
      serviceAddress: null,
      user: { fullName: 'Nam', avatarUrl: null },
    },
    pets: [],
    payments: [],
  };
}

describe('Khối phiên ở chi tiết đơn chủ nuôi', () => {
  it('trả km và nhịp cập nhật, KHÔNG lộ trường tra soát nội bộ', () => {
    const ra = raChiTiet(
      donDat({
        totalWaypoints: 90,
        totalDistanceM: 1500,
        durationMinutes: 30,
      }) as never,
    ) as { session: Record<string, unknown> | null };

    // 30 phút chia 90 điểm là 20 giây mỗi điểm, gom 10 điểm mới gửi
    expect(ra.session).toEqual({
      distanceKm: 1.5,
      durationMinutes: 30,
      updateEverySeconds: 20 * DIEM_MOI_LAN_GUI,
    });
    expect(JSON.stringify(ra)).not.toContain('suspicion');
    expect(JSON.stringify(ra)).not.toContain('flagged');
  });

  it('chưa chốt báo cáo thì khối phiên là null chứ không phải số 0', () => {
    const ra = raChiTiet(donDat(null) as never) as { session: unknown };

    expect(ra.session).toBeNull();
  });
});
