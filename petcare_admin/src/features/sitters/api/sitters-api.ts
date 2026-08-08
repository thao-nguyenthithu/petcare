import { apiClient } from '@/lib/api/client';
import type {
  BanSitterResult,
  HideSitterResult,
  SitterDecision,
  SitterDetail,
  SitterListQuery,
  SitterListResponse,
  SitterTabCounts,
} from '@/features/sitters/types';

export const sittersApi = {
  async getSitters(query: SitterListQuery): Promise<SitterListResponse> {
    const { data } = await apiClient.get<SitterListResponse>('/admin/sitters', {
      params: query,
    });
    return data;
  },

  async getTabCounts(): Promise<SitterTabCounts> {
    const { data } = await apiClient.get<SitterTabCounts>('/admin/sitters/counts');
    return data;
  },

  async getProvinces(): Promise<string[]> {
    const { data } = await apiClient.get<string[]>('/admin/provinces');
    return data;
  },

  async getSitter(id: string): Promise<SitterDetail> {
    const { data } = await apiClient.get<SitterDetail>(`/admin/sitters/${id}`);
    return data;
  },

  async decideSitter(id: string, decision: SitterDecision, reason?: string) {
    const { data } = await apiClient.patch<{ id: string; status: string }>(
      `/admin/sitters/${id}/status`,
      { status: decision, ...(reason ? { reason } : {}) },
    );
    return data;
  },

  async requestSupplement(id: string, reason: string) {
    const { data } = await apiClient.post<{ id: string }>(
      `/admin/sitters/${id}/supplement-request`,
      { reason },
    );
    return data;
  },

  async hideSitter(id: string, days: number, reason: string): Promise<HideSitterResult> {
    const { data } = await apiClient.patch<HideSitterResult>(
      `/admin/sitters/${id}/hidden`,
      { days, reason },
    );
    return data;
  },

  async banSitter(id: string, banned: boolean, reason: string): Promise<BanSitterResult> {
    const { data } = await apiClient.patch<BanSitterResult>(
      `/admin/sitters/${id}/ban`,
      { banned, reason },
    );
    return data;
  },
};
