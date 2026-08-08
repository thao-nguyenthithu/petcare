import axios, { AxiosError } from 'axios';
import { toast } from 'sonner';
import i18n from '@/core/i18n';
import { tokenStorage } from '@/lib/api/token-storage';
import { LOGIN_PATH } from '@/routes/paths';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 20000,
  headers: { 'Content-Type': 'application/json' },
});

// Gắn accessToken vào mọi lời gọi
apiClient.interceptors.request.use((config) => {
  const token = tokenStorage.get();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

const DUONG_DAN_BO_QUA_401 = ['/auth/login'];

apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    const url = error.config?.url ?? '';
    const laLoiHetPhien =
      error.response?.status === 401 &&
      !DUONG_DAN_BO_QUA_401.some((duongDan) => url.includes(duongDan)) &&
      !window.location.pathname.startsWith(LOGIN_PATH);

    if (laLoiHetPhien) {
      tokenStorage.clear();
      toast.error(i18n.t('chung.phienHetHan'));
      window.location.assign(LOGIN_PATH);
    }
    return Promise.reject(error);
  },
);

type LoiBackend = { code?: string; message?: string | string[] };

export function getErrorCode(error: unknown): string | null {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data as LoiBackend | undefined;
    return data?.code ?? null;
  }
  return null;
}

export function getErrorStatus(error: unknown): number | null {
  return axios.isAxiosError(error) ? (error.response?.status ?? null) : null;
}

export function getErrorMeta<T>(error: unknown): T | null {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data as { meta?: T } | undefined;
    return data?.meta ?? null;
  }
  return null;
}

export function isNetworkError(error: unknown): boolean {
  return axios.isAxiosError(error) && !error.response;
}

export function getErrorMessage(error: unknown, fallback = i18n.t('chung.coLoi')): string {
  if (axios.isAxiosError(error)) {
    if (!error.response) return i18n.t('chung.matMang');
    const data = error.response.data as LoiBackend | undefined;
    const theoMa = data?.code ? i18n.t(`loi.${data.code}`, { defaultValue: '' }) : '';
    if (theoMa) return theoMa;
    const message = data?.message;
    if (Array.isArray(message)) return message[0] ?? fallback;
    if (typeof message === 'string') return message;
  }
  return fallback;
}
