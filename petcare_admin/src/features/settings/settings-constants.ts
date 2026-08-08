export const KHOA_CAN_LY_DO = [
  'platform.fee.percent',
  'cancel.fee.percent',
  'escrow.hours',
  'penalty.warnings_to_hide',
  'penalty.window_days',
  'penalty.cancel_rate_max',
  'penalty.min_orders',
];

export function canLyDo(key: string): boolean {
  return KHOA_CAN_LY_DO.includes(key);
}

export const DAI_TOI_DA_LY_DO = 300;
