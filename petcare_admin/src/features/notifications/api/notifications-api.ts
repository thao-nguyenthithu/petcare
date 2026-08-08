import type {
  AudienceCount,
  AudienceKind,
  BroadcastInput,
  BroadcastResult,
  CampaignListResponse,
} from '@/features/notifications/types';
import { apiClient } from '@/lib/api/client';

export const notificationsApi = {
  async getCampaigns(page: number, limit: number): Promise<CampaignListResponse> {
    const { data } = await apiClient.get<CampaignListResponse>(
      '/admin/notifications/campaigns',
      { params: { page, limit } },
    );
    return data;
  },

  async getProvinces(): Promise<string[]> {
    const { data } = await apiClient.get<string[]>('/admin/provinces');
    return data;
  },

  async getAudienceCount(kind: AudienceKind, value?: string): Promise<AudienceCount> {
    const { data } = await apiClient.get<AudienceCount>('/admin/notifications/audience', {
      params: { kind, value },
    });
    return data;
  },

  async broadcast(input: BroadcastInput): Promise<BroadcastResult> {
    const { data } = await apiClient.post<BroadcastResult>(
      '/admin/notifications/broadcast',
      input,
    );
    return data;
  },

  async cancelCampaign(id: string): Promise<{ id: string; daHuy: boolean }> {
    const { data } = await apiClient.delete<{ id: string; daHuy: boolean }>(
      `/admin/notifications/campaigns/${encodeURIComponent(id)}`,
    );
    return data;
  },
};
