import { useQuery, useQueryClient } from '@tanstack/react-query';
import { authApi, type CurrentUser } from '@/features/auth/api/auth-api';
import { tokenStorage } from '@/lib/api/token-storage';

export const CURRENT_USER_KEY = ['auth', 'me'] as const;

export function useCurrentAdmin() {
  return useQuery({
    queryKey: CURRENT_USER_KEY,
    queryFn: authApi.getMe,
    enabled: Boolean(tokenStorage.get()),
    retry: false,
    staleTime: 5 * 60_000,
  });
}

export function useSetCurrentAdmin() {
  const queryClient = useQueryClient();
  return (user: CurrentUser) => queryClient.setQueryData(CURRENT_USER_KEY, user);
}
