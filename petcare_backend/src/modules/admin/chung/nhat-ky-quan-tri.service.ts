import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import type { HanhDongNhatKy, LoaiDoiTuong } from './hanh-dong-nhat-ky';

export type { LoaiDoiTuong };

export type BanGhiNhatKy = {
  adminId: string;
  // Ép về tập đã khai để không ai ghi được mã mà màn không có nhãn
  action: HanhDongNhatKy;
  targetType: LoaiDoiTuong;
  targetId?: string | null;
  targetCode?: string | null;
  reason?: string | null;
  oldValue?: string | null;
  newValue?: string | null;
};

@Injectable()
export class NhatKyQuanTriService {
  constructor(private readonly prisma: PrismaService) {}

  // Lệnh CHƯA chạy, để gọi nhét vào cùng $transaction với thao tác chính
  lenhGhi(ban: BanGhiNhatKy, db: Prisma.TransactionClient = this.prisma) {
    return db.adminAuditLog.create({
      data: {
        adminId: ban.adminId,
        action: ban.action,
        targetType: ban.targetType,
        targetId: ban.targetId ?? null,
        targetCode: ban.targetCode ?? null,
        reason: ban.reason ?? null,
        oldValue: ban.oldValue ?? null,
        newValue: ban.newValue ?? null,
      },
      select: { id: true },
    });
  }

  async ghi(ban: BanGhiNhatKy): Promise<void> {
    await this.lenhGhi(ban);
  }
}
