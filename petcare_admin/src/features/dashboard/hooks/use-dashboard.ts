import { useQuery } from '@tanstack/react-query';
import { dashboardApi } from '@/features/dashboard/api/dashboard-api';

const CHU_KY_LAM_MOI = 60_000;

export const DASHBOARD_KEY = ['admin', 'dashboard'] as const;

export function useDashboard(enabled = true) {
  return useQuery({
    queryKey: DASHBOARD_KEY,
    queryFn: dashboardApi.getDashboard,
    refetchInterval: CHU_KY_LAM_MOI,
    enabled,
  });
}

export const QUEUE_KEY = ['admin', 'queue'] as const;

export function useQueue() {
  return useQuery({
    queryKey: QUEUE_KEY,
    queryFn: dashboardApi.getQueue,
    refetchInterval: CHU_KY_LAM_MOI,
  });
}
