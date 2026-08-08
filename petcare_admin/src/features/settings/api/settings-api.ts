import { apiClient } from '@/lib/api/client';
import type {
  AdminAccountInfo,
  AuditLogFilters,
  AuditLogQuery,
  AuditLogResponse,
  LimitGroup,
  OperatingSettingsResponse,
  UpdateSettingInput,
  UpdateSettingResult,
} from '@/features/settings/types';

export const settingsApi = {
  async getSettings(): Promise<OperatingSettingsResponse> {
    const { data } = await apiClient.get<OperatingSettingsResponse>('/admin/settings');
    return data;
  },

  async updateSetting({ key, giaTri, lyDo }: UpdateSettingInput): Promise<UpdateSettingResult> {
    const { data } = await apiClient.put<UpdateSettingResult>(
      `/admin/settings/${encodeURIComponent(key)}`,
      lyDo ? { giaTri, lyDo } : { giaTri },
    );
    return data;
  },

  async getAuditLogs(query: AuditLogQuery): Promise<AuditLogResponse> {
    const { data } = await apiClient.get<AuditLogResponse>('/admin/audit-logs', {
      params: query,
    });
    return data;
  },

  async getAuditLogFilters(): Promise<AuditLogFilters> {
    const { data } = await apiClient.get<AuditLogFilters>('/admin/audit-logs/filters');
    return data;
  },

  async getAdminAccount(): Promise<AdminAccountInfo> {
    const { data } = await apiClient.get<AdminAccountInfo>('/admin/account');
    return data;
  },

  async getLimitGroups(): Promise<LimitGroup[]> {
    const { data } = await apiClient.get<LimitGroup[]>('/admin/limits');
    return data;
  },
};
