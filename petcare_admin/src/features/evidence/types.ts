import type { ServiceType } from '@/features/dashboard/chart-colors';

export type EvidenceSource = 'session' | 'boarding' | 'noShow';

export type SessionPhase = 'CHECK_IN' | 'IN_PROGRESS' | 'CHECK_OUT';

export type EvidenceTabKey = EvidenceSource | 'gpsFlagged';

export type ReportKind = 'GEAR' | 'NO_SHOW' | 'SITTER_ABANDON';

export type DiemAi = {
  aiConfidenceScore: number | null;
  aiPassed: boolean | null;
  anhVanXa: boolean;
};

export type EvidencePhoto = DiemAi & {
  id: string;
  source: EvidenceSource;
  bookingCode: string;
  serviceType: ServiceType;
  serviceName: string;
  url: string;
  phase: SessionPhase | null;
  takenAt: string;
  photoLat: number | null;
  photoLng: number | null;
  conditions: string[];
  anhDoDung: boolean;
  reportKind: ReportKind | null;
};

export type EvidenceQuery = {
  source: EvidenceSource;
  page?: number;
  limit?: number;
};

export type EvidenceResponse = {
  total: number;
  page: number;
  limit: number;
  items: EvidencePhoto[];
};

export type EvidenceSourceCounts = Record<EvidenceTabKey, number>;

export type AlbumPhoto = DiemAi & {
  id: string;
  url: string;
  takenAt: string;
  photoLat: number | null;
  photoLng: number | null;
  distanceFromMeetingM: number | null;
  anhDoDung: boolean;
};

export type EvidenceGroup = {
  key: string;
  dayIndex: number | null;
  date: string | null;
  photoCount: number;
  conditions: string[];
  message: string | null;
  photos: AlbumPhoto[];
};

export type AlbumStats = {
  total: number;
  dayCount: number | null;
  conditionCount: number | null;
  missingDayCount: number | null;
  messageCount: number | null;
};

export type BookingEvidence = {
  booking: {
    code: string;
    serviceType: ServiceType;
    serviceName: string;
    scheduledAt: string;
    scheduledEndAt: string | null;
    reportKind: ReportKind | null;
  };
  groups: EvidenceGroup[];
  stats: AlbumStats;
};
