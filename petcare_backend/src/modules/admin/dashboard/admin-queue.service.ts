import { Injectable } from '@nestjs/common';
import { MOT_NGAY_MS } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';

// Một dòng chỉ nằm ở đây khi chỉ quản trị viên làm được và chậm là có hậu quả
export const KHOA_VIEC = [
  'sitterPending',
  'disputeReview',
  'withdrawalPending',
  'penaltyReview',
] as const;

export type KhoaViec = (typeof KHOA_VIEC)[number];

const NHAN: Record<KhoaViec, string> = {
  sitterPending: 'Hồ sơ người chăm chờ duyệt',
  disputeReview: 'Khiếu nại chờ kết luận',
  withdrawalPending: 'Người chăm chờ nhận tiền rút',
  penaltyReview: 'Người chăm xin miễn phạt',
};

const CON_VIEC: Record<KhoaViec, string> = {
  sitterPending: 'Hồ sơ đang chờ bạn duyệt',
  disputeReview: 'Chưa kết luận thì tiền của đơn vẫn bị giữ',
  withdrawalPending: 'Đã trừ ví, chờ bạn chuyển khoản',
  penaltyReview: 'Chưa soát thì án phạt vẫn còn hiệu lực',
};

const HET_VIEC: Record<KhoaViec, string> = {
  sitterPending: 'Không còn hồ sơ nào chờ duyệt',
  disputeReview: 'Không còn khiếu nại nào chờ kết luận',
  withdrawalPending: 'Không còn lệnh rút nào chờ chuyển',
  penaltyReview: 'Không còn ai xin miễn phạt',
};

type SoHangCho = {
  sitterPending: number;
  sitterOldest: Date | null;
  disputeReview: number;
  withdrawalPending: number;
  penaltyReview: number;
};

@Injectable()
export class AdminQueueService {
  constructor(private readonly prisma: PrismaService) {}

  async danhSach() {
    const bayGio = new Date();
    const so = await this.dem(bayGio);

    const items = KHOA_VIEC.map((key) => {
      const count = so[key];
      return {
        key,
        label: NHAN[key],
        count,
        hint: this.dongPhu(key, count, so.sitterOldest, bayGio),
      };
    });
    return {
      total: items.reduce((tong, muc) => tong + muc.count, 0),
      items,
    };
  }

  // Bốn phép đếm đi chung một câu, chuông gọi lại mỗi 60 giây nên lượt nào cũng đáng kể
  private async dem(bayGio: Date): Promise<SoHangCho> {
    const dong = await this.prisma.$queryRaw<SoHangCho[]>`
      SELECT
        (SELECT count(*) FROM "Sitter" WHERE "status" = 'PENDING')::int AS "sitterPending",
        (SELECT MIN(COALESCE("submittedAt", "createdAt")) FROM "Sitter"
          WHERE "status" = 'PENDING') AS "sitterOldest",
        (SELECT count(*) FROM "ViolationReport"
          WHERE "status" = 'REVIEWING'
             OR ("status" = 'OPEN' AND "replyDeadline" < ${bayGio}))::int AS "disputeReview",
        (SELECT count(*) FROM "Withdrawal" WHERE "status" = 'PENDING')::int AS "withdrawalPending",
        (SELECT count(*) FROM "SitterPenalty"
          WHERE "status" = 'PENDING_REVIEW')::int AS "penaltyReview"`;
    return dong[0];
  }

  private dongPhu(
    key: KhoaViec,
    count: number,
    cuNhat: Date | null,
    bayGio: Date,
  ): string {
    if (count === 0) return HET_VIEC[key];
    if (key !== 'sitterPending' || !cuNhat) return CON_VIEC[key];
    const ngay = Math.floor(
      (bayGio.getTime() - cuNhat.getTime()) / MOT_NGAY_MS,
    );
    if (ngay <= 0) return 'Hồ sơ cũ nhất nộp trong hôm nay';
    return `Hồ sơ cũ nhất đã chờ ${ngay} ngày`;
  }
}
