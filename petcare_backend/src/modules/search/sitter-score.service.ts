import { Injectable, Logger } from '@nestjs/common';
import { MOT_NGAY_MS } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { SystemSettingsService } from '../admin/system-settings.service';
import { diemTinh, duMauXetHuy } from './sitter-search.helpers';
import { laNguoiChamTinCay } from './sitter-trusted';

@Injectable()
export class SitterScoreService {
  private readonly logger = new Logger(SitterScoreService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  async tinhLai(sitterId: string): Promise<void> {
    try {
      await this.capNhat(sitterId);
    } catch (loi) {
      this.logger.error(
        `Tính lại điểm tĩnh của người chăm ${sitterId} lỗi`,
        loi as Error,
      );
    }
  }

  private async capNhat(sitterId: string) {
    const tuNgay = new Date(
      Date.now() - this.thamSo.so('penalty.window_days') * MOT_NGAY_MS,
    );
    const [ncc, soHoanThanh, soNganNgu, soHuy] = await Promise.all([
      this.prisma.sitter.findUnique({
        where: { id: sitterId },
        select: { ratingAvg: true, totalReviews: true, lastHiddenAt: true },
      }),
      this.prisma.booking.count({
        where: { sitterId, status: 'COMPLETED' },
      }),
      this.prisma.booking.count({
        where: {
          sitterId,
          status: { notIn: ['PENDING', 'AWAITING_PAYMENT'] },
          createdAt: { gte: tuNgay },
        },
      }),
      this.prisma.sitterPenalty.count({
        where: {
          sitterId,
          kind: 'CANCEL_RATE',
          status: { not: 'WAIVED' },
          createdAt: { gte: tuNgay },
        },
      }),
    ]);
    if (!ncc) return;

    const duMau = duMauXetHuy(soNganNgu);
    const tyLeHuy = soNganNgu === 0 ? 0 : soHuy / soNganNgu;
    const trusted = laNguoiChamTinCay({
      soDonHoanThanh: soHoanThanh,
      ratingAvg: ncc.ratingAvg,
      tyLeHuy: duMau ? tyLeHuy : 0,
      biAnGanDay: ncc.lastHiddenAt !== null && ncc.lastHiddenAt >= tuNgay,
    });
    const diem = diemTinh({
      ratingAvg: ncc.ratingAvg,
      totalReviews: ncc.totalReviews,
      completedOrders: soHoanThanh,
      trusted,
      cancelRate: tyLeHuy,
      duMauXetHuy: duMau,
    });
    await this.prisma.sitter.update({
      where: { id: sitterId },
      data: { staticScore: diem, trustedBadge: trusted },
    });
  }
}
