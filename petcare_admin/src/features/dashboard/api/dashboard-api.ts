import type { DashboardData, QueueData } from '@/features/dashboard/types';
import { apiClient } from '@/lib/api/client';

export const dashboardApi = {
  async getDashboard(): Promise<DashboardData> {
    const { data } = await apiClient.get<DashboardData>('/admin/dashboard');
    return data;
  },

  async getQueue(): Promise<QueueData> {
    const { data } = await apiClient.get<QueueData>('/admin/queue');
    return data;
  },
};
