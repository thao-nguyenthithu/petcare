import type { ServiceType } from '@/features/dashboard/chart-colors';

export const BOOKING_STATUSES = [
  'AWAITING_PAYMENT',
  'PENDING',
  'CONFIRMED',
  'IN_PROGRESS',
  'AWAITING_OWNER_CONFIRM',
  'COMPLETED',
  'CANCELLED_BY_OWNER',
  'CANCELLED_BY_SITTER',
  'CANCELLED_EXPIRED',
  'CANCELLED_UNPAID',
  'CANCELLED_NO_SHOW',
  'CANCELLED_BY_ADMIN',
  'DISPUTED',
  'RESOLVED',
] as const;

export type BookingStatus = (typeof BOOKING_STATUSES)[number];

export type BookingTabKey =
  | 'all'
  | 'awaitingPayment'
  | 'pending'
  | 'confirmed'
  | 'running'
  | 'awaitingConfirm'
  | 'completed'
  | 'cancelled'
  | 'disputed';

export type AdminBookingRow = {
  code: string;
  ownerName: string;
  petNames: string[];
  sitterName: string;
  sitterRating: number;
  serviceType: ServiceType;
  serviceName: string;
  durationMinutes: number | null;
  scheduledAt: string;
  scheduledEndAt: string | null;
  totalPrice: number | null;
  createdAt: string;
  status: BookingStatus;
};

export type BookingListQuery = {
  q?: string;
  tab?: BookingTabKey;
  serviceType?: ServiceType;
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
};

export type BookingListResponse = {
  total: number;
  page: number;
  limit: number;
  items: AdminBookingRow[];
};

export type PaymentStatus =
  | 'PENDING'
  | 'HELD'
  | 'FAILED'
  | 'EXPIRED'
  | 'RELEASED'
  | 'REFUNDING'
  | 'REFUNDED';

export type BookingDetail = {
  booking: {
    code: string;
    status: BookingStatus;
    serviceType: ServiceType;
    serviceName: string;
    durationMinutes: number | null;
    scheduledAt: string;
    scheduledEndAt: string | null;
    addressText: string | null;
    totalPrice: number | null;
    platformFee: number | null;
    sitterPayout: number | null;
    cancellationFee: number | null;
    createdAt: string;
    paidAt: string | null;
    acceptedAt: string | null;
    acceptDeadlineAt: string | null;
    departedAt: string | null;
    arrivedAt: string | null;
    arriveDistanceM: number | null;
    startedAt: string | null;
    endedAt: string | null;
    completedAt: string | null;
    escrowReleaseAt: string | null;
    lateMinutes: number | null;
    lateReportedAt: string | null;
    gearReportedAt: string | null;
    ownerArrivedAt: string | null;
    distanceKm: number | null;
    noShowProofUrls: string[];
  };
  owner: { id: string; fullName: string; email: string; avatarUrl: string | null };
  sitter: {
    id: string;
    userId: string;
    fullName: string;
    email: string;
    ratingAvg: number;
    avatarUrl: string | null;
  };
  pets: Array<{
    id: string;
    name: string;
    breed: string;
    birthDate: string | null;
    weightKg: number;
    durationMinutes: number | null;
    price: number | null;
  }>;
  payment: {
    status: PaymentStatus;
    txnRef: string;
    gatewayTxnNo: string | null;
    bankCode: string | null;
    cardType: string | null;
    paidAt: string | null;
    releasedAt: string | null;
    expiresAt: string | null;
  } | null;
  gpsReport: GpsReport | null;
  track: Array<{ lat: number; lng: number; clientTs: string; isNoise: boolean }>;
  trackTruncated: boolean;
};

export type BookingConversationEntry = {
  id: string;
  sender: 'OWNER' | 'SITTER' | 'SYSTEM';
  kind: 'TEXT' | 'IMAGE' | 'LOCATION' | 'SYSTEM';
  sentAt: string;
  content: string;
  photoCount: number;
  masked: boolean;
};

export type BookingConversation = {
  code: string;
  ownerName: string;
  sitterName: string;
  openedAt: string | null;
  closedAt: string | null;
  entries: BookingConversationEntry[];
  truncated: boolean;
};

export type GpsReport = {
  totalWaypoints: number;
  totalDistanceM: number;
  durationMinutes: number;
  avgSpeedKmh: number;
  suspicionScore: number | null;
  flaggedForReview: boolean;
  suspicionNote: string | null;
  mockedCount: number;
  speedFlag: boolean;
};

export type GpsDeviationLabel =
  | 'twoThresholds'
  | 'ratioOnly'
  | 'withinError'
  | 'trackingOff'
  | 'noClaim';

export type GpsReportRow = {
  bookingCode: string;
  sitterId: string;
  sitterName: string;
  suspicionScore: number | null;
  flaggedForReview: boolean;
  suspicionNote: string | null;
  totalDistanceM: number;
  claimedDistanceKm: number | null;
  totalWaypoints: number;
  durationMinutes: number;
  avgSpeedKmh: number;
  mockedCount: number;
  speedFlag: boolean;
  reviewedAt: string | null;
  createdAt: string;
};

export type GpsTabKey = 'flagged' | 'reviewed' | 'noClaim' | 'all';

export type GpsTabCounts = Record<GpsTabKey, number>;

export type GpsReportListQuery = {
  q?: string;
  tab?: GpsTabKey;
  flagged?: boolean;
  minScore?: number;
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
};

export type GpsReviewResult = {
  bookingCode: string;
  flaggedForReview: boolean;
};

export type GpsReportListResponse = {
  total: number;
  page: number;
  limit: number;
  items: GpsReportRow[];
};
