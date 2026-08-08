import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { settingsApi } from '@/features/settings/api/settings-api';
import type { AuditLogQuery, UpdateSettingInput } from '@/features/settings/types';

const SETTINGS_KEY = ['admin', 'settings'] as const;

export function useOperatingSettings() {
  return useQuery({
    queryKey: [...SETTINGS_KEY, 'operating'],
    queryFn: settingsApi.getSettings,
    staleTime: 0,
  });
}

export function useUpdateSetting() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateSettingInput) => settingsApi.updateSetting(input),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: [...SETTINGS_KEY, 'operating'] });
      void queryClient.invalidateQueries({ queryKey: [...SETTINGS_KEY, 'audit-logs'] });
    },
  });
}

export function useAuditLogs(query: AuditLogQuery) {
  return useQuery({
    queryKey: [...SETTINGS_KEY, 'audit-logs', query],
    queryFn: () => settingsApi.getAuditLogs(query),
    placeholderData: keepPreviousData,
  });
}

export function useAuditLogFilters() {
  return useQuery({
    queryKey: [...SETTINGS_KEY, 'audit-log-filters'],
    queryFn: settingsApi.getAuditLogFilters,
  });
}

export function useAdminAccount() {
  return useQuery({
    queryKey: [...SETTINGS_KEY, 'admin-account'],
    queryFn: settingsApi.getAdminAccount,
  });
}

export function useLimitGroups() {
  return useQuery({
    queryKey: [...SETTINGS_KEY, 'limits'],
    queryFn: settingsApi.getLimitGroups,
    staleTime: Infinity,
  });
}
