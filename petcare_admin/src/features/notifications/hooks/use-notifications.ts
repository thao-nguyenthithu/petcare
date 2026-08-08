import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { notificationsApi } from '@/features/notifications/api/notifications-api';
import type { AudienceKind, BroadcastInput } from '@/features/notifications/types';
import { NHOM_CAN_THAM_SO } from '@/features/notifications/types';

const NOTIFICATIONS_KEY = ['admin', 'notifications'] as const;

export function useCampaigns(page: number, limit: number) {
  return useQuery({
    queryKey: [...NOTIFICATIONS_KEY, 'campaigns', page, limit],
    queryFn: () => notificationsApi.getCampaigns(page, limit),
  });
}

export function useProvinces() {
  return useQuery({
    queryKey: [...NOTIFICATIONS_KEY, 'provinces'],
    queryFn: notificationsApi.getProvinces,
    staleTime: 5 * 60_000,
  });
}

export function useAudienceCount(kind: AudienceKind, value?: string) {
  const duThamSo = !NHOM_CAN_THAM_SO.includes(kind) || Boolean(value);
  return useQuery({
    queryKey: [...NOTIFICATIONS_KEY, 'audience', kind, value ?? null],
    queryFn: () => notificationsApi.getAudienceCount(kind, value),
    enabled: duThamSo,
    staleTime: 30_000,
  });
}

export function useBroadcast() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: BroadcastInput) => notificationsApi.broadcast(input),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: NOTIFICATIONS_KEY });
    },
  });
}

export function useCancelCampaign() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => notificationsApi.cancelCampaign(id),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: NOTIFICATIONS_KEY });
    },
  });
}
