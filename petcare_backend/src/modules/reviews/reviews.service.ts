import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { MOT_NGAY_MS, gioVn, ngayThangVn } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { LOAI_RA_APP } from '../bookings/booking-enums';
import { AnhKyService } from '../media/anh-ky.service';
import { BUCKET_ANH_DON } from '../media/anh-duong-dan';
import { AnhTaiLenService } from '../media/anh-tai-len.service';
import { type UploadedImage } from '../media/image-upload';
import { BookingNotifyService } from '../notifications/booking-notify.service';
import { SitterScoreService } from '../search/sitter-score.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { raApp, thongKe } from './review-mapper';
import { CHON_DANH_GIA, NGAY_DUOC_PHAN_HOI } from './review-select';
import { ReplyReviewDto } from './dto/reply-review.dto';

export const NGAY_DUOC_DANH_GIA = 7;
export const TRAN_MOI_TRANG = 20;

const TRANG_THAI_XONG = ['COMPLETED'] as const;

const BUCKET_DANH_GIA = BUCKET_ANH_DON;

@Injectable()
export class ReviewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notify: BookingNotifyService,
    private readonly diem: SitterScoreService,
    private readonly anh: AnhTaiLenService,
    private readonly kyAnh: AnhKyService,
  ) {}

  async cuaNguoiCham(
    sitterId: string,
    opts: {
      truoc?: string;
      rating?: number;
      service?: string;
      coAnh?: boolean;
    },
  ) {
    const dieuKien: Prisma.ReviewWhereInput = {
      booking: {
        sitterId,
        ...(opts.service
          ? { service: { type: this.maDbCuaLoai(opts.service) } }
          : {}),
      },
      ...(opts.rating ? { rating: opts.rating } : {}),
      ...(opts.truoc ? { createdAt: { lt: new Date(opts.truoc) } } : {}),
      ...(opts.coAnh ? { NOT: { photos: { isEmpty: true } } } : {}),
    };
    const rows = await this.prisma.review.findMany({
      where: dieuKien,
      select: CHON_DANH_GIA,
      orderBy: { createdAt: 'desc' },
      take: TRAN_MOI_TRANG + 1,
    });
    const conNua = rows.length > TRAN_MOI_TRANG;
    const items = conNua ? rows.slice(0, TRAN_MOI_TRANG) : rows;
    const [ky, stats] = await Promise.all([
      this.kyAnh.kyLo(items.flatMap((d) => d.photos)),
      thongKe(this.prisma, sitterId),
    ]);
    return {
      items: items.map((d) => raApp(d, ky)),
      stats,
      truocTiep: conNua
        ? items[items.length - 1].createdAt.toISOString()
        : null,
    };
  }

  // GET /sitter/reviews đánh giá VỀ TÔI, nhìn từ người chăm
  async veToi(sitterId: string, opts: { truoc?: string }) {
    return this.cuaNguoiCham(sitterId, opts);
  }

  // GET /reviews/mine đánh giá CHÍNH TÔI đã viết, nhìn từ chủ nuôi
  async cuaToi(userId: string, truoc?: string) {
    const rows = await this.prisma.review.findMany({
      where: {
        reviewerId: userId,
        ...(truoc ? { createdAt: { lt: new Date(truoc) } } : {}),
      },
      select: CHON_DANH_GIA,
      orderBy: { createdAt: 'desc' },
      take: TRAN_MOI_TRANG + 1,
    });
    const conNua = rows.length > TRAN_MOI_TRANG;
    const items = conNua ? rows.slice(0, TRAN_MOI_TRANG) : rows;
    const [tong, ky] = await Promise.all([
      this.prisma.review.count({ where: { reviewerId: userId } }),
      this.kyAnh.kyLo(items.flatMap((d) => d.photos)),
    ]);
    return {
      items: items.map((d) => raApp(d, ky)),
      total: tong,
      truocTiep: conNua
        ? items[items.length - 1].createdAt.toISOString()
        : null,
    };
  }

  // Đơn đã xong mà chủ nuôi chưa đánh giá và vẫn còn trong hạn
  async donChoDanhGia(userId: string) {
    // Đếm từ lúc đơn chuyển sang hoàn thành, không phải lúc bấm kết thúc (bộ luật mục 7)
    const hanTu = new Date(Date.now() - NGAY_DUOC_DANH_GIA * MOT_NGAY_MS);
    const rows = await this.prisma.booking.findMany({
      where: {
        ownerId: userId,
        status: { in: [...TRANG_THAI_XONG] },
        completedAt: { gte: hanTu },
        review: { is: null },
      },
      select: {
        id: true,
        code: true,
        endedAt: true,
        completedAt: true,
        service: { select: { type: true } },
        sitter: {
          select: { user: { select: { fullName: true, avatarUrl: true } } },
        },
        pets: {
          select: {
            pet: { select: { name: true, species: true, avatarUrl: true } },
          },
        },
      },
      orderBy: { completedAt: 'desc' },
    });
    return rows.map((d) => {
      const xong = d.endedAt ?? new Date();
      const chotLuc = d.completedAt ?? xong;
      const conLai =
        NGAY_DUOC_DANH_GIA -
        Math.floor((Date.now() - chotLuc.getTime()) / MOT_NGAY_MS);
      return {
        id: d.id,
        code: d.code,
        sitterName: d.sitter?.user.fullName ?? '',
        sitterAvatarUrl: d.sitter?.user.avatarUrl ?? null,
        serviceType: LOAI_RA_APP[d.service.type],
        pets: d.pets.map((p) => ({
          name: p.pet.name,
          species: p.pet.species.toLowerCase(),
          avatarUrl: p.pet.avatarUrl,
        })),
        endedAtDateLabel: ngayThangVn(xong),
        endedAtTimeLabel: gioVn(xong),
        daysLeftToReview: Math.max(0, conLai),
      };
    });
  }

  // POST /bookings/:id/review
  async viet(
    userId: string,
    bookingId: string,
    dto: CreateReviewDto,
    files: UploadedImage[] = [],
  ) {
    const don = await this.prisma.booking.findFirst({
      where: { id: bookingId, ownerId: userId },
      select: {
        id: true,
        status: true,
        endedAt: true,
        completedAt: true,
        sitterId: true,
      },
    });
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }
    if (!TRANG_THAI_XONG.includes(don.status as 'COMPLETED')) {
      throw new ConflictException({
        code: 'DON_CHUA_XONG',
        message: 'Đơn xong rồi mới đánh giá được',
      });
    }
    // Đơn cũ chưa có completedAt thì lùi về endedAt, thà rộng tay còn hơn chặn nhầm
    const chotLuc = (don.completedAt ?? don.endedAt)?.getTime() ?? 0;
    if (Date.now() - chotLuc > NGAY_DUOC_DANH_GIA * MOT_NGAY_MS) {
      throw new ConflictException({
        code: 'QUA_HAN_DANH_GIA',
        message: `Chỉ đánh giá được trong ${NGAY_DUOC_DANH_GIA} ngày kể từ khi đơn hoàn thành`,
      });
    }
    const daCo = await this.prisma.review.findUnique({
      where: { bookingId },
      select: { id: true },
    });
    if (daCo) {
      throw new ConflictException({
        code: 'DA_DANH_GIA',
        message: 'Đơn này bạn đã đánh giá rồi',
      });
    }

    // Đẩy ảnh trước khi ghi: ghi xong mà ảnh hỏng thì đánh giá không sửa lại được
    const anh = await this.anh.dayLen(BUCKET_DANH_GIA, bookingId, files);
    const ghi = await this.prisma.review.create({
      data: {
        bookingId,
        reviewerId: userId,
        rating: dto.rating,
        comment: dto.comment ?? null,
        photos: anh,
        praiseTags: dto.praiseTags ?? [],
      },
      select: CHON_DANH_GIA,
    });
    // Đánh giá mới là một trong ba sự kiện làm điểm tĩnh xếp hạng đổi
    await this.capNhatDiemNcc(don.sitterId);
    if (don.sitterId) await this.diem.tinhLai(don.sitterId);
    await this.notify.baoNguoiCham(bookingId, {
      type: 'DANH_GIA',
      titleKey: 'tbDanhGiaMoiTieuDe',
      bodyKey: 'tbDanhGiaMoiNoiDung',
      params: { soSao: dto.rating },
    });
    return raApp(ghi, await this.kyAnh.kyLo(ghi.photos));
  }

  // POST /reviews/:id/reply — người chăm đáp lại, MỘT lần và trong hạn
  async phanHoi(sitterId: string, reviewId: string, dto: ReplyReviewDto) {
    const dg = await this.prisma.review.findUnique({
      where: { id: reviewId },
      select: {
        id: true,
        reply: true,
        createdAt: true,
        booking: { select: { sitterId: true } },
      },
    });
    if (!dg) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DANH_GIA',
        message: 'Không tìm thấy đánh giá này',
      });
    }
    if (dg.booking.sitterId !== sitterId) {
      throw new ForbiddenException({
        code: 'KHONG_PHAI_DANH_GIA_CUA_BAN',
        message: 'Đánh giá này không thuộc đơn của bạn',
      });
    }
    if (dg.reply) {
      throw new ConflictException({
        code: 'DA_PHAN_HOI',
        message: 'Mỗi đánh giá chỉ được đáp lại một lần',
      });
    }
    if (
      Date.now() - dg.createdAt.getTime() >
      NGAY_DUOC_PHAN_HOI * MOT_NGAY_MS
    ) {
      throw new ConflictException({
        code: 'QUA_HAN_PHAN_HOI',
        message: `Chỉ đáp lại được trong ${NGAY_DUOC_PHAN_HOI} ngày`,
      });
    }
    const ghi = await this.prisma.review.update({
      where: { id: reviewId },
      data: { reply: dto.content, replyAt: new Date() },
      select: CHON_DANH_GIA,
    });
    return raApp(ghi, await this.kyAnh.kyLo(ghi.photos));
  }

  // Cất sẵn lên hồ sơ để màn tìm kiếm khỏi cộng lại mỗi lần liệt kê
  private async capNhatDiemNcc(sitterId: string | null) {
    if (!sitterId) return;
    const gop = await this.prisma.review.aggregate({
      where: { booking: { sitterId } },
      _avg: { rating: true },
      _count: true,
    });
    await this.prisma.sitter.update({
      where: { id: sitterId },
      data: {
        ratingAvg: gop._avg.rating ?? 0,
        totalReviews: gop._count,
      },
    });
  }

  private maDbCuaLoai(ma: string) {
    switch (ma) {
      case 'boarding':
        return 'BOARDING' as const;
      case 'grooming':
        return 'GROOMING' as const;
      default:
        return 'WALKING' as const;
    }
  }
}
