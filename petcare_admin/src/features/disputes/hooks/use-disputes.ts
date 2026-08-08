import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { disputesApi } from '@/features/disputes/api/disputes-api';
import { KHOA_HAN_KET_LUAN } from '@/features/disputes/dispute-constants';
import type { DisputeListQuery, ResolveDisputeInput } from '@/features/disputes/types';
import { useOperatingSettings } from '@/features/settings/hooks/use-settings';

const DISPUTES_KEY = ['admin', 'disputes'] as const;

export function useHanKetLuanNgay(): number | null {
  const thamSo = useOperatingSettings();
  const dong = thamSo.data?.items.find((item) => item.key === KHOA_HAN_KET_LUAN);
  return typeof dong?.giaTri === 'number' ? dong.giaTri : null;
}

export function useDisputes(query: DisputeListQuery) {
  return useQuery({
    queryKey: [...DISPUTES_KEY, 'list', query],
    queryFn: () => disputesApi.getDisputes(query),
    placeholderData: keepPreviousData,
  });
}

export function useDisputeTabCounts() {
  return useQuery({
    queryKey: [...DISPUTES_KEY, 'counts'],
    queryFn: disputesApi.getTabCounts,
  });
}

export function useDisputeDetail(code: string) {
  return useQuery({
    queryKey: [...DISPUTES_KEY, 'detail', code],
    queryFn: () => disputesApi.getDispute(code),
    enabled: Boolean(code),
  });
}

export function useResolveDispute() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: ResolveDisputeInput) => disputesApi.resolveDispute(input),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: DISPUTES_KEY });
    },
  });
}
