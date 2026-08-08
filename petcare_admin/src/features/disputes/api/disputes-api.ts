import type {
  DisputeDetail,
  DisputeListQuery,
  DisputeListResponse,
  DisputeTabKey,
  ResolveDisputeInput,
  ResolveDisputeResult,
} from '@/features/disputes/types';
import { apiClient } from '@/lib/api/client';

export const disputesApi = {
  async getDisputes(query: DisputeListQuery): Promise<DisputeListResponse> {
    const { data } = await apiClient.get<DisputeListResponse>('/admin/disputes', {
      params: query,
    });
    return data;
  },

  async getTabCounts(): Promise<Record<DisputeTabKey, number>> {
    const { data } = await apiClient.get<Record<DisputeTabKey, number>>(
      '/admin/disputes/counts',
    );
    return data;
  },

  async getDispute(code: string): Promise<DisputeDetail> {
    const { data } = await apiClient.get<DisputeDetail>(
      `/admin/disputes/${encodeURIComponent(code)}`,
    );
    return data;
  },

  async resolveDispute({ code, ...than }: ResolveDisputeInput) {
    const { data } = await apiClient.patch<ResolveDisputeResult>(
      `/admin/disputes/${encodeURIComponent(code)}/resolve`,
      than,
    );
    return data;
  },
};
