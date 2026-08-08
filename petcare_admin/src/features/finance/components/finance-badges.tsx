import { useTranslation } from 'react-i18next';
import { Activity, Check, Clock, Minus, X } from 'lucide-react';
import { Badge, type BadgeTone } from '@/components/ui/badge';
import type {
  PaymentGateway,
  PaymentStatus,
  RefundStatus,
  WithdrawalStatus,
} from '@/features/finance/types';
import type { LucideIcon } from 'lucide-react';

type KieuBadge = { tone: BadgeTone; icon: LucideIcon };

const KIEU_GIAO_DICH: Record<PaymentStatus, KieuBadge> = {
  PENDING: { tone: 'pending', icon: Clock },
  HELD: { tone: 'info', icon: Activity },
  RELEASED: { tone: 'success', icon: Check },
  REFUNDING: { tone: 'pending', icon: Clock },
  REFUNDED: { tone: 'success', icon: Check },
  FAILED: { tone: 'danger', icon: X },
  EXPIRED: { tone: 'neutral', icon: Minus },
};

export function PaymentStatusBadge({ status }: { status: PaymentStatus }) {
  const { t } = useTranslation();
  const kieu = KIEU_GIAO_DICH[status];
  return (
    <Badge tone={kieu.tone} icon={kieu.icon}>
      {t(`thanhToan.trangThai.${status}`)}
    </Badge>
  );
}

const KIEU_LENH_RUT: Record<WithdrawalStatus, KieuBadge> = {
  PENDING: { tone: 'pending', icon: Clock },
  SENT: { tone: 'info', icon: Check },
  DONE: { tone: 'success', icon: Check },
  REJECTED: { tone: 'danger', icon: X },
};

export function WithdrawalStatusBadge({ status }: { status: WithdrawalStatus }) {
  const { t } = useTranslation();
  const kieu = KIEU_LENH_RUT[status];
  return (
    <Badge tone={kieu.tone} icon={kieu.icon}>
      {t(`taiChinh.trangThaiRut.${status}`)}
    </Badge>
  );
}

const KIEU_HOAN_TIEN: Record<RefundStatus, KieuBadge> = {
  REFUNDING: { tone: 'info', icon: Activity },
  REFUNDED: { tone: 'success', icon: Check },
};

export function RefundStatusBadge({ status }: { status: RefundStatus }) {
  const { t } = useTranslation();
  const kieu = KIEU_HOAN_TIEN[status];
  return (
    <Badge tone={kieu.tone} icon={kieu.icon}>
      {t(`hoanTien.trangThai.${status}`)}
    </Badge>
  );
}

export function GatewayBadge({ gateway }: { gateway: PaymentGateway }) {
  const { t } = useTranslation();
  if (gateway === 'vnpay') return null;
  return <Badge tone="neutral">{t(`thanhToan.cong.${gateway}`)}</Badge>;
}
