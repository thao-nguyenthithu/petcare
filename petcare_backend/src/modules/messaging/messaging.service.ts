import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { AnhKyService } from '../media/anh-ky.service';
import { BookingNotifyService } from '../notifications/booking-notify.service';
import { cheThongTinLienLac } from './che-thong-tin';
import {
  chatDaKhoa,
  phutConLai,
  tinTheoVai,
  trangThaiChat,
  type VaiChat,
} from './messaging.mapper';

export const TRANG_TIN = 30;

export type NguCanhGui = {
  userId: string;
  conversationId: string;
  bookingId: string;
  vai: VaiChat;
};

type NoiDungGui = {
  text?: string;
  images?: string[];
  lat?: number;
  lng?: number;
  caption?: string;
};

@Injectable()
export class MessagingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly kyAnh: AnhKyService,
    private readonly notify: BookingNotifyService,
  ) {}

  async moHoiThoai(bookingId: string) {
    return this.prisma.conversation.upsert({
      where: { bookingId },
      create: { bookingId },
      update: {},
    });
  }

  private async layDon(bookingId: string) {
    return this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        ownerId: true,
        status: true,
        sitter: { select: { userId: true } },
      },
    });
  }

  // Vai của người đang gọi trong đơn này
  private async vaiTrongDon(
    userId: string,
    bookingId: string,
  ): Promise<VaiChat> {
    const don = await this.layDon(bookingId);
    if (!don) throw new NotFoundException('Không tìm thấy đơn');
    if (don.ownerId === userId) return 'OWNER';
    if (don.sitter?.userId === userId) return 'PROVIDER';
    throw new ForbiddenException('Bạn không thuộc đơn này');
  }

  // Đọc thẳng cột đếm chưa đọc để khỏi quét bảng Message mỗi lần mở tab
  async danhSach(userId: string, vai: VaiChat) {
    const dieuKienDon =
      vai === 'OWNER' ? { ownerId: userId } : { sitter: { userId } };
    const dsHoiThoai = await this.prisma.conversation.findMany({
      where: { booking: dieuKienDon },
      orderBy: [{ lastMessageAt: 'desc' }, { createdAt: 'desc' }],
      include: {
        booking: {
          select: {
            id: true,
            code: true,
            status: true,
            scheduledAt: true,
            scheduledEndAt: true,
            startedAt: true,
            endedAt: true,
            escrowReleaseAt: true,
            durationMinutes: true,
            owner: { select: { fullName: true, avatarUrl: true } },
            sitter: {
              select: {
                id: true,
                user: { select: { fullName: true, avatarUrl: true } },
              },
            },
            service: { select: { name: true, type: true } },
            pets: {
              select: {
                pet: { select: { name: true, species: true, avatarUrl: true } },
              },
            },
          },
        },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
          select: { senderId: true, text: true, textSitter: true },
        },
      },
    });

    const bayGio = new Date();
    return dsHoiThoai.map((hoiThoai) => {
      const don = hoiThoai.booking;
      const tinCuoi = hoiThoai.messages[0];
      const laChuNuoi = vai === 'OWNER';
      return {
        id: hoiThoai.id,
        bookingId: don.id,
        bookingCode: don.code,
        sitterId: don.sitter?.id ?? null,
        partnerName: laChuNuoi
          ? (don.sitter?.user.fullName ?? 'Người chăm')
          : (don.owner.fullName ?? 'Chủ nuôi'),
        partnerAvatar:
          (laChuNuoi ? don.sitter?.user.avatarUrl : don.owner.avatarUrl) ?? '',
        serviceName: don.service.name,
        serviceType: don.service.type,
        pets: don.pets.map((p) => ({
          name: p.pet.name,
          species: p.pet.species,
          avatarUrl: p.pet.avatarUrl ?? '',
        })),
        state: trangThaiChat(don.status),
        lastMessage: tinCuoi
          ? laChuNuoi
            ? tinCuoi.text
            : (tinCuoi.textSitter ?? tinCuoi.text)
          : hoiThoai.lastMessage,
        lastMessageAt: hoiThoai.lastMessageAt?.toISOString() ?? null,
        unreadCount: laChuNuoi ? hoiThoai.unreadOwner : hoiThoai.unreadSitter,
        fromMe: tinCuoi?.senderId === userId,
        remainingMinutes: phutConLai(don, bayGio),
        locked: chatDaKhoa(don.status),
      };
    });
  }

  async theoDon(userId: string, bookingId: string, vai: VaiChat) {
    await this.vaiTrongDon(userId, bookingId);
    await this.moHoiThoai(bookingId);
    const ds = await this.danhSach(userId, vai);
    return ds.find((c) => c.bookingId === bookingId) ?? null;
  }

  async demChuaDoc(userId: string, vai: VaiChat) {
    const ds = await this.prisma.conversation.findMany({
      where: {
        booking: vai === 'OWNER' ? { ownerId: userId } : { sitter: { userId } },
      },
      select: { unreadOwner: true, unreadSitter: true },
    });
    const tong = ds.reduce(
      (cong, c) => cong + (vai === 'OWNER' ? c.unreadOwner : c.unreadSitter),
      0,
    );
    return { total: tong };
  }

  private async hoiThoaiCuaToi(userId: string, conversationId: string) {
    const hoiThoai = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
      select: { id: true, bookingId: true },
    });
    if (!hoiThoai) throw new NotFoundException('Không tìm thấy hội thoại');
    const vai = await this.vaiTrongDon(userId, hoiThoai.bookingId);
    return { hoiThoai, vai };
  }

  async tinNhan(userId: string, conversationId: string, truoc?: string) {
    const { hoiThoai, vai } = await this.hoiThoaiCuaToi(userId, conversationId);
    const ds = await this.prisma.message.findMany({
      where: {
        conversationId: hoiThoai.id,
        ...(truoc ? { createdAt: { lt: new Date(truoc) } } : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: TRANG_TIN,
    });
    const theoChieuXuoi = [...ds].reverse();
    const ky = await this.kyAnh.kyLo(ds.flatMap((t) => t.images));
    return {
      items: theoChieuXuoi.map((tin) => tinTheoVai(tin, vai, userId, ky)),
      truocTiep:
        ds.length === TRANG_TIN
          ? ds[ds.length - 1].createdAt.toISOString()
          : null,
    };
  }

  async kiemQuyenGui(
    userId: string,
    conversationId: string,
  ): Promise<NguCanhGui> {
    const hoiThoai = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
      select: { id: true, bookingId: true },
    });
    if (!hoiThoai) throw new NotFoundException('Không tìm thấy hội thoại');
    const don = await this.layDon(hoiThoai.bookingId);
    if (!don) throw new NotFoundException('Không tìm thấy đơn');
    const vai: VaiChat =
      don.ownerId === userId
        ? 'OWNER'
        : don.sitter?.userId === userId
          ? 'PROVIDER'
          : (() => {
              throw new ForbiddenException('Bạn không thuộc đơn này');
            })();
    if (chatDaKhoa(don.status)) {
      throw new BadRequestException('Cuộc trò chuyện đã kết thúc');
    }
    return {
      userId,
      conversationId: hoiThoai.id,
      bookingId: hoiThoai.bookingId,
      vai,
    };
  }

  async gui(userId: string, conversationId: string, dto: NoiDungGui) {
    return this.ghiTin(await this.kiemQuyenGui(userId, conversationId), dto);
  }

  async ghiTin(ngu: NguCanhGui, dto: NoiDungGui) {
    const coAnh = (dto.images?.length ?? 0) > 0;
    const coViTri = dto.lat != null && dto.lng != null;
    const chuGoc = dto.text?.trim() ?? '';
    if (!chuGoc && !coAnh && !coViTri) {
      throw new BadRequestException('Tin nhắn trống');
    }
    const daChe = cheThongTinLienLac(chuGoc);
    const kind = coAnh ? 'IMAGE' : coViTri ? 'LOCATION' : 'TEXT';

    const [tin] = await this.prisma.$transaction([
      this.prisma.message.create({
        data: {
          bookingId: ngu.bookingId,
          conversationId: ngu.conversationId,
          senderId: ngu.userId,
          role: ngu.vai,
          kind,
          text: daChe.text,
          masked: daChe.masked,
          images: dto.images ?? [],
          caption: dto.caption ?? null,
          lat: dto.lat ?? null,
          lng: dto.lng ?? null,
        },
      }),
      this.prisma.conversation.update({
        where: { id: ngu.conversationId },
        data: {
          lastMessage: daChe.text || (coAnh ? 'Đã gửi ảnh' : 'Đã gửi vị trí'),
          lastMessageAt: new Date(),
          ...(ngu.vai === 'OWNER'
            ? { unreadSitter: { increment: 1 } }
            : { unreadOwner: { increment: 1 } }),
        },
      }),
    ]);

    await this.notify.tinNhanMoi(ngu.bookingId, ngu.vai === 'OWNER');
    const kyAnh = await this.kyAnh.kyLo(tin.images);
    return {
      conversationId: ngu.conversationId,
      bookingId: ngu.bookingId,
      vaiNguoiGui: ngu.vai,
      tin,
      kyAnh,
    };
  }

  async danhDauDaDoc(userId: string, conversationId: string) {
    const { hoiThoai, vai } = await this.hoiThoaiCuaToi(userId, conversationId);
    await this.prisma.$transaction([
      this.prisma.conversation.update({
        where: { id: hoiThoai.id },
        data: vai === 'OWNER' ? { unreadOwner: 0 } : { unreadSitter: 0 },
      }),
      this.prisma.message.updateMany({
        where: {
          conversationId: hoiThoai.id,
          isRead: false,
          NOT: { senderId: userId },
        },
        data: { isRead: true },
      }),
    ]);
    return { ok: true };
  }

  async duocVaoHoiThoai(
    userId: string,
    conversationId: string,
  ): Promise<VaiChat | null> {
    try {
      const { vai } = await this.hoiThoaiCuaToi(userId, conversationId);
      return vai;
    } catch {
      return null;
    }
  }
}
