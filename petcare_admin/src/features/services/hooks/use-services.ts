import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { servicesApi } from '@/features/services/api/services-api';
import type {
  ServiceUpdateInput,
  SetSitterServiceEnabledInput,
  SitterServiceQuery,
} from '@/features/services/types';
import type { ServiceType } from '@/features/dashboard/chart-colors';

const SERVICES_KEY = ['admin', 'services'] as const;

export function useServices() {
  return useQuery({
    queryKey: [...SERVICES_KEY, 'catalog'],
    queryFn: servicesApi.getServices,
  });
}

export function useSitterServices(query: SitterServiceQuery) {
  return useQuery({
    queryKey: [...SERVICES_KEY, 'sitter-services', query],
    queryFn: () => servicesApi.getSitterServices(query),
    placeholderData: keepPreviousData,
  });
}

export function useServiceConstraints() {
  return useQuery({
    queryKey: [...SERVICES_KEY, 'constraints'],
    queryFn: servicesApi.getConstraints,
    staleTime: Infinity,
  });
}

export function useUpdateService() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ type, input }: { type: ServiceType; input: ServiceUpdateInput }) =>
      servicesApi.updateService(type, input),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: SERVICES_KEY });
    },
  });
}

export function useSetSitterServiceEnabled() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: SetSitterServiceEnabledInput) =>
      servicesApi.setSitterServiceEnabled(input),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: SERVICES_KEY });
    },
  });
}
