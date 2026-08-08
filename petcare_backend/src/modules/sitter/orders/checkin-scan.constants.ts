export const CHECKIN_SCAN_QUEUE = 'checkin-scan';

export const VIEC_QUET_LO = 'quet-lo-check-in';

export type ViecQuetLo = { batchId: string; bookingId: string };

export function tenRoomDon(bookingId: string): string {
  return `booking:${bookingId}`;
}

export const SU_KIEN_QUET_XONG = 'checkin.scan.done';
