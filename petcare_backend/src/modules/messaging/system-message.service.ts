import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export type NoiDungTinHeThong = {
  text: string;
  textSitter?: string;
  actionLabel?: string;
  actionLabelSitter?: string;
  canGap?: boolean;
  images?: string[];
  soAnhThem?: number;
  caption?: string;
};

@Injectable()
export class SystemMessageService {
  constructor(private readonly prisma: PrismaService) {}

  async ghi(bookingId: string, noiDung: NoiDungTinHeThong) {
    const hoiThoai = await this.prisma.conversation.upsert({
      where: { bookingId },
      create: { bookingId },
      update: {},
      select: { id: true },
    });
    const laAnh = (noiDung.images?.length ?? 0) > 0;
    const [tin] = await this.prisma.$transaction([
      this.prisma.message.create({
        data: {
          bookingId,
          conversationId: hoiThoai.id,
          senderId: null,
          role: 'SYSTEM',
          kind: laAnh ? 'IMAGE' : 'SYSTEM',
          text: noiDung.text,
          textSitter: noiDung.textSitter ?? null,
          actionLabel: noiDung.actionLabel ?? null,
          actionLabelSitter: noiDung.actionLabelSitter ?? null,
          canGap: noiDung.canGap ?? false,
          images: noiDung.images ?? [],
          soAnhThem: noiDung.soAnhThem ?? null,
          caption: noiDung.caption ?? null,
        },
      }),
      this.prisma.conversation.update({
        where: { id: hoiThoai.id },
        data: { lastMessage: noiDung.text, lastMessageAt: new Date() },
      }),
    ]);
    return { conversationId: hoiThoai.id, tin };
  }
}
