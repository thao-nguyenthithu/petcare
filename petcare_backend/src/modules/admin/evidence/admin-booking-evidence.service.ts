import { Injectable, NotFoundException } from '@nestjs/common';
import { ServiceType } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AnhKyService } from '../../media/anh-ky.service';
import { NhomAnh, nhomSuCo, nhomTheoPha, nhomTrongGiu } from './album-nhom';
import { diemHen, kieuBaoSuCo, soDem } from './anh-bang-chung';

const CHON_ANH_PHIEN = {
  id: true,
  photoUrl: true,
  phase: true,
  anhDoDung: true,
  anhVanXa: true,
  photoLat: true,
  photoLng: true,
  takenAt: true,
  aiConfidenceScore: true,
  aiPassed: true,
} as const;

// Bốn ô dưới lưới chỉ có nghĩa với kỳ giữ, trả 0 cho đơn dắt là bịa ra ngày thiếu ảnh
type ThongKe = {
  total: number;
  dayCount: number | null;
  conditionCount: number | null;
  missingDayCount: number | null;
  messageCount: number | null;
};

@Injectable()
export class AdminBookingEvidenceService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly kyAnh: AnhKyService,
  ) {}

  async album(code: string) {
    const don = await this.prisma.booking.findUnique({
      where: { code },
      select: {
        id: true,
        code: true,
        status: true,
        scheduledAt: true,
        scheduledEndAt: true,
        cancelledAt: true,
        gearReportedAt: true,
        updatedAt: true,
        addressLat: true,
        addressLng: true,
        noShowProofUrls: true,
        service: { select: { name: true, type: true } },
        sitter: { select: { lat: true, lng: true } },
        sessionPhotos: { orderBy: { takenAt: 'asc' }, select: CHON_ANH_PHIEN },
        boardingUpdates: {
          orderBy: { createdAt: 'asc' },
          select: {
            id: true,
            message: true,
            conditions: true,
            photoUrls: true,
            createdAt: true,
          },
        },
      },
    });
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }

    const laTrongGiu = don.service.type === ServiceType.BOARDING;
    const diem = diemHen(
      don.service.type,
      { lat: don.addressLat, lng: don.addressLng },
      { lat: don.sitter.lat, lng: don.sitter.lng },
    );
    const nhom: NhomAnh[] = [
      ...(laTrongGiu
        ? nhomTrongGiu(don.sessionPhotos, don.boardingUpdates, diem)
        : nhomTheoPha(don.sessionPhotos, diem)),
      ...nhomSuCo(
        don.id,
        don.noShowProofUrls,
        don.cancelledAt ?? don.gearReportedAt ?? don.updatedAt,
      ),
    ];
    const dem = soDem(don.scheduledAt, don.scheduledEndAt);
    // Ký cả album trong MỘT lượt, ký theo từng nhóm là một lượt mạng mỗi nhóm
    const ky = await this.kyAnh.kyLo(
      nhom.flatMap((n) => n.photos.map((a) => a.url)),
    );
    for (const n of nhom) {
      n.photos = n.photos.map((a) => ({ ...a, url: ky.get(a.url) ?? a.url }));
    }

    return {
      booking: {
        code: don.code,
        serviceType: don.service.type,
        serviceName: don.service.name,
        scheduledAt: don.scheduledAt,
        scheduledEndAt: don.scheduledEndAt,
        reportKind: don.noShowProofUrls.length
          ? kieuBaoSuCo(don.status, don.gearReportedAt)
          : null,
      },
      groups: nhom,
      stats: this.thongKe(nhom, laTrongGiu, dem),
    };
  }

  private thongKe(
    nhom: NhomAnh[],
    laTrongGiu: boolean,
    dem: number | null,
  ): ThongKe {
    const total = nhom.reduce((sum, n) => sum + n.photoCount, 0);
    if (!laTrongGiu) {
      return {
        total,
        dayCount: null,
        conditionCount: null,
        missingDayCount: null,
        messageCount: null,
      };
    }
    const ngay = nhom.filter((n) => n.dayIndex !== null);
    return {
      total,
      dayCount: ngay.length,
      conditionCount: ngay.reduce((sum, n) => sum + n.conditions.length, 0),
      // Chưa chốt ngày trả bé thì không suy ra được kỳ dài bao nhiêu, để trống
      missingDayCount: dem === null ? null : Math.max(0, dem - ngay.length),
      messageCount: ngay.filter((n) => n.message).length,
    };
  }
}
