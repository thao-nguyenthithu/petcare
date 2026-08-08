
const VN_TIME_ZONE = 'Asia/Ho_Chi_Minh';

export function formatMoney(value: number): string {
  return `${new Intl.NumberFormat('vi-VN').format(Math.round(value))} đ`;
}

export function formatNumber(value: number): string {
  return new Intl.NumberFormat('vi-VN').format(value);
}

export function formatPercent(value: number, fractionDigits = 1): string {
  return `${new Intl.NumberFormat('vi-VN', {
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
  }).format(value)}%`;
}

// Ngày dd/MM/yyyy theo giờ Việt Nam
export function formatDate(value: string | Date | number): string {
  return new Intl.DateTimeFormat('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    timeZone: VN_TIME_ZONE,
  }).format(new Date(value));
}

// Giờ HH:mm theo giờ Việt Nam
export function formatTime(value: string | Date | number): string {
  return new Intl.DateTimeFormat('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
    timeZone: VN_TIME_ZONE,
  }).format(new Date(value));
}

// Ngày kèm giờ dd/MM/yyyy · HH:mm
export function formatDateTime(value: string | Date): string {
  const date = new Date(value);
  const time = new Intl.DateTimeFormat('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
    timeZone: VN_TIME_ZONE,
  }).format(date);
  return `${formatDate(date)} · ${time}`;
}

export function formatRelative(value: string | Date, now: Date = new Date()): string {
  const diffMs = new Date(value).getTime() - now.getTime();
  const units: Array<[Intl.RelativeTimeFormatUnit, number]> = [
    ['year', 365 * 24 * 3600_000],
    ['month', 30 * 24 * 3600_000],
    ['day', 24 * 3600_000],
    ['hour', 3600_000],
    ['minute', 60_000],
  ];
  const rtf = new Intl.RelativeTimeFormat('vi-VN', { numeric: 'auto' });
  for (const [unit, ms] of units) {
    if (Math.abs(diffMs) >= ms) {
      return rtf.format(Math.round(diffMs / ms), unit);
    }
  }
  return 'vừa xong';
}
