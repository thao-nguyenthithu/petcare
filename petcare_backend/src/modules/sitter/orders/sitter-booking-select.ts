import { Prisma } from 'generated/prisma/client';
import { BookingStatus } from 'generated/prisma/enums';
import { TRANG_THAI_HUY } from '../../bookings/booking-enums';
import { NhomDonNccDto } from './dto/sitter-order.dto';

export const NHOM_TRANG_THAI: Record<NhomDonNccDto, BookingStatus[]> = {
  pending: ['PENDING'],
  upcoming: ['CONFIRMED'],
  ongoing: ['IN_PROGRESS'],
  waitConfirm: ['AWAITING_OWNER_CONFIRM'],
  completed: ['COMPLETED', 'RESOLVED'],
  cancelled: [...TRANG_THAI_HUY, 'DISPUTED'],
};

export const MOI_TRANG_MAC_DINH = 20;
export const PHUT_MO_NUT_BAT_DAU = 15;
export const GIO_MO_DIA_CHI = 2;
export const CHON_DONG = {
  id: true,
  code: true,
  status: true,
  scheduledAt: true,
  scheduledEndAt: true,
  startedAt: true,
  endedAt: true,
  createdAt: true,
  paidAt: true,
  totalPrice: true,
  platformFee: true,
  platformFeePercent: true,
  cancelFeePercent: true,
  sitterPayout: true,
  escrowReleaseAt: true,
  durationMinutes: true,
  priceBreakdown: true,
  service: { select: { type: true, name: true } },
  owner: { select: { fullName: true, avatarUrl: true } },
  address: { select: { ward: true, province: true } },
  pets: { select: { pet: { select: { name: true, species: true } } } },
} satisfies Prisma.BookingSelect;

export type DongDon = Prisma.BookingGetPayload<{ select: typeof CHON_DONG }>;

export const CHON_CHI_TIET = {
  ...CHON_DONG,
  acceptedAt: true,
  departedAt: true,
  arrivedAt: true,
  arriveDistanceM: true,
  ownerArrivedAt: true,
  pickupDistanceKm: true,
  gearReportedAt: true,
  lateMinutes: true,
  etaAt: true,
  lateReportedAt: true,
  cancelledAt: true,
  cancellationReason: true,
  cancellationNote: true,
  noShowProofUrls: true,
  cancellationFee: true,
  sitterPayout: true,
  sitterNote: true,
  handoverNote: true,
  distanceKm: true,
  specialNotes: true,
  addressText: true,
  addressLat: true,
  addressLng: true,
  gearCommittedAt: true,
  owner: { select: { id: true, fullName: true, avatarUrl: true } },
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
  sessionPhotos: {
    orderBy: { takenAt: 'asc' },
    select: {
      id: true,
      photoUrl: true,
      phase: true,
      anhDoDung: true,
      takenAt: true,
    },
  },
  gpsReport: { select: { totalWaypoints: true, totalDistanceM: true } },
  boardingUpdates: {
    orderBy: { createdAt: 'desc' },
    select: {
      id: true,
      message: true,
      conditions: true,
      photoUrls: true,
      createdAt: true,
    },
  },
} satisfies Prisma.BookingSelect;

export type DonChiTiet = Prisma.BookingGetPayload<{
  select: typeof CHON_CHI_TIET;
}>;

export type DongGiaLuu = {
  key: string;
  amount: number;
  petId?: string;
  meta?: Record<string, number | string>;
};
