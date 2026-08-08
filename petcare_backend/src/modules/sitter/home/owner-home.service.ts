import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { LOAI_RA_APP } from '../../bookings/booking-enums';

const SO_NCC_DAT_LAI = 5;

// Home chủ nuôi
@Injectable()
export class OwnerHomeService {
  constructor(private readonly prisma: PrismaService) {}

  async trangChu(userId: string) {
    const [dangChay, datLai] = await Promise.all([
      this.donDangChay(userId),
      this.nguoiChamDaDat(userId),
    ]);
    return { activeOrders: dangChay, recentSitters: datLai };
  }

  private async donDangChay(ownerId: string) {
    const ds = await this.prisma.booking.findMany({
      where: { ownerId, status: 'IN_PROGRESS' },
      orderBy: { startedAt: 'asc' },
      select: {
        id: true,
        code: true,
        startedAt: true,
        scheduledAt: true,
        scheduledEndAt: true,
        durationMinutes: true,
        service: { select: { name: true, type: true } },
        sitter: {
          select: { user: { select: { fullName: true, avatarUrl: true } } },
        },
        pets: { select: { pet: { select: { name: true } } } },
      },
    });
    const bayGio = Date.now();
    return ds.map((d) => {
      const batDau = (d.startedAt ?? d.scheduledAt).getTime();
      const ket =
        d.scheduledEndAt?.getTime() ??
        (d.durationMinutes ? batDau + d.durationMinutes * 60_000 : null);
      const conLai = ket ? Math.round((ket - bayGio) / 60_000) : null;
      return {
        id: d.id,
        code: d.code,
        serviceName: d.service.name,
        serviceType: LOAI_RA_APP[d.service.type],
        sitterName: d.sitter?.user.fullName ?? '',
        sitterAvatar: d.sitter?.user.avatarUrl ?? '',
        petNames: d.pets.map((e) => e.pet.name),
        startedAt: (d.startedAt ?? d.scheduledAt).toISOString(),
        endAt: ket ? new Date(ket).toISOString() : null,
        remainingMinutes: conLai != null && conLai > 0 ? conLai : 0,
        progress:
          ket && ket > batDau
            ? Math.min(1, Math.max(0, (bayGio - batDau) / (ket - batDau)))
            : null,
      };
    });
  }

  private async nguoiChamDaDat(ownerId: string) {
    const ds = await this.prisma.booking.findMany({
      where: {
        ownerId,
        status: 'COMPLETED',
        sitter: { userId: { not: ownerId } },
      },
      orderBy: { scheduledAt: 'desc' },
      select: {
        sitterId: true,
        scheduledAt: true,
        service: { select: { type: true } },
        sitter: {
          select: {
            id: true,
            ratingAvg: true,
            totalReviews: true,
            user: { select: { fullName: true, avatarUrl: true } },
          },
        },
      },
    });

    const gom = new Map<
      string,
      {
        sitter: (typeof ds)[number]['sitter'];
        loai: string;
        soLan: number;
        ganNhat: Date;
      }
    >();
    for (const d of ds) {
      if (!d.sitter) continue;
      const cu = gom.get(d.sitterId);
      if (cu) {
        cu.soLan += 1;
      } else {
        gom.set(d.sitterId, {
          sitter: d.sitter,
          loai: LOAI_RA_APP[d.service.type],
          soLan: 1,
          ganNhat: d.scheduledAt,
        });
      }
    }

    return [...gom.values()]
      .sort((a, b) => b.soLan - a.soLan || +b.ganNhat - +a.ganNhat)
      .slice(0, SO_NCC_DAT_LAI)
      .map((e) => ({
        sitterId: e.sitter.id,
        name: e.sitter.user.fullName ?? '',
        avatar: e.sitter.user.avatarUrl ?? '',
        serviceType: e.loai,
        rating: e.sitter.ratingAvg,
        totalReviews: e.sitter.totalReviews,
        timesBooked: e.soLan,
      }));
  }
}
