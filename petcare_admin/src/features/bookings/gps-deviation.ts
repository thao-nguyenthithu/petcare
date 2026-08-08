import { NGUONG_LECH_KM, NGUONG_LECH_TY_LE } from '@/features/bookings/booking-constants';
import type { GpsDeviationLabel, GpsReportRow } from '@/features/bookings/types';

export function tinhNhanDoLech(row: GpsReportRow): GpsDeviationLabel {
  if (row.durationMinutes > 0 && row.totalWaypoints === 0) return 'trackingOff';

  if (row.claimedDistanceKm === null) return 'noClaim';

  const serverKm = row.totalDistanceM / 1000;
  const lech = Math.abs(row.claimedDistanceKm - serverKm);
  const vuotTuyetDoi = lech >= NGUONG_LECH_KM;
  const vuotTyLe = serverKm > 0 && lech / serverKm > NGUONG_LECH_TY_LE;

  if (vuotTuyetDoi && vuotTyLe) return 'twoThresholds';
  if (vuotTuyetDoi || vuotTyLe) return 'ratioOnly';
  return 'withinError';
}
