import { Prisma } from 'generated/prisma/client';
import { LOAI_RA_APP, MA_TRANG_THAI } from '../bookings/booking-enums';


export const CHON_DON_VI = {
  id: true,
  code: true,
  status: true,
  scheduledAt: true,
  scheduledEndAt: true,
  endedAt: true,
  durationMinutes: true,
  totalPrice: true,
  sitterPayout: true,
  platformFee: true,
  priceBreakdown: true,
  cancellationReason: true,
  owner: { select: { fullName: true } },
  service: { select: { name: true, type: true } },
  pets: { select: { pet: { select: { name: true, species: true } } } },
} satisfies Prisma.BookingSelect;

export type DonVi = Prisma.BookingGetPayload<{ select: typeof CHON_DON_VI }>;

function soDem(bd: unknown): number {
  const o = bd as { nights?: number } | null;
  return typeof o?.nights === 'number' ? o.nights : 0;
}

export function raTheDon(d: DonVi) {
  const loai = LOAI_RA_APP[d.service.type];
  return {
    id: d.id,
    code: d.code,
    status: MA_TRANG_THAI[d.status],
    serviceType: loai,
    serviceName: d.service.name,
    ownerName: d.owner.fullName,
    pets: d.pets.map((e) => ({
      name: e.pet.name,
      species: e.pet.species === 'CAT' ? 'cat' : 'dog',
    })),
    startAt: d.scheduledAt,
    endAt: d.scheduledEndAt,
    durationMinutes: d.durationMinutes,
    nights: loai === 'boarding' ? soDem(d.priceBreakdown) : null,
    totalPrice: d.totalPrice ?? 0,
    sitterAmount: khoanNccNhan(d),
    cancellationReason: d.cancellationReason,
  };
}

export function khoanNccNhan(d: {
  sitterPayout: number | null;
  totalPrice: number | null;
  platformFee: number | null;
}): number {
  if (d.sitterPayout != null) return d.sitterPayout;
  return Math.max(0, (d.totalPrice ?? 0) - (d.platformFee ?? 0));
}
