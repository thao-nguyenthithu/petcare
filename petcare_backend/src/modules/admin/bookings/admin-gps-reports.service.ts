import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { dungTrang, KetQuaTrang, kepTrang } from '../chung/phan-trang';
import { chonChieu, chonCot } from '../chung/sap-xep';
import { COT_SAP_XEP_GPS, LocGpsDto } from './dto/loc-gps.dto';
import type { TabGps } from './tra-soat-gps';

function dieuKienTab(tab: TabGps): Prisma.BookingGpsReportWhereInput {
  switch (tab) {
    // Hàng chờ là việc CÒN PHẢI LÀM, đơn đã soát mà giữ cờ thì không còn chờ ai
    case 'flagged':
      return { flaggedForReview: true, reviewedAt: null };
    // Có mốc soát mới là đã soát, gồm cả lượt gỡ cờ lẫn lượt giữ cờ
    case 'reviewed':
      return { reviewedAt: { not: null } };
    // Nhóm không đối chiếu được, chính là nhóm mà điểm nghi ngờ không nói gì về nó
    case 'noClaim':
      return { booking: { distanceKm: null } };
    default:
      return {};
  }
}

@Injectable()
export class AdminGpsReportsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
  ) {}

  private dieuKien(loc: LocGpsDto): Prisma.BookingGpsReportWhereInput {
    const dieu: Prisma.BookingGpsReportWhereInput = {
      ...(loc.tab ? dieuKienTab(loc.tab) : {}),
    };
    // Bộ lọc trên thanh công cụ nằm trong AND nên chỉ thu hẹp được điều kiện tab
    const them: Prisma.BookingGpsReportWhereInput[] = [];
    if (loc.flagged !== undefined) them.push({ flaggedForReview: loc.flagged });
    if (loc.minScore !== undefined) {
      them.push({ suspicionScore: { gte: loc.minScore } });
    }
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      them.push({
        booking: {
          OR: [
            { code: tim },
            { sitter: { legalName: tim } },
            { sitter: { user: { fullName: tim } } },
          ],
        },
      });
    }
    if (them.length) dieu.AND = them;
    if (loc.from || loc.to) {
      dieu.createdAt = {
        ...(loc.from ? { gte: new Date(loc.from) } : {}),
        ...(loc.to ? { lte: new Date(loc.to) } : {}),
      };
    }
    return dieu;
  }

  async danhSach(loc: LocGpsDto): Promise<KetQuaTrang<unknown>> {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);
    const cot = chonCot(COT_SAP_XEP_GPS, loc.sort, 'createdAt');
    const chieu = chonChieu(loc.dir, 'desc');
    // Đơn chưa khai km dồn về cuối chứ không nằm lẫn trong dải điểm, xem tab noClaim
    const thuTu: Prisma.BookingGpsReportOrderByWithRelationInput =
      cot === 'suspicionScore'
        ? { suspicionScore: { sort: chieu, nulls: 'last' } }
        : { createdAt: chieu };

    const [total, ds] = await Promise.all([
      this.prisma.bookingGpsReport.count({ where }),
      this.prisma.bookingGpsReport.findMany({
        where,
        orderBy: thuTu,
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          suspicionScore: true,
          flaggedForReview: true,
          suspicionNote: true,
          totalDistanceM: true,
          totalWaypoints: true,
          durationMinutes: true,
          avgSpeedKmh: true,
          mockedCount: true,
          speedFlag: true,
          reviewedAt: true,
          createdAt: true,
          booking: {
            select: {
              code: true,
              distanceKm: true,
              sitter: {
                select: {
                  id: true,
                  user: { select: { fullName: true } },
                },
              },
            },
          },
        },
      }),
    ]);

    const items = ds.map(({ booking, ...r }) => ({
      ...r,
      bookingCode: booking.code,
      sitterId: booking.sitter.id,
      sitterName: booking.sitter.user.fullName,
      // App chưa khai thì để trống, lấp bằng số server là xoá mất chính chỗ lệch
      claimedDistanceKm: booking.distanceKm,
    }));
    return dungTrang(items, total, khoang);
  }

  async demTab() {
    const dem = (tab: TabGps) =>
      this.prisma.bookingGpsReport.count({ where: dieuKienTab(tab) });
    const [all, flagged, reviewed, noClaim] = await Promise.all([
      dem('all'),
      dem('flagged'),
      dem('reviewed'),
      dem('noClaim'),
    ]);
    return { all, flagged, reviewed, noClaim };
  }

  // Chỉ đổi cờ soát và ghi chú: không đụng trạng thái đơn, không đụng tiền (bộ luật mục 8)
  async soat(
    code: string,
    cleared: boolean,
    note: string,
    adminId: string,
  ): Promise<{ bookingCode: string; flaggedForReview: boolean }> {
    const banGhi = await this.prisma.bookingGpsReport.findFirst({
      where: { booking: { code } },
      select: {
        id: true,
        flaggedForReview: true,
        reviewedAt: true,
        booking: { select: { id: true, code: true } },
      },
    });
    if (!banGhi) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_BAO_CAO_GPS',
        message: 'Đơn này không có bản ghi lộ trình nào',
      });
    }
    // Còn cờ là việc chưa khép nên soát lại được, gỡ cờ rồi thì đi đường khiếu nại
    if (!banGhi.flaggedForReview) {
      if (banGhi.reviewedAt) {
        throw new BadRequestException({
          code: 'BAO_CAO_GPS_DA_SOAT',
          message: 'Bản ghi này đã có người soát và gỡ cờ, không soát lại nữa',
        });
      }
      throw new BadRequestException({
        code: 'KHONG_CO_CO_DE_SOAT',
        message: 'Đơn này không bị gắn cờ nên không có gì để soát',
      });
    }

    const conCo = !cleared;
    await this.prisma.$transaction(async (db) => {
      // Kẹp cờ cũ vào where, không thì hai lượt soát cùng lúc ghi hai dòng nhật ký
      const doi = await db.bookingGpsReport.updateMany({
        where: { id: banGhi.id, flaggedForReview: true },
        data: {
          flaggedForReview: conCo,
          suspicionNote: note,
          reviewedAt: new Date(),
        },
      });
      if (doi.count === 0) {
        throw new ConflictException({
          code: 'BAO_CAO_GPS_DA_SOAT',
          message: 'Bản ghi vừa được soát ở nơi khác, tải lại rồi thử tiếp',
        });
      }
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: cleared ? 'GO_CO_GPS' : 'GIU_CO_GPS',
          targetType: 'BOOKING',
          targetId: banGhi.booking.id,
          targetCode: banGhi.booking.code,
          reason: note,
          oldValue: String(banGhi.flaggedForReview),
          newValue: String(conCo),
        },
        db,
      );
    });
    return { bookingCode: banGhi.booking.code, flaggedForReview: conCo };
  }
}
