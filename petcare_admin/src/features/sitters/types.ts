import type { ServiceType } from '@/features/dashboard/chart-colors';
import type { ServicePricing } from '@/features/services/types';

export const SITTER_STATUSES = ['PENDING', 'APPROVED', 'REJECTED'] as const;
export type SitterStatus = (typeof SITTER_STATUSES)[number];

export type SitterState = 'pending' | 'active' | 'rejected' | 'hidden' | 'banned';

export type SitterTabKey = 'pending' | 'active' | 'rejected' | 'hidden';

export type PetKind = 'DOG' | 'CAT' | 'BOTH';

export type SitterRow = {
  id: string;
  userId: string;
  legalName: string | null;
  fullName: string;
  avatarUrl: string | null;
  submittedAt: string | null;
  onboardedAt: string | null;
  status: SitterStatus;
  province: string | null;
  addressDetail: string | null;
  serviceAddress: string | null;
  services: ServiceType[];
  hasFront: boolean;
  hasBack: boolean;
  ratingAvg: number;
  totalReviews: number;
  hiddenUntil: string | null;
  hiddenCount: number;
  bannedAt: string | null;
};

export type SitterListQuery = {
  q?: string;
  tab?: SitterTabKey;
  service?: ServiceType;
  province?: string;
  page?: number;
  limit?: number;
};

export type SitterListResponse = {
  total: number;
  page: number;
  limit: number;
  items: SitterRow[];
};

export type SitterTabCounts = Record<SitterTabKey, number> & { banned: number };

export type HideSitterResult = {
  id: string;
  hiddenDays: number;
  hiddenCount: number;
  hiddenTimesInWindow: number;
  banned: boolean;
  runningBookingCount: number;
};

export type BanSitterResult = {
  id: string;
  banned: boolean;
  runningBookingCount: number;
  waivedHides: number;
};

export type SitterDetail = {
  sitter: {
    id: string;
    userId: string;
    legalName: string | null;
    gender: 'MALE' | 'FEMALE' | 'OTHER' | null;
    dateOfBirth: string | null;
    nationalId: string | null;
    idIssuedPlace: string | null;
    idIssuedDate: string | null;
    province: string | null;
    addressDetail: string | null;
    submittedAt: string | null;
    onboardedAt: string | null;
    serviceAddress: string | null;
    serviceAddressNote: string | null;
    serviceRadiusKm: number | null;
    lat: number | null;
    lng: number | null;
    status: SitterStatus;
    hiddenUntil: string | null;
    hiddenCount: number;
    hiddenTimesInWindow: number;
    bannedAt: string | null;
    lastSupplementRequestAt: string | null;
  };
  user: {
    fullName: string;
    email: string;
    phone: string | null;
    createdAt: string;
    avatarUrl: string | null;
  };
  documents: { frontUrl: string | null; backUrl: string | null };
  services: Array<{
    type: ServiceType;
    enabled: boolean;
    petKind: PetKind;
    pricing: ServicePricing;
  }>;
  penalties: Array<{
    id: string;
    kind: PenaltyKind;
    status: 'ACTIVE' | 'PENDING_REVIEW' | 'WAIVED';
    reason: string | null;
    createdAt: string;
    bookingCode: string | null;
  }>;
  stats: {
    bookingCount: number;
    cancelRate: number | null;
    runningBookingCount: number;
    ratingAvg: number;
    totalReviews: number;
  };
};

export type PenaltyKind = 'CANCEL_RATE' | 'WARNING' | 'HIDE';

export type SitterDecision = 'APPROVED' | 'REJECTED';
