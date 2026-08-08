import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { bookingsApi } from '@/features/bookings/api/bookings-api';
import type { BookingListQuery, GpsReportListQuery } from '@/features/bookings/types';

const BOOKINGS_KEY = ['admin', 'bookings'] as const;
const GPS_KEY = ['admin', 'gps-reports'] as const;

export function useBookings(query: BookingListQuery) {
  return useQuery({
    queryKey: [...BOOKINGS_KEY, 'list', query],
    queryFn: () => bookingsApi.getBookings(query),
    placeholderData: keepPreviousData,
  });
}

export function useBookingTabCounts() {
  return useQuery({
    queryKey: [...BOOKINGS_KEY, 'counts'],
    queryFn: bookingsApi.getTabCounts,
  });
}

export function useBookingDetail(code: string) {
  return useQuery({
    queryKey: [...BOOKINGS_KEY, 'detail', code],
    queryFn: () => bookingsApi.getBooking(code),
    enabled: Boolean(code),
  });
}

export function useBookingConversation(code: string) {
  return useQuery({
    queryKey: [...BOOKINGS_KEY, 'conversation', code],
    queryFn: () => bookingsApi.getConversation(code),
    enabled: Boolean(code),
  });
}

export function useCanThiepHuy(code: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (reason: string) => bookingsApi.canThiepHuy(code, reason),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: BOOKINGS_KEY });
    },
  });
}

export function useTaiTrackCsv(code: string) {
  return useMutation({
    mutationFn: () => bookingsApi.taiTrackCsv(code),
    onSuccess: (blob) => taiVe(blob, `loc-trinh-${code}.csv`),
  });
}

function taiVe(blob: Blob, ten: string) {
  const url = URL.createObjectURL(blob);
  const the = document.createElement('a');
  the.href = url;
  the.download = ten;
  the.click();
  URL.revokeObjectURL(url);
}

export function useGpsReports(query: GpsReportListQuery) {
  return useQuery({
    queryKey: [...GPS_KEY, 'list', query],
    queryFn: () => bookingsApi.getGpsReports(query),
    placeholderData: keepPreviousData,
  });
}

export function useGpsTabCounts() {
  return useQuery({
    queryKey: [...GPS_KEY, 'counts'],
    queryFn: bookingsApi.getGpsTabCounts,
  });
}

export function useReviewGpsReport() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      bookingCode,
      cleared,
      note,
    }: {
      bookingCode: string;
      cleared: boolean;
      note: string;
    }) => bookingsApi.reviewGpsReport(bookingCode, cleared, note),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: GPS_KEY });
    },
  });
}
