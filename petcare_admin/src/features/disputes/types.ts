import type { ServiceType } from '@/features/dashboard/chart-colors';

export const DISPUTE_STATUSES = ['OPEN', 'REVIEWING', 'RESOLVED'] as const;

export type DisputeStatus = (typeof DISPUTE_STATUSES)[number];

export type DisputeViewStatus = 'waitingSitter' | 'waitingSupport' | 'refunded' | 'rejected';

export type DisputeTabKey = 'waitingSitter' | 'waitingSupport' | 'resolved';

export type DisputePenalty = 'WARNING' | 'CANCEL_RATE' | 'HIDE';

export type ReporterRole = 'OWNER' | 'PROVIDER';

export type AdminDisputeRow = {
  code: string;
  bookingCode: string;
  serviceType: ServiceType;
  serviceName: string;
  reporterName: string;
  reporterRole: ReporterRole;
  reporterAvatarUrl: string | null;
  sitterName: string;
  description: string;
  createdAt: string;
  replyDeadline: string | null;
  sitterReplyAt: string | null;
  status: DisputeStatus;
  refundAmount: number | null;
};

export type DisputeSort = 'hanKetLuan' | 'moiNhat';

export type DisputeListQuery = {
  q?: string;
  status?: DisputeStatus;
  tab?: DisputeTabKey;
  serviceType?: ServiceType;
  from?: string;
  to?: string;
  sort?: DisputeSort;
  page?: number;
  limit?: number;
};

export type DisputeListResponse = {
  total: number;
  page: number;
  limit: number;
  items: AdminDisputeRow[];
};

export type DisputeEvidencePhoto = {
  url: string;
  takenAt: string;
  lat: number | null;
  lng: number | null;
};

export type SitterViolationHistory = {
  code: string;
  title: string | null;
  resolvedAt: string | null;
  refundAmount: number | null;
};

export type DisputeDetail = {
  dispute: {
    code: string;
    bookingCode: string;
    serviceType: ServiceType;
    serviceName: string;
    status: DisputeStatus;
    description: string;
    evidenceUrls: string[];
    createdAt: string;
    replyDeadline: string | null;
    sitterReply: string | null;
    sitterReplyAt: string | null;
    sitterReplyPhotos: string[];
    resolution: string | null;
    resolutionReason: string | null;
    refundAmount: number | null;
    resolvedAt: string | null;
  };
  reporter: { id: string; fullName: string; role: ReporterRole };
  sitter: {
    id: string;
    userId: string;
    fullName: string;
    violationCount6m: number;
  };
  booking: { code: string; totalPrice: number; scheduledAt: string };
  systemEvidence: {
    gps: { distanceFromMeetingM: number | null; note: string | null } | null;
    photos: DisputeEvidencePhoto[];
  };
  sitterHistory: SitterViolationHistory[];
};

export type ResolveDisputeInput = {
  code: string;
  resolution: string;
  resolutionReason: string;
  refundAmount: number;
  penalty?: DisputePenalty;
  notifyBoth: boolean;
};

export type ResolveDisputeResult = {
  code: string;
  status: DisputeStatus;
  refundAmount: number | null;
  resolvedAt: string;
};
