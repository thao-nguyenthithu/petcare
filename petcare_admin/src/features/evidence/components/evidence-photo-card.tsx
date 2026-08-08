import { useTranslation } from 'react-i18next';
import { AlertTriangle, Check, Clock, Package } from 'lucide-react';
import { Badge, type BadgeTone } from '@/components/ui/badge';
import { nhanNguon } from '@/features/evidence/evidence-labels';
import type { EvidencePhoto, SessionPhase } from '@/features/evidence/types';
import { formatDate } from '@/lib/format';
import { cn } from '@/lib/utils';

const KIEU_PHA: Record<SessionPhase, { tone: BadgeTone; icon: typeof Check }> = {
  CHECK_IN: { tone: 'pending', icon: Clock },
  IN_PROGRESS: { tone: 'success', icon: Check },
  CHECK_OUT: { tone: 'pending', icon: Clock },
};

export function PhaseBadge({ photo }: { photo: EvidencePhoto }) {
  const { t } = useTranslation();

  if (photo.source === 'noShow') {
    return (
      <Badge tone="danger" icon={AlertTriangle}>
        {t('anh.pha.suCo')}
      </Badge>
    );
  }
  if (photo.source === 'boarding') {
    return (
      <Badge tone="success" icon={Check}>
        {t('anh.pha.kyGiu')}
      </Badge>
    );
  }
  if (photo.anhDoDung) {
    return (
      <Badge tone="pending" icon={Package}>
        {t('anh.pha.doDung')}
      </Badge>
    );
  }

  const kieu = photo.phase ? KIEU_PHA[photo.phase] : undefined;
  if (!photo.phase || !kieu) return null;
  return (
    <Badge tone={kieu.tone} icon={kieu.icon}>
      {t(`anh.pha.${photo.phase}`)}
    </Badge>
  );
}

type EvidencePhotoCardProps = {
  photo: EvidencePhoto;
  dangChon: boolean;
  onChon: () => void;
};

export function EvidencePhotoCard({ photo, dangChon, onChon }: EvidencePhotoCardProps) {
  const { t } = useTranslation();

  return (
    <button type="button" onClick={onChon} className="flex flex-col text-left">
      <div
        className={cn(
          'relative flex h-[126px] items-center justify-center rounded-card border-2 bg-neutral-light/60',
          dangChon ? 'border-primary' : 'border-transparent',
        )}
      >
        <img
          src={photo.url}
          alt={photo.bookingCode}
          className="h-full w-full rounded-[12px] object-cover"
        />
        <span className="absolute right-label top-label">
          <PhaseBadge photo={photo} />
        </span>
      </div>

      <p className="mt-item truncate text-label">{photo.bookingCode}</p>
      <p className="truncate text-caption-sm text-text-secondary">
        {photo.serviceName} · {formatDate(photo.takenAt)}
      </p>
      <p className="mt-label truncate text-caption-sm text-accent">
        {nhanNguon(photo, t)}
      </p>
    </button>
  );
}
