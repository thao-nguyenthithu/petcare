import type { ServiceType } from '@/features/dashboard/chart-colors';

export type AdminReviewRow = {
  id: string;
  bookingCode: string;
  reviewerName: string;
  reviewerAvatar: string | null;
  createdAt: string;
  sitterName: string;
  serviceType: ServiceType;
  serviceName: string;
  durationMinutes: number | null;
  rating: number;
  comment: string;
  photos: string[];
  reply: string | null;
  replyAt: string | null;
  replyDeadline: string;
};

export type ReviewTabKey = 'all' | 'lowRating' | 'hasPhotos' | 'noReply';

export type ReviewListQuery = {
  q?: string;
  ratingFrom?: number;
  ratingTo?: number;
  serviceType?: ServiceType;
  hasPhotos?: boolean;
  replied?: boolean;
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
};

export type ReviewListResponse = {
  total: number;
  avgRating: number | null;
  page: number;
  limit: number;
  items: AdminReviewRow[];
};
