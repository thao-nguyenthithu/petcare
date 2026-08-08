import { Prisma } from 'generated/prisma/client';
import { BookingStatus } from 'generated/prisma/enums';

export const CHON = {
  id: true,
  code: true,
  status: true,
  scheduledAt: true,
  scheduledEndAt: true,
  acceptedAt: true,
  departedAt: true,
  ownerDepartedAt: true,
  ownerReturnDepartedAt: true,
  arrivedAt: true,
  startedAt: true,
  endedAt: true,
  cancelledAt: true,
  cancellationReason: true,
  cancellationNote: true,
  noShowProofUrls: true,
  cancellationFee: true,
  createdAt: true,
  paidAt: true,
  totalPrice: true,
  platformFeePercent: true,
  cancelFeePercent: true,
  escrowReleaseAt: true,
  durationMinutes: true,
  priceBreakdown: true,
  specialNotes: true,
  addressText: true,
  addressLat: true,
  addressLng: true,
  service: { select: { type: true, name: true } },
  gpsReport: {
    select: {
      totalWaypoints: true,
      totalDistanceM: true,
      durationMinutes: true,
    },
  },
  sitter: {
    select: {
      id: true,
      ratingAvg: true,
      totalReviews: true,
      serviceAddress: true,
      lat: true,
      lng: true,
      user: { select: { fullName: true, avatarUrl: true } },
    },
  },
  pets: {
    select: {
      packageCode: true,
      durationMinutes: true,
      price: true,
      pet: {
        select: {
          id: true,
          name: true,
          species: true,
          breed: true,
          gender: true,
          birthDate: true,
          weightKg: true,
          isNeutered: true,
          underTreatment: true,
          chronicDisease: true,
          medication: true,
          careNote: true,
          avatarUrl: true,
          preventions: {
            orderBy: { createdAt: 'asc' },
            select: {
              id: true,
              code: true,
              customName: true,
              form: true,
              isPeriodic: true,
              suggestedCycleValue: true,
              suggestedCycleUnit: true,
              doses: {
                orderBy: { doneAt: 'desc' },
                select: {
                  id: true,
                  doneAt: true,
                  cycleValue: true,
                  cycleUnit: true,
                  place: true,
                },
              },
            },
          },
        },
      },
    },
  },
} satisfies Prisma.BookingSelect;

export type DonChiTiet = Prisma.BookingGetPayload<{ select: typeof CHON }>;

export type DongGiaLuu = {
  key: string;
  amount: number;
  petId?: string;
  meta?: Record<string, number | string>;
};

export const TRANG_THAI_HUY_DUOC: BookingStatus[] = ['PENDING', 'CONFIRMED'];
