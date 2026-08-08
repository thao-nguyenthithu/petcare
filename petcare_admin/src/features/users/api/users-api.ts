import { apiClient } from '@/lib/api/client';
import type {
  PetDetail,
  PetPreventionResponse,
  UserDetail,
  UserListQuery,
  UserListResponse,
  UserTabCounts,
} from '@/features/users/types';

export const usersApi = {
  async getUsers(query: UserListQuery): Promise<UserListResponse> {
    const { data } = await apiClient.get<UserListResponse>('/admin/users', {
      params: query,
    });
    return data;
  },

  async getTabCounts(): Promise<UserTabCounts> {
    const { data } = await apiClient.get<UserTabCounts>('/admin/users/counts');
    return data;
  },

  async getProvinces(): Promise<string[]> {
    const { data } = await apiClient.get<string[]>('/admin/provinces');
    return data;
  },

  async getUser(id: string): Promise<UserDetail> {
    const { data } = await apiClient.get<UserDetail>(`/admin/users/${id}`);
    return data;
  },

  async setUserActive(id: string, isActive: boolean, reason: string) {
    const { data } = await apiClient.patch<{ id: string; isActive: boolean }>(
      `/admin/users/${id}/active`,
      { isActive, reason },
    );
    return data;
  },

  async getPets(userId: string): Promise<{ items: PetDetail[] }> {
    const { data } = await apiClient.get<{ items: PetDetail[] }>(
      `/admin/users/${userId}/pets`,
    );
    return data;
  },

  async getPreventions(petId: string): Promise<PetPreventionResponse> {
    const { data } = await apiClient.get<PetPreventionResponse>(
      `/admin/pets/${petId}/preventions`,
    );
    return data;
  },

  async setPetActive(id: string, isActive: boolean, reason: string) {
    const { data } = await apiClient.patch<{ id: string; isActive: boolean }>(
      `/admin/pets/${id}/active`,
      { isActive, reason },
    );
    return data;
  },
};
