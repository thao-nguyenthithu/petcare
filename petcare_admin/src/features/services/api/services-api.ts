import type { ServiceType } from '@/features/dashboard/chart-colors';
import type {
  ServiceConstraintRow,
  ServiceRow,
  ServiceUpdateInput,
  SetSitterServiceEnabledInput,
  SitterServiceQuery,
  SitterServiceResponse,
} from '@/features/services/types';
import { apiClient } from '@/lib/api/client';

export const servicesApi = {
  async getServices(): Promise<{ items: ServiceRow[] }> {
    const { data } = await apiClient.get<{ items: ServiceRow[] }>('/admin/services');
    return data;
  },

  async updateService(type: ServiceType, input: ServiceUpdateInput): Promise<ServiceRow> {
    const moTa = input.description.trim();
    const { data } = await apiClient.put<ServiceRow>(
      `/admin/services/${encodeURIComponent(type)}`,
      { name: input.name.trim(), description: moTa ? moTa : undefined },
    );
    return data;
  },

  async getConstraints(): Promise<{ items: ServiceConstraintRow[] }> {
    const { data } = await apiClient.get<{ items: ServiceConstraintRow[] }>(
      '/admin/service-constraints',
    );
    return data;
  },

  async getSitterServices(query: SitterServiceQuery): Promise<SitterServiceResponse> {
    const { data } = await apiClient.get<SitterServiceResponse>('/admin/sitter-services', {
      params: query,
    });
    return data;
  },

  async setSitterServiceEnabled({ id, enabled, reason }: SetSitterServiceEnabledInput) {
    const { data } = await apiClient.patch<{ id: string; enabled: boolean }>(
      `/admin/sitter-services/${encodeURIComponent(id)}/enabled`,
      { enabled, reason: reason.trim() },
    );
    return data;
  },
};
