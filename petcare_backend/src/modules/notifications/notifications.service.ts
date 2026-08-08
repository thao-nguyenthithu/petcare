import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import type {
  NotificationRole,
  NotificationType,
} from 'generated/prisma/enums';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../firebase/firebase.service';
import { dungCau, type KhoaTin, type ThamSoTin } from './thong-bao-i18n';

export const TRAN_MOI_TRANG = 30;

type TinChung = {
  userId: string;
  type: NotificationType;
  role: NotificationRole;
  urgent?: boolean;
  targetId?: string | null;
};

// Khoá để dịch, hoặc chuỗi thô
export type TinMoi = TinChung &
  (
    | {
        titleKey: KhoaTin;
        bodyKey: KhoaTin;
        params?: ThamSoTin;
        title?: never;
        body?: never;
      }
    | {
        title: string;
        body: string;
        titleKey?: never;
        bodyKey?: never;
        params?: never;
      }
  );

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly firebase: FirebaseService,
  ) {}
  async tao(tin: TinMoi) {
    const ghi = await this.prisma.notification.create({
      data: {
        userId: tin.userId,
        type: tin.type,
        role: tin.role,
        title: this.cau(tin, 'tieuDe'),
        body: this.cau(tin, 'noiDung'),
        titleKey: tin.titleKey ?? null,
        bodyKey: tin.bodyKey ?? null,
        params: tin.params ?? undefined,
        urgent: tin.urgent ?? false,
        targetId: tin.targetId ?? null,
      },
    });
    void this.dayPush(tin).catch((e: Error) =>
      this.logger.error(`Đẩy push thất bại: ${e.message}`),
    );
    return ghi;
  }

  async taoNhieu(danhSach: TinMoi[]) {
    await Promise.all(danhSach.map((t) => this.tao(t)));
  }

  private cau(tin: TinMoi, phan: 'tieuDe' | 'noiDung', locale = 'vi'): string {
    if (phan === 'tieuDe') {
      return tin.titleKey
        ? dungCau(tin.titleKey, tin.params, locale)
        : tin.title;
    }
    return tin.bodyKey ? dungCau(tin.bodyKey, tin.params, locale) : tin.body;
  }

  private async dayPush(tin: TinMoi) {
    const thietBi = await this.prisma.deviceToken.findMany({
      where: { userId: tin.userId },
      select: { token: true, locale: true },
    });
    if (thietBi.length === 0) {
      this.logger.warn(
        `Bỏ push cho ${tin.userId}: chưa có thiết bị nào đăng ký nhận`,
      );
      return;
    }
    const theoNgonNgu = new Map<string, string[]>();
    for (const t of thietBi) {
      theoNgonNgu.set(t.locale, [
        ...(theoNgonNgu.get(t.locale) ?? []),
        t.token,
      ]);
    }
    const data = {
      type: tin.type,
      role: tin.role,
      ...(tin.targetId ? { targetId: tin.targetId } : {}),
    };
    const tokenChet = (
      await Promise.all(
        [...theoNgonNgu].map(([locale, tokens]) =>
          this.firebase.guiPush(tokens, {
            title: this.cau(tin, 'tieuDe', locale),
            body: this.cau(tin, 'noiDung', locale),
            data,
          }),
        ),
      )
    ).flat();
    if (tokenChet.length > 0) {
      await this.prisma.deviceToken.deleteMany({
        where: { token: { in: tokenChet } },
      });
    }
  }

  // Cuộn theo con trỏ thời gian
  async danhSach(
    userId: string,
    opts: { truoc?: string; role?: NotificationRole; take?: number } = {},
  ) {
    const take = Math.min(opts.take ?? TRAN_MOI_TRANG, TRAN_MOI_TRANG);
    const rows = await this.prisma.notification.findMany({
      where: {
        userId,
        ...(opts.role ? { role: opts.role } : {}),
        ...(opts.truoc ? { createdAt: { lt: new Date(opts.truoc) } } : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: take + 1,
    });
    const conNua = rows.length > take;
    const items = conNua ? rows.slice(0, take) : rows;
    return {
      items: items.map((n) => ({
        id: n.id,
        type: n.type,
        role: n.role,
        title: n.title,
        body: n.body,
        titleKey: n.titleKey,
        bodyKey: n.bodyKey,
        params: n.params,
        urgent: n.urgent,
        targetId: n.targetId,
        isRead: n.isRead,
        createdAt: n.createdAt.toISOString(),
      })),
      truocTiep: conNua
        ? items[items.length - 1].createdAt.toISOString()
        : null,
    };
  }

  async soChuaDoc(userId: string) {
    const soLuong = await this.prisma.notification.count({
      where: { userId, isRead: false },
    });
    return { soLuong };
  }

  async danhDauDaDoc(userId: string, id: string) {
    const ketQua = await this.prisma.notification.updateMany({
      where: { id, userId },
      data: { isRead: true },
    });
    if (ketQua.count === 0) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_THONG_BAO',
        message: 'Không tìm thấy thông báo này',
      });
    }
    return { id, isRead: true };
  }

  async danhDauDocHet(userId: string) {
    const ketQua = await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
    return { soLuong: ketQua.count };
  }

  async luuThietBi(
    userId: string,
    token: string,
    platform: string,
    locale = 'vi',
  ) {
    await this.prisma.deviceToken.upsert({
      where: { token },
      create: { userId, token, platform, locale },
      update: { userId, platform, locale },
    });
    return { daLuu: true };
  }

  async xoaThietBi(token: string) {
    await this.prisma.deviceToken.deleteMany({ where: { token } });
    return { daXoa: true };
  }
}
