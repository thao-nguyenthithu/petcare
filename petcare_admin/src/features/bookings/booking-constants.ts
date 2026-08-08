import {
  Activity,
  AlertTriangle,
  Ban,
  Check,
  Clock,
  Minus,
  PauseCircle,
  ShieldCheck,
  UserCheck,
  UserX,
  X,
  type LucideIcon,
} from 'lucide-react';
import type { BadgeTone } from '@/components/ui/badge';
import type { BookingStatus, BookingTabKey } from '@/features/bookings/types';

export const KIEU_TRANG_THAI: Record<BookingStatus, { tone: BadgeTone; icon: LucideIcon }> = {
  AWAITING_PAYMENT: { tone: 'pending', icon: Clock },
  PENDING: { tone: 'pending', icon: Clock },
  CONFIRMED: { tone: 'info', icon: UserCheck },
  PAUSED_WAITING_OWNER: { tone: 'neutral', icon: PauseCircle },
  IN_PROGRESS: { tone: 'info', icon: Activity },
  AWAITING_OWNER_CONFIRM: { tone: 'pending', icon: Clock },
  COMPLETED: { tone: 'success', icon: Check },
  CANCELLED_BY_OWNER: { tone: 'danger', icon: X },
  CANCELLED_BY_SITTER: { tone: 'danger', icon: X },
  CANCELLED_EXPIRED: { tone: 'danger', icon: X },
  CANCELLED_UNPAID: { tone: 'neutral', icon: Minus },
  CANCELLED_NO_SHOW: { tone: 'info', icon: UserX },
  CANCELLED_BY_ADMIN: { tone: 'danger', icon: Ban },
  DISPUTED: { tone: 'danger', icon: AlertTriangle },
  RESOLVED: { tone: 'success', icon: ShieldCheck },
};

export const THU_TU_TAB: BookingTabKey[] = [
  'all',
  'awaitingPayment',
  'pending',
  'confirmed',
  'running',
  'awaitingConfirm',
  'completed',
  'cancelled',
  'disputed',
];

export const TRANG_THAI_HUY_DUOC: BookingStatus[] = [
  'AWAITING_PAYMENT',
  'PENDING',
  'CONFIRMED',
];

export const GIO_MO_CHI_DUONG = 2;

export const NGUONG_LECH_KM = 0.3;
export const NGUONG_LECH_TY_LE = 0.2;
