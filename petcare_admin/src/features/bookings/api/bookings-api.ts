import type {
  BookingConversation,
  BookingDetail,
  BookingListQuery,
  BookingListResponse,
  BookingStatus,
  BookingTabKey,
  GpsReportListQuery,
  GpsReportListResponse,
  GpsReviewResult,
  GpsTabCounts,
} from '@/features/bookings/types';
import { apiClient } from '@/lib/api/client';

export const bookingsApi = {
  async getBookings(query: BookingListQuery): Promise<BookingListResponse> {
    const { data } = await apiClient.get<BookingListResponse>('/admin/bookings', {
      params: query,
    });
    return data;
  },

  async getTabCounts(): Promise<Record<BookingTabKey, number>> {
    const { data } = await apiClient.get<Record<BookingTabKey, number>>(
      '/admin/bookings/counts',
    );
    return data;
  },

  async getBooking(code: string): Promise<BookingDetail> {
    const { data } = await apiClient.get<BookingDetail>(
      `/admin/bookings/${encodeURIComponent(code)}`,
    );
    return data;
  },

  async getConversation(code: string): Promise<BookingConversation> {
    const { data } = await apiClient.get<BookingConversation>(
      `/admin/bookings/${encodeURIComponent(code)}/conversation`,
    );
    return data;
  },

  async taiTrackCsv(code: string): Promise<Blob> {
    const { data } = await apiClient.get<Blob>(
      `/admin/bookings/${encodeURIComponent(code)}/track.csv`,
      { responseType: 'blob' },
    );
    return data;
  },

  async canThiepHuy(
    code: string,
    reason: string,
  ): Promise<{ code: string; status: BookingStatus }> {
    const { data } = await apiClient.post<{ code: string; status: BookingStatus }>(
      `/admin/bookings/${encodeURIComponent(code)}/cancel`,
      { reason },
    );
    return data;
  },

  async getGpsReports(query: GpsReportListQuery): Promise<GpsReportListResponse> {
    const { data } = await apiClient.get<GpsReportListResponse>('/admin/gps-reports', {
      params: query,
    });
    return data;
  },

  async getGpsTabCounts(): Promise<GpsTabCounts> {
    const { data } = await apiClient.get<GpsTabCounts>('/admin/gps-reports/counts');
    return data;
  },

  async reviewGpsReport(
    bookingCode: string,
    cleared: boolean,
    note: string,
  ): Promise<GpsReviewResult> {
    const { data } = await apiClient.patch<GpsReviewResult>(
      `/admin/gps-reports/${encodeURIComponent(bookingCode)}/review`,
      { cleared, note },
    );
    return data;
  },
};
