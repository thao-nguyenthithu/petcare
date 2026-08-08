import type {
  BookingEvidence,
  EvidenceQuery,
  EvidenceResponse,
  EvidenceSourceCounts,
} from '@/features/evidence/types';
import { apiClient } from '@/lib/api/client';

export const evidenceApi = {
  async getEvidence(query: EvidenceQuery): Promise<EvidenceResponse> {
    const { data } = await apiClient.get<EvidenceResponse>('/admin/evidence', {
      params: query,
    });
    return data;
  },

  async getSourceCounts(): Promise<EvidenceSourceCounts> {
    const { data } = await apiClient.get<EvidenceSourceCounts>('/admin/evidence/counts');
    return data;
  },

  async getBookingEvidence(code: string): Promise<BookingEvidence> {
    const { data } = await apiClient.get<BookingEvidence>(
      `/admin/bookings/${encodeURIComponent(code)}/evidence`,
    );
    return data;
  },
};
