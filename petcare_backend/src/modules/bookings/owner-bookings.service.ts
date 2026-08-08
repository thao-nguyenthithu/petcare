import { Injectable } from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { BookingStatus } from 'generated/prisma/enums';
import { PrismaService } from '../../prisma/prisma.service';
import {
  LOAI_RA_APP,
  LOAI_RA_DB,
  TRANG_THAI_AN,
  TRANG_THAI_HUY,
} from './booking-enums';
import { hanNhanDonCua, maTrangThaiHieuLuc } from './booking-time';
import { ListBookingsDto, NhomDonDto } from './dto/list-bookings.dto';

const NHOM_TRANG_THAI: Record<NhomDonDto, BookingStatus[]> = {
  pending: ['PENDING'],
  upcoming: ['CONFIRMED'],
  ongoing: ['IN_PROGRESS', 'AWAITING_OWNER_CONFIRM', 'DISPUTED'],
  completed: ['COMPLETED', 'RESOLVED'],
  cancelled: TRANG_THAI_HUY,
};

const MOI_TRANG_MAC_DINH = 20;

const CHON = {
  id: true,
  code: true,
  status: true,
  scheduledAt: true,
  scheduledEndAt: true,
  endedAt: true,
  escrowReleaseAt: true,
  createdAt: true,
  paidAt: true,
  totalPrice: true,
  service: { select: { type: true, name: true } },
  sitter: { select: { user: { select: { fullName: true, avatarUrl: true } } } },
  pets: {
    select: {
      pet: { select: { id: true, name: true, species: true, avatarUrl: true } },
    },
  },
} satisfies Prisma.BookingSelect;

type DonTrongDanhSach = Prisma.BookingGetPayload<{ select: typeof CHON }>;

@Injectable()
export class OwnerBookingsService {
  constructor(private readonly prisma: PrismaService) {}

  async danhSachCuaToi(userId: string, dto: ListBookingsDto) {
    const trang = dto.page ?? 1;
    const moiTrang = dto.limit ?? MOI_TRANG_MAC_DINH;
    const dieuKien = this.dieuKien(userId, dto);
    const [tong, dons] = await Promise.all([
      this.prisma.booking.count({ where: dieuKien }),
      this.prisma.booking.findMany({
        where: dieuKien,
        orderBy: { scheduledAt: this.chieuSap(dto.status) },
        skip: (trang - 1) * moiTrang,
        take: moiTrang,
        select: CHON,
      }),
    ]);
    return {
      items: dons.map((d) => this.raDong(d)),
      total: tong,
      page: trang,
      limit: moiTrang,
    };
  }

  private dieuKien(
    userId: string,
    dto: ListBookingsDto,
  ): Prisma.BookingWhereInput {
    const tuKhoa = dto.q;
    return {
      ownerId: userId,
      ...(dto.status
        ? { status: { in: NHOM_TRANG_THAI[dto.status] } }
        : { status: { notIn: TRANG_THAI_AN } }),
      ...(dto.serviceType
        ? { service: { type: LOAI_RA_DB[dto.serviceType] } }
        : {}),
      ...(tuKhoa
        ? {
            OR: [
              {
                pets: {
                  some: {
                    pet: { name: { contains: tuKhoa, mode: 'insensitive' } },
                  },
                },
              },
              {
                sitter: {
                  user: {
                    fullName: { contains: tuKhoa, mode: 'insensitive' },
                  },
                },
              },
              { service: { name: { contains: tuKhoa, mode: 'insensitive' } } },
            ],
          }
        : {}),
    };
  }

  private chieuSap(nhom?: NhomDonDto): Prisma.SortOrder {
    return nhom === 'pending' || nhom === 'upcoming' || nhom === 'ongoing'
      ? 'asc'
      : 'desc';
  }

  private raDong(d: DonTrongDanhSach) {
    return {
      id: d.id,
      code: d.code,
      status: maTrangThaiHieuLuc(d),
      serviceType: LOAI_RA_APP[d.service.type],
      serviceName: d.service.name,
      sitterName: d.sitter.user.fullName,
      sitterAvatarUrl: d.sitter.user.avatarUrl,
      pets: d.pets.map((e) => ({
        id: e.pet.id,
        name: e.pet.name,
        species: e.pet.species === 'CAT' ? 'cat' : 'dog',
        avatarUrl: e.pet.avatarUrl,
      })),
      startAt: d.scheduledAt,
      endAt: d.scheduledEndAt,
      deadlineAt: this.hanCua(d),
      priceAmount: d.totalPrice ?? 0,
    };
  }

  private hanCua(d: DonTrongDanhSach): Date | null {
    if (d.status === 'PENDING') return hanNhanDonCua(d);
    if (d.status === 'AWAITING_OWNER_CONFIRM') return d.escrowReleaseAt;
    return null;
  }
}
