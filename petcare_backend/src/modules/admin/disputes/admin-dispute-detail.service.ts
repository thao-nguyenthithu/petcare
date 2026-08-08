import { Injectable, NotFoundException } from '@nestjs/common';
import { ReportStatus } from '../../../../generated/prisma/enums';
import { MOT_NGAY_MS } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { AnhKyService } from '../../media/anh-ky.service';
import { THANG_DEM_VI_PHAM } from './khieu-nai-chung';

const NGAY_MOI_THANG = 30;

function mocCuaSo(bayGio: Date): Date {
  const lui = THANG_DEM_VI_PHAM * NGAY_MOI_THANG * MOT_NGAY_MS;
  return new Date(bayGio.getTime() - lui);
}

@Injectable()
export class AdminDisputeDetailService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly kyAnh: AnhKyService,
  ) {}

  async chiTiet(code: string) {
    const hs = await this.prisma.violationReport.findUnique({
      where: { code },
      select: {
        code: true,
        description: true,
        evidenceUrls: true,
        status: true,
        replyDeadline: true,
        sitterReply: true,
        sitterReplyAt: true,
        sitterReplyPhotos: true,
        resolution: true,
        resolutionReason: true,
        refundAmount: true,
        resolvedAt: true,
        createdAt: true,
        reporterId: true,
        reporter: { select: { id: true, fullName: true } },
        booking: {
          select: {
            id: true,
            code: true,
            ownerId: true,
            totalPrice: true,
            scheduledAt: true,
            arriveDistanceM: true,
            service: { select: { name: true, type: true } },
            sitter: {
              select: {
                id: true,
                user: { select: { id: true, fullName: true } },
              },
            },
            gpsReport: { select: { suspicionNote: true } },
            sessionPhotos: {
              orderBy: { takenAt: 'asc' },
              select: {
                photoUrl: true,
                takenAt: true,
                photoLat: true,
                photoLng: true,
              },
            },
          },
        },
      },
    });
    if (!hs) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_KHIEU_NAI',
        message: 'Không tìm thấy hồ sơ khiếu nại',
      });
    }

    const tuNgay = mocCuaSo(new Date());
    const sitterId = hs.booking.sitter.id;
    const anhPhanAnh = Array.isArray(hs.evidenceUrls)
      ? (hs.evidenceUrls as string[])
      : [];
    const [soViPham, lichSu, ky] = await Promise.all([
      this.prisma.violationReport.count({
        where: {
          booking: { sitterId },
          createdAt: { gte: tuNgay },
          code: { not: hs.code },
        },
      }),
      this.prisma.violationReport.findMany({
        where: {
          booking: { sitterId },
          status: ReportStatus.RESOLVED,
          createdAt: { gte: tuNgay },
          code: { not: hs.code },
        },
        orderBy: { resolvedAt: 'desc' },
        select: {
          code: true,
          resolution: true,
          refundAmount: true,
          resolvedAt: true,
        },
      }),
      // Ba nguồn ảnh của màn đi chung MỘT lượt ký, đừng ký từng khối
      this.kyAnh.kyLo([
        ...anhPhanAnh,
        ...hs.sitterReplyPhotos,
        ...hs.booking.sessionPhotos.map((a) => a.photoUrl),
      ]),
    ]);

    return {
      dispute: {
        code: hs.code,
        bookingCode: hs.booking.code,
        serviceType: hs.booking.service.type,
        serviceName: hs.booking.service.name,
        status: hs.status,
        description: hs.description,
        evidenceUrls: anhPhanAnh.map((u) => ky.get(u) ?? u),
        createdAt: hs.createdAt,
        // Hồ sơ do người chăm mở không có lượt đáp nào, để trống chứ không phải quá hạn
        replyDeadline: hs.replyDeadline,
        sitterReply: hs.sitterReply,
        sitterReplyAt: hs.sitterReplyAt,
        sitterReplyPhotos: hs.sitterReplyPhotos.map((u) => ky.get(u) ?? u),
        resolution: hs.resolution,
        resolutionReason: hs.resolutionReason,
        refundAmount: hs.refundAmount,
        resolvedAt: hs.resolvedAt,
      },
      reporter: {
        id: hs.reporter.id,
        fullName: hs.reporter.fullName,
        role: hs.reporterId === hs.booking.ownerId ? 'OWNER' : 'PROVIDER',
      },
      sitter: {
        id: hs.booking.sitter.id,
        userId: hs.booking.sitter.user.id,
        fullName: hs.booking.sitter.user.fullName,
        violationCount6m: soViPham,
      },
      booking: {
        code: hs.booking.code,
        totalPrice: hs.booking.totalPrice,
        scheduledAt: hs.booking.scheduledAt,
      },
      systemEvidence: {
        gps: hs.booking.gpsReport
          ? {
              distanceFromMeetingM: hs.booking.arriveDistanceM,
              note: hs.booking.gpsReport.suspicionNote,
            }
          : null,
        photos: hs.booking.sessionPhotos.map((anh) => ({
          url: ky.get(anh.photoUrl) ?? anh.photoUrl,
          takenAt: anh.takenAt,
          lat: anh.photoLat,
          lng: anh.photoLng,
        })),
      },
      sitterHistory: lichSu.map((cu) => ({
        code: cu.code,
        title: cu.resolution,
        resolvedAt: cu.resolvedAt,
        refundAmount: cu.refundAmount,
      })),
    };
  }
}
