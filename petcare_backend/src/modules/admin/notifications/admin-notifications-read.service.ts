import { BadRequestException, Injectable } from '@nestjs/common';
import { NotificationRole } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { dungTrang, KetQuaTrang, kepTrang } from '../chung/phan-trang';
import { LocLuotGuiDto } from './dto/thong-bao-quan-tri.dto';
import {
  lopNguoiNhan,
  NHOM_CAN_THAM_SO,
  NhomNguoiNhan,
  vaiMacDinh,
} from './nguoi-nhan';

export type DongLuotGui = {
  id: string;
  title: string;
  body: string;
  role: NotificationRole;
  audienceKind: string;
  audienceValue: string | null;
  urgent: boolean;
  recipientCount: number;
  readCount: number;
  sentAt: string | null;
  scheduledAt: string | null;
  createdAt: string;
};

@Injectable()
export class AdminNotificationsReadService {
  constructor(private readonly prisma: PrismaService) {}

  async danhSachLuot(loc: LocLuotGuiDto): Promise<KetQuaTrang<DongLuotGui>> {
    const khoang = kepTrang(loc.page, loc.limit);
    const [total, ds] = await Promise.all([
      this.prisma.notificationCampaign.count(),
      this.prisma.notificationCampaign.findMany({
        orderBy: { createdAt: 'desc' },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          id: true,
          title: true,
          body: true,
          role: true,
          audienceKind: true,
          audienceValue: true,
          urgent: true,
          recipientCount: true,
          sentAt: true,
          scheduledAt: true,
          createdAt: true,
        },
      }),
    ]);

    const daDoc = await this.demDaDoc(ds.map((d) => d.id));
    const items = ds.map((d) => ({
      ...d,
      readCount: daDoc.get(d.id) ?? 0,
      sentAt: d.sentAt?.toISOString() ?? null,
      scheduledAt: d.scheduledAt?.toISOString() ?? null,
      createdAt: d.createdAt.toISOString(),
    }));
    return dungTrang(items, total, khoang);
  }

  // Gộp một groupBy cho cả trang, đếm từng lượt là mỗi dòng một lượt đi về
  private async demDaDoc(ids: string[]): Promise<Map<string, number>> {
    if (ids.length === 0) return new Map();
    const nhom = await this.prisma.notification.groupBy({
      by: ['campaignId'],
      where: { campaignId: { in: ids }, isRead: true },
      _count: { _all: true },
    });
    return new Map(
      nhom.map((n) => [n.campaignId ?? '', n._count._all] as const),
    );
  }

  async demNguoiNhan(nhom: NhomNguoiNhan, thamSo?: string | null) {
    if (NHOM_CAN_THAM_SO.includes(nhom) && !thamSo) {
      throw new BadRequestException({
        code: 'THIEU_THAM_SO_NHOM_NHAN',
        message: 'Nhóm người nhận này cần chọn tỉnh hoặc chọn một tài khoản',
      });
    }
    const lop = lopNguoiNhan(nhom, thamSo ?? null, vaiMacDinh(nhom));
    const dem = await Promise.all(
      lop.map((l) => this.prisma.user.count({ where: l.where })),
    );
    return dem.reduce((tong, so) => tong + so, 0);
  }
}
