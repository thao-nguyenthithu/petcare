export const PENALTY_KINDS = ['CANCEL_RATE', 'WARNING', 'HIDE'] as const;
export type PenaltyKind = (typeof PENALTY_KINDS)[number];

export const PENALTY_STATUSES = ['ACTIVE', 'PENDING_REVIEW', 'WAIVED'] as const;
export type PenaltyStatus = (typeof PENALTY_STATUSES)[number];

export type PenaltyTabKey = 'pendingReview' | 'active' | 'waived' | 'hidden';

export type PenaltyProfile = {
  cancelRate: number | null;
  warningCount: number;
  hiddenCount: number;
  hiddenTimesInWindow: number;
  hiddenUntil: string | null;
  bannedAt: string | null;
};

export type PenaltyRow = {
  id: string;
  sitterId: string;
  sitterName: string;
  kind: PenaltyKind;
  status: PenaltyStatus;
  reason: string | null;
  createdAt: string;
  reviewDeadline: string | null;
  bookingCode: string | null;
  serviceName: string | null;
  profile: PenaltyProfile;
};

export type PenaltyListQuery = {
  q?: string;
  tab?: PenaltyTabKey;
  kind?: PenaltyKind;
  page?: number;
  limit?: number;
};

export type PenaltyListResponse = {
  total: number;
  page: number;
  limit: number;
  items: PenaltyRow[];
};

export type PenaltyTabCounts = Record<PenaltyTabKey, number>;
