import { useTranslation } from 'react-i18next';
import { ChevronLeft, ChevronRight, Clock, MapPin } from 'lucide-react';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { SectionCard } from '@/components/ui/section-card';
import { EmptyState } from '@/components/state/empty-state';
import { AiScorePanel } from '@/features/evidence/components/ai-score-panel';
import type { AlbumPhoto } from '@/features/evidence/types';
import { formatDateTime } from '@/lib/format';

type AlbumPhotoPanelProps = {
  photo: AlbumPhoto | null;
  code: string;
  chiSo: number;
  tong: number;
  onTruoc: () => void;
  onSau: () => void;
  onXem: () => void;
};

export function AlbumPhotoPanel({
  photo,
  code,
  chiSo,
  tong,
  onTruoc,
  onSau,
  onXem,
}: AlbumPhotoPanelProps) {
  const { t } = useTranslation();

  if (!photo) {
    return (
      <SectionCard title={t('anh.dangXem.tieuDe')}>
        <EmptyState message={t('anh.dangXem.chuaChon')} />
      </SectionCard>
    );
  }

  const coToaDo = photo.photoLat !== null && photo.photoLng !== null;
  const lech =
    photo.distanceFromMeetingM === null
      ? ''
      : ` · ${t('anh.lechMet', { value: photo.distanceFromMeetingM })}`;

  return (
    <SectionCard title={t('anh.dangXem.tieuDe')} subtitle={formatDateTime(photo.takenAt)}>
      <div className="flex h-[210px] items-center justify-center rounded-card bg-neutral-light/60">
        <button
          type="button"
          aria-label={t('xemAnh.moAnh')}
          onClick={onXem}
          className="h-full w-full"
        >
          <img
            src={photo.url}
            alt={code}
            className="h-full w-full rounded-card object-cover"
          />
        </button>
      </div>

      <div className="mt-stack flex items-center justify-between gap-item">
        <NutLuot nhan={t('chung.trangTruoc')} onBam={onTruoc}>
          <ChevronLeft className="h-4 w-4" strokeWidth={1.8} />
        </NutLuot>
        <span className="text-label">{t('anh.viTriAnh', { index: chiSo + 1, total: tong })}</span>
        <NutLuot nhan={t('chung.trangSau')} onBam={onSau}>
          <ChevronRight className="h-4 w-4" strokeWidth={1.8} />
        </NutLuot>
      </div>

      <ul className="mt-stack flex flex-col gap-label">
        <Dong icon={Clock} label={t('anh.thoiDiemChup')} value={formatDateTime(photo.takenAt)} />
        <Dong
          icon={MapPin}
          label={t('anh.toaDo')}
          value={coToaDo ? `${photo.photoLat}, ${photo.photoLng}${lech}` : t('anh.khongCoToaDo')}
        />
      </ul>

      <div className="mt-stack border-t border-neutral-light pt-stack">
        <AiScorePanel diem={photo} />
      </div>
    </SectionCard>
  );
}

function Dong({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof Clock;
  label: string;
  value: string | null;
}) {
  return (
    <li className="flex items-baseline justify-between gap-item">
      <span className="flex items-center gap-label text-label font-normal text-text-secondary">
        <Icon className="h-[15px] w-[15px] shrink-0" strokeWidth={1.8} />
        {label}
      </span>
      <span className="min-w-0 break-words text-right text-label">
        {value ?? <KhongCoDuLieu />}
      </span>
    </li>
  );
}

function NutLuot({
  nhan,
  onBam,
  children,
}: {
  nhan: string;
  onBam: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      type="button"
      aria-label={nhan}
      onClick={onBam}
      className="flex h-8 w-8 items-center justify-center rounded-card border border-neutral text-text-secondary hover:bg-card-mint"
    >
      {children}
    </button>
  );
}
