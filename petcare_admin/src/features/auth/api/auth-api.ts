import { apiClient } from '@/lib/api/client';

export type UserRole = 'OWNER' | 'PROVIDER' | 'ADMIN';

export type LoginResponse = {
  accessToken: string;
  user: { id: string; email: string; role: UserRole };
};

export type CurrentUser = {
  id: string;
  fullName: string;
  email: string;
  phone: string | null;
  role: UserRole;
  avatarUrl: string | null;
  isVerified: boolean;
  createdAt: string;
};

export const authApi = {
  async login(email: string, password: string): Promise<LoginResponse> {
    const { data } = await apiClient.post<LoginResponse>('/auth/login', { email, password });
    return data;
  },

  async getMe(): Promise<CurrentUser> {
    const { data } = await apiClient.get<CurrentUser>('/auth/me');
    return data;
  },

  async forgotPassword(email: string): Promise<void> {
    await apiClient.post('/auth/forgot-password', { email, scope: 'admin' });
  },

  async verifyResetOtp(email: string, otp: string): Promise<string> {
    const { data } = await apiClient.post<{ resetToken: string }>('/auth/verify-reset-otp', {
      email,
      otp,
      scope: 'admin',
    });
    return data.resetToken;
  },

  async resetPassword(resetToken: string, newPassword: string): Promise<void> {
    await apiClient.post('/auth/reset-password', { resetToken, newPassword });
  },
};
