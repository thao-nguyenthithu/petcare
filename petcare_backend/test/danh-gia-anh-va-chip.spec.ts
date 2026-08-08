import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { PrismaService } from '../src/prisma/prisma.service';
import { AnhTaiLenService } from '../src/modules/media/anh-tai-len.service';
import { type UploadedImage } from '../src/modules/media/image-upload';
import { BookingNotifyService } from '../src/modules/notifications/booking-notify.service';
import { SitterScoreService } from '../src/modules/search/sitter-score.service';
import {
  CreateReviewDto,
  SO_CHIP_KHEN,
} from '../src/modules/reviews/dto/create-review.dto';
import { ReviewsService } from '../src/modules/reviews/reviews.service';
import { anhKyGia } from './anh-ky-gia';

const CHU_NUOI = 'u-chu-nuoi';

function loiDau(dto: object): string {
  const ban = plainToInstance(CreateReviewDto, dto);
  const loi = validateSync(ban);
  return loi.length ? Object.keys(loi[0].constraints ?? {})[0] : '';
}

function anh(so: number): UploadedImage[] {
  return Array.from({ length: so }, () => ({}));
}

function dungGhi() {
  const daGhi: Array<Record<string, unknown>> = [];
  const daDay: UploadedImage[][] = [];
  const prisma = {
    daGhi,
    booking: {
      findFirst: () =>
        Promise.resolve({
          id: 'don-1',
          status: 'COMPLETED',
          endedAt: new Date(),
          completedAt: new Date(),
          sitterId: 'ncc-1',
        }),
    },
    review: {
      findUnique: () => Promise.resolve(null),
      create: (arg: { data: Record<string, unknown> }) => {
        daGhi.push(arg.data);
        return Promise.resolve({
          id: 'dg-1',
          rating: arg.data.rating,
          comment: null,
          photos: arg.data.photos,
          praiseTags: arg.data.praiseTags,
          reply: null,
          replyAt: null,
          createdAt: new Date(),
          reviewer: { fullName: 'Hoa' },
          booking: {
            id: 'don-1',
            sitterId: 'ncc-1',
            service: { name: 'Dắt đi dạo', type: 'WALKING' },
            pets: [],
          },
        });
      },
      aggregate: () => Promise.resolve({ _avg: { rating: 5 }, _count: 1 }),
      count: () => Promise.resolve(1),
    },
    sitter: { update: () => Promise.resolve({}) },
  };
  const anhTaiLen = {
    dayLen: (_b: string, _t: string, files: UploadedImage[]) => {
      daDay.push(files);
      return Promise.resolve(files.map((_, i) => `https://kho/anh-${i}.jpg`));
    },
  };
  const service = new ReviewsService(
    prisma as unknown as PrismaService,
    {
      baoNguoiCham: () => Promise.resolve(),
    } as unknown as BookingNotifyService,
    { tinhLai: () => Promise.resolve() } as unknown as SitterScoreService,
    anhTaiLen as unknown as AnhTaiLenService,
    anhKyGia().service,
  );
  return { service, prisma, daDay };
}

describe('Đánh giá nhận tệp ảnh và chip khen', () => {
  it('ảnh đi thẳng từ tệp, cột photos lưu URL do máy chủ sinh', async () => {
    const { service, prisma, daDay } = dungGhi();

    await service.viet(CHU_NUOI, 'don-1', { rating: 5 }, anh(2));

    expect(daDay[0]).toHaveLength(2);
    expect(prisma.daGhi[0].photos).toEqual([
      'https://kho/anh-0.jpg',
      'https://kho/anh-1.jpg',
    ]);
  });

  it('không gửi ảnh vẫn viết được đánh giá', async () => {
    const { service, prisma } = dungGhi();

    await service.viet(CHU_NUOI, 'don-1', { rating: 4 }, []);

    expect(prisma.daGhi[0].photos).toEqual([]);
  });

  it('chip khen lưu đúng mã, không dịch và không kiểm danh sách', async () => {
    const { service, prisma } = dungGhi();

    await service.viet(
      CHU_NUOI,
      'don-1',
      { rating: 5, praiseTags: ['DUNG_GIO', 'AN_CAN'] },
      [],
    );

    expect(prisma.daGhi[0].praiseTags).toEqual(['DUNG_GIO', 'AN_CAN']);
  });

  it('quá trần chip khen thì DTO chặn', () => {
    const qua = Array.from({ length: SO_CHIP_KHEN + 1 }, (_, i) => `C${i}`);
    expect(loiDau({ rating: 5, praiseTags: qua })).toBe('arrayMaxSize');
  });

  it('multipart gửi chip khen dạng chuỗi ngăn phẩy vẫn ra mảng', () => {
    const ban = plainToInstance(CreateReviewDto, {
      rating: 5,
      praiseTags: 'DUNG_GIO,AN_CAN',
    });
    expect(ban.praiseTags).toEqual(['DUNG_GIO', 'AN_CAN']);
  });

  it('multipart gửi số sao dạng chuỗi vẫn qua được kiểm tra', () => {
    expect(loiDau({ rating: '5' })).toBe('');
    expect(loiDau({ rating: '9' })).toBe('max');
  });
});
