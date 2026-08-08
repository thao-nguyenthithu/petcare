import type { BookingStatus } from '@/features/bookings/types';
import type { ServiceType } from '@/features/dashboard/chart-colors';

export type RecentBooking = {
  code: string;
  ownerName: string;
  ownerPhone: string | null;
  serviceName: string;
  durationMinutes: number | null;
  status: BookingStatus;
  totalPrice: number | null;
};

export type DashboardData = {
  users: { total: number; delta: number | null };
  sitters: { active: number; pending: number; delta: number | null };
  bookings: { thisMonth: number; ongoing: number; delta: number | null };
  revenue: {
    total: number;
    commission: number;
    escrowHeld: number;
    delta: number | null;
  };
  revenueByMonth: Array<{ month: number; sitterPayout: number; platformFee: number }>;
  serviceMix: Array<{ type: ServiceType; count: number; percent: number }>;
  recentBookings: RecentBooking[];
};

export type QueueKey = 'sitterPending' | 'disputeReview' | 'withdrawalPending' | 'penaltyReview';

export type QueueItem = {
  key: QueueKey;
  label: string;
  count: number;
  hint: string;
};

export type QueueData = {
  total: number;
  items: QueueItem[];
};
