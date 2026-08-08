import { useTranslation } from 'react-i18next';
import { Activity, Check, Clock, X } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import type { UserRole } from '@/features/users/types';

export function UserStatusBadge({
  isActive,
  isVerified,
}: {
  isActive: boolean;
  isVerified: boolean;
}) {
  const { t } = useTranslation();
  if (!isActive) {
    return (
      <Badge tone="danger" icon={X}>
        {t('nguoiDung.trangThai.biKhoa')}
      </Badge>
    );
  }
  if (!isVerified) {
    return (
      <Badge tone="pending" icon={Clock}>
        {t('nguoiDung.trangThai.choXacThuc')}
      </Badge>
    );
  }
  return (
    <Badge tone="success" icon={Check}>
      {t('nguoiDung.trangThai.hoatDong')}
    </Badge>
  );
}

export function UserRoleBadge({
  role,
  isSitter = false,
}: {
  role: UserRole;
  isSitter?: boolean;
}) {
  const { t } = useTranslation();
  if (role !== 'ADMIN' && (isSitter || role === 'PROVIDER')) {
    return (
      <Badge tone="success" icon={Check}>
        {t('nguoiDung.vaiTro.PROVIDER')}
      </Badge>
    );
  }
  if (role === 'ADMIN') {
    return <Badge tone="neutral">{t('nguoiDung.vaiTro.ADMIN')}</Badge>;
  }
  return (
    <Badge tone="info" icon={Activity}>
      {t('nguoiDung.vaiTro.OWNER')}
    </Badge>
  );
}

export function UserAvatar({
  name,
  url,
  size = 36,
}: {
  name: string;
  url?: string | null;
  size?: number;
}) {
  const chuCai = name.trim().charAt(0).toUpperCase();
  if (url) {
    return (
      <img
        src={url}
        alt={name}
        className="shrink-0 rounded-full object-cover"
        style={{ width: size, height: size }}
      />
    );
  }
  return (
    <span
      className="flex shrink-0 items-center justify-center rounded-full bg-card-mint text-label text-primary"
      style={{ width: size, height: size, fontSize: Math.round(size / 2.6) }}
    >
      {chuCai}
    </span>
  );
}
