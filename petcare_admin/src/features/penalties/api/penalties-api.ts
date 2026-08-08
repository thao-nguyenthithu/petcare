import { apiClient } from '@/lib/api/client';
import type {
  PenaltyListQuery,
  PenaltyListResponse,
  PenaltyTabCounts,
} from '@/features/penalties/types';

const TRANG_THAI_CUA_TAB = {
  pendingReview: 'PENDING_REVIEW',
  active: 'ACTIVE',
  waived: 'WAIVED',
} as const;

export const penaltiesApi = {
  async getPenalties(query: PenaltyListQuery): Promise<PenaltyListResponse> {
    const { tab, ...conLai } = query;
    const status = tab && tab !== 'hidden' ? TRANG_THAI_CUA_TAB[tab] : undefined;
    const { data } = await apiClient.get<PenaltyListResponse>('/admin/penalties', {
      params: { ...conLai, ...(status ? { status } : {}) },
    });
    return data;
  },

  async getTabCounts(): Promise<PenaltyTabCounts> {
    const { data } = await apiClient.get<PenaltyTabCounts>('/admin/penalties/counts');
    return data;
  },

  async reviewPenalty(id: string, waived: boolean, note: string) {
    const { data } = await apiClient.patch<{ id: string; status: string }>(
      `/admin/penalties/${id}/review`,
      { waived, note },
    );
    return data;
  },
};
