import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { QUEUE_KEY } from '@/features/dashboard/hooks/use-dashboard';
import { penaltiesApi } from '@/features/penalties/api/penalties-api';
import type { PenaltyListQuery } from '@/features/penalties/types';

const PENALTIES_KEY = ['admin', 'penalties'] as const;

export function usePenalties(query: PenaltyListQuery) {
  return useQuery({
    queryKey: [...PENALTIES_KEY, 'list', query],
    queryFn: () => penaltiesApi.getPenalties(query),
    placeholderData: keepPreviousData,
  });
}

export function usePenaltyTabCounts() {
  return useQuery({
    queryKey: [...PENALTIES_KEY, 'counts'],
    queryFn: penaltiesApi.getTabCounts,
  });
}

export function useReviewPenalty() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, waived, note }: { id: string; waived: boolean; note: string }) =>
      penaltiesApi.reviewPenalty(id, waived, note),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: PENALTIES_KEY });
      void queryClient.invalidateQueries({ queryKey: ['admin', 'sitters'] });
      void queryClient.invalidateQueries({ queryKey: QUEUE_KEY });
    },
  });
}
