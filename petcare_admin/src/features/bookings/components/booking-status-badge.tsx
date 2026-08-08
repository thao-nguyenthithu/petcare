import { useTranslation } from 'react-i18next';
import { Badge } from '@/components/ui/badge';
import { KIEU_TRANG_THAI } from '@/features/bookings/booking-constants';
import type { BookingStatus } from '@/features/bookings/types';

export function AdminBookingStatusBadge({ status }: { status: BookingStatus }) {
  const { t } = useTranslation();
  const kieu = KIEU_TRANG_THAI[status];
  return (
    <Badge tone={kieu.tone} icon={kieu.icon}>
      {t(`don.trangThai.${status}`)}
    </Badge>
  );
}
