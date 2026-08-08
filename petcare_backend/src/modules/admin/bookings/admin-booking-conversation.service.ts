import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { chatDaKhoa } from '../../messaging/messaging.mapper';

// Trần cứng ở đường đọc của quản trị viên, cắt thì phải nói ra (bộ luật mục 8)
export const TRAN_TIN_TRA_SOAT = 500;

type VaiTraSoat = 'OWNER' | 'SITTER' | 'SYSTEM';

// Bảng lưu ghi PROVIDER, màn tra soát nói SITTER cho khớp cả cụm quản trị
function vaiCua(role: string): VaiTraSoat {
  if (role === 'OWNER') return 'OWNER';
  if (role === 'PROVIDER') return 'SITTER';
  return 'SYSTEM';
}

@Injectable()
export class AdminBookingConversationService {
  constructor(private readonly prisma: PrismaService) {}

  async hoiThoai(code: string) {
    const don = await this.prisma.booking.findUnique({
      where: { code },
      select: {
        code: true,
        status: true,
        completedAt: true,
        cancelledAt: true,
        owner: { select: { fullName: true } },
        sitter: {
          select: { user: { select: { fullName: true } } },
        },
        conversation: {
          select: {
            createdAt: true,
            messages: {
              orderBy: { createdAt: 'asc' },
              // Lấy dư một tin để phân biệt đúng trần với hội thoại bị cắt
              take: TRAN_TIN_TRA_SOAT + 1,
              select: {
                id: true,
                role: true,
                kind: true,
                text: true,
                images: true,
                soAnhThem: true,
                masked: true,
                createdAt: true,
              },
            },
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

    const tin = don.conversation?.messages ?? [];
    const daKhoa = chatDaKhoa(don.status);
    return {
      code: don.code,
      ownerName: don.owner.fullName,
      sitterName: don.sitter.user.fullName,
      openedAt: don.conversation?.createdAt ?? null,
      // Mốc khép thật của đơn, KHÔNG cộng thêm hạn giữ tiền của mục 7
      closedAt: daKhoa ? (don.completedAt ?? don.cancelledAt) : null,
      entries: tin.slice(0, TRAN_TIN_TRA_SOAT).map((t) => ({
        id: t.id,
        sender: vaiCua(t.role),
        kind: t.kind,
        sentAt: t.createdAt,
        // Bản chữ của chủ nuôi, không trộn với bản người chăm
        content: t.text,
        photoCount: t.images.length + (t.soAnhThem ?? 0),
        masked: t.masked,
      })),
      truncated: tin.length > TRAN_TIN_TRA_SOAT,
    };
  }
}
