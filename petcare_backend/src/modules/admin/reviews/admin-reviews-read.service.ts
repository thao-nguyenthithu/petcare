import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { MOT_NGAY_MS } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { NGAY_DUOC_PHAN_HOI } from '../../reviews/review-select';
import { dungTrang, kepTrang } from '../chung/phan-trang';
import { LocDanhGiaDto } from './dto/loc-danh-gia.dto';

// Chưa ai đáp là còn đáp được, đánh giá quá hạn đã chốt nên không cần ai xem nữa
function conHanDap(bayGio: Date): Prisma.ReviewWhereInput {
  return {
    reply: null,
    createdAt: {
      gt: new Date(bayGio.getTime() - NGAY_DUOC_PHAN_HOI * MOT_NGAY_MS),
    },
  };
}

const CO_ANH: Prisma.ReviewWhereInput = { photos: { isEmpty: false } };

// Mốc sao của tab đánh giá thấp, màn gửi ratingTo bằng đúng số này
const SAO_THAP_TOI_DA = 2;

@Injectable()
export class AdminReviewsReadService {
  constructor(private readonly prisma: PrismaService) {}

  private dieuKien(loc: LocDanhGiaDto): Prisma.ReviewWhereInput {
    const dieu: Prisma.ReviewWhereInput = {};
    if (loc.ratingFrom || loc.ratingTo) {
      dieu.rating = {
        ...(loc.ratingFrom ? { gte: loc.ratingFrom } : {}),
        ...(loc.ratingTo ? { lte: loc.ratingTo } : {}),
      };
    }
    if (loc.serviceType) dieu.booking = { service: { type: loc.serviceType } };
    if (loc.hasPhotos !== undefined) {
      dieu.photos = loc.hasPhotos ? { isEmpty: false } : { isEmpty: true };
    }
    if (loc.replied !== undefined) {
      dieu.reply = loc.replied ? { not: null } : null;
    }
    if (loc.from || loc.to) {
      dieu.createdAt = {
        ...(loc.from ? { gte: new Date(loc.from) } : {}),
        ...(loc.to ? { lte: new Date(loc.to) } : {}),
      };
    }
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      dieu.AND = [
        {
          OR: [
            { comment: tim },
            { booking: { code: tim } },
            { booking: { sitter: { legalName: tim } } },
            { booking: { sitter: { user: { fullName: tim } } } },
          ],
        },
      ];
    }
    return dieu;
  }

  async danhSach(loc: LocDanhGiaDto) {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);

    const [total, diem, ds] = await Promise.all([
      this.prisma.review.count({ where }),
      // Trung bình của tập đang lọc, KHÔNG lấy Sitter.ratingAvg vì cột đó theo từng người chăm
      this.prisma.review.aggregate({ where, _avg: { rating: true } }),
      this.prisma.review.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          id: true,
          rating: true,
          comment: true,
          photos: true,
          reply: true,
          replyAt: true,
          createdAt: true,
          reviewer: { select: { fullName: true, avatarUrl: true } },
          booking: {
            select: {
              code: true,
              durationMinutes: true,
              service: { select: { name: true, type: true } },
              sitter: {
                select: {
                  user: { select: { fullName: true } },
                },
              },
            },
          },
        },
      }),
    ]);

    const items = ds.map((dg) => ({
      id: dg.id,
      bookingCode: dg.booking.code,
      reviewerName: dg.reviewer.fullName,
      reviewerAvatar: dg.reviewer.avatarUrl,
      createdAt: dg.createdAt,
      sitterName: dg.booking.sitter.user.fullName,
      serviceType: dg.booking.service.type,
      serviceName: dg.booking.service.name,
      durationMinutes: dg.booking.durationMinutes,
      rating: dg.rating,
      comment: dg.comment,
      photos: dg.photos,
      reply: dg.reply,
      replyAt: dg.replyAt,
      // Hạn đáp suy từ lúc gửi đánh giá, không có cột riêng (bộ luật mục 7)
      replyDeadline: new Date(
        dg.createdAt.getTime() + NGAY_DUOC_PHAN_HOI * MOT_NGAY_MS,
      ),
    }));
    return {
      ...dungTrang(items, total, khoang),
      // Tập lọc rỗng thì để trống, trả 0 là vu cho người chăm 0 trên 5 sao
      avgRating: diem._avg.rating,
    };
  }

  async demTab() {
    const bayGio = new Date();
    const [all, lowRating, hasPhotos, noReply] = await Promise.all([
      this.prisma.review.count(),
      this.prisma.review.count({ where: { rating: { lte: SAO_THAP_TOI_DA } } }),
      this.prisma.review.count({ where: CO_ANH }),
      this.prisma.review.count({ where: conHanDap(bayGio) }),
    ]);
    return { all, lowRating, hasPhotos, noReply };
  }
}
