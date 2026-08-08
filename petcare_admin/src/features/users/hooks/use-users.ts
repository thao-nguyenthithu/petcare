import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { usersApi } from '@/features/users/api/users-api';
import type { UserListQuery } from '@/features/users/types';

const USERS_KEY = ['admin', 'users'] as const;

export function useUsers(query: UserListQuery) {
  return useQuery({
    queryKey: [...USERS_KEY, 'list', query],
    queryFn: () => usersApi.getUsers(query),
    placeholderData: keepPreviousData,
  });
}

export function useUserTabCounts() {
  return useQuery({
    queryKey: [...USERS_KEY, 'counts'],
    queryFn: usersApi.getTabCounts,
  });
}

export function useProvinces() {
  return useQuery({
    queryKey: [...USERS_KEY, 'provinces'],
    queryFn: usersApi.getProvinces,
    staleTime: Infinity,
  });
}

export function useUserDetail(id: string, enabled = true) {
  return useQuery({
    queryKey: [...USERS_KEY, 'detail', id],
    queryFn: () => usersApi.getUser(id),
    enabled: enabled && Boolean(id),
  });
}

export function useUserPets(userId: string) {
  return useQuery({
    queryKey: [...USERS_KEY, 'pets', userId],
    queryFn: () => usersApi.getPets(userId),
  });
}

export function usePetPreventions(petId: string | null) {
  return useQuery({
    queryKey: [...USERS_KEY, 'preventions', petId],
    queryFn: () => usersApi.getPreventions(petId ?? ''),
    enabled: Boolean(petId),
  });
}

export function useSetUserActive() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, isActive, reason }: { id: string; isActive: boolean; reason: string }) =>
      usersApi.setUserActive(id, isActive, reason),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: USERS_KEY });
    },
  });
}

export function useSetPetActive() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, isActive, reason }: { id: string; isActive: boolean; reason: string }) =>
      usersApi.setPetActive(id, isActive, reason),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: USERS_KEY });
    },
  });
}
