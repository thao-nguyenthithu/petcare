import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { QUEUE_KEY } from '@/features/dashboard/hooks/use-dashboard';
import { sittersApi } from '@/features/sitters/api/sitters-api';
import type { SitterDecision, SitterListQuery } from '@/features/sitters/types';

const SITTERS_KEY = ['admin', 'sitters'] as const;

export function useSitters(query: SitterListQuery) {
  return useQuery({
    queryKey: [...SITTERS_KEY, 'list', query],
    queryFn: () => sittersApi.getSitters(query),
    placeholderData: keepPreviousData,
  });
}

export function useSitterTabCounts() {
  return useQuery({
    queryKey: [...SITTERS_KEY, 'counts'],
    queryFn: sittersApi.getTabCounts,
  });
}

export function useSitterProvinces() {
  return useQuery({
    queryKey: [...SITTERS_KEY, 'provinces'],
    queryFn: sittersApi.getProvinces,
    staleTime: 5 * 60_000,
  });
}

export function useSitterDetail(id: string) {
  return useQuery({
    queryKey: [...SITTERS_KEY, 'detail', id],
    queryFn: () => sittersApi.getSitter(id),
    enabled: Boolean(id),
  });
}

function useLamMoiNcc() {
  const queryClient = useQueryClient();
  return () => {
    void queryClient.invalidateQueries({ queryKey: SITTERS_KEY });
    void queryClient.invalidateQueries({ queryKey: QUEUE_KEY });
  };
}

export function useDecideSitter() {
  const lamMoi = useLamMoiNcc();
  return useMutation({
    mutationFn: ({
      id,
      decision,
      reason,
    }: {
      id: string;
      decision: SitterDecision;
      reason?: string;
    }) => sittersApi.decideSitter(id, decision, reason),
    onSuccess: lamMoi,
  });
}

export function useRequestSupplement() {
  const lamMoi = useLamMoiNcc();
  return useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) =>
      sittersApi.requestSupplement(id, reason),
    onSuccess: lamMoi,
  });
}

export function useHideSitter() {
  const lamMoi = useLamMoiNcc();
  return useMutation({
    mutationFn: ({ id, days, reason }: { id: string; days: number; reason: string }) =>
      sittersApi.hideSitter(id, days, reason),
    onSuccess: lamMoi,
  });
}

export function useBanSitter() {
  const lamMoi = useLamMoiNcc();
  return useMutation({
    mutationFn: ({ id, banned, reason }: { id: string; banned: boolean; reason: string }) =>
      sittersApi.banSitter(id, banned, reason),
    onSuccess: lamMoi,
  });
}
