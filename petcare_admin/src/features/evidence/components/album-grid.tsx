import { useTranslation } from 'react-i18next';
import type { TFunction } from 'i18next';
import { SectionCard } from '@/components/ui/section-card';
import { nhanNhom, nhanTinhTrang } from '@/features/evidence/evidence-labels';
import type {
  AlbumStats,
  BookingEvidence,
  EvidenceGroup,
  ReportKind,
} from '@/features/evidence/types';
import { formatDate, formatTime } from '@/lib/format';
import { cn } from '@/lib/utils';

type OSo = { label: string; value: string; tone?: 'accent' };

function dungOSo(stats: AlbumStats, t: TFunction): OSo[] {
  const o: OSo[] = [
    { label: t('anh.album.tongSoAnh'), value: t('anh.album.soAnh', { count: stats.total }) },
  ];
  if (stats.dayCount !== null) {
    o.push({
      label: t('anh.album.soNgayCoBan'),
      value: t('anh.album.soNgay', { count: stats.dayCount }),
    });
  }
  if (stats.conditionCount !== null) {
    o.push({
      label: t('anh.album.nhanTinhTrang'),
      value: t('anh.album.soNhan', { count: stats.conditionCount }),
    });
  }
  if (stats.missingDayCount !== null) {
    o.push({
      label: t('anh.album.ngayThieuAnh'),
      value: t('anh.album.soNgay', { count: stats.missingDayCount }),
      tone: stats.missingDayCount > 0 ? 'accent' : undefined,
    });
  }
  if (stats.messageCount !== null) {
    o.push({
      label: t('anh.album.ghiChuNcc'),
      value: t('anh.album.soLoiNhan', { count: stats.messageCount }),
    });
  }
  return o;
}

type AlbumGridProps = {
  data: BookingEvidence;
  maAnh: string | null;
  onChon: (id: string) => void;
};

export function AlbumGrid({ data, maAnh, onChon }: AlbumGridProps) {
  const { t } = useTranslation();
  const laTrongGiu = data.booking.serviceType === 'BOARDING';
  const oSo = dungOSo(data.stats, t);

  return (
    <SectionCard
      title={t('anh.album.tieuDe')}
      subtitle={laTrongGiu ? t('anh.album.moTaTrongGiu') : t('anh.album.moTaPhien')}
    >
      <div className="flex flex-col gap-block">
        {data.groups.map((group) => (
          <NhomAnhKhoi
            key={group.key}
            group={group}
            reportKind={data.booking.reportKind}
            maAnh={maAnh}
            onChon={onChon}
          />
        ))}
      </div>

      <div className="mt-block grid grid-cols-5 gap-item border-t border-neutral-light pt-stack">
        {oSo.map((item) => (
          <div key={item.label}>
            <p className="text-label-sm uppercase text-text-secondary">{item.label}</p>
            <p
              className={cn(
                'mt-text text-h3',
                item.tone === 'accent' ? 'text-accent' : 'text-text-primary',
              )}
            >
              {item.value}
            </p>
          </div>
        ))}
      </div>
    </SectionCard>
  );
}

function NhomAnhKhoi({
  group,
  reportKind,
  maAnh,
  onChon,
}: {
  group: EvidenceGroup;
  reportKind: ReportKind | null;
  maAnh: string | null;
  onChon: (id: string) => void;
}) {
  const { t } = useTranslation();

  return (
    <div>
      <div className="flex items-baseline gap-label">
        <p className="text-label">
          {nhanNhom(group, t, reportKind)}
          {group.dayIndex !== null && group.date ? ` · ${formatDate(group.date)}` : ''}
        </p>
        <span className="text-caption-sm text-text-secondary">
          {t('anh.album.soAnh', { count: group.photoCount })}
        </span>
      </div>

      {group.conditions.length > 0 ? (
        <div className="mt-label flex flex-wrap items-center gap-label">
          {group.conditions.map((item) => (
            <span
              key={item}
              className="rounded-card bg-card-mint px-label py-text text-caption-sm text-primary"
            >
              {nhanTinhTrang(item, t)}
            </span>
          ))}
        </div>
      ) : null}

      {group.message ? (
        <p className="mt-label text-caption-sm text-text-secondary">{group.message}</p>
      ) : null}

      {group.photos.length === 0 ? (
        <p className="mt-item rounded-card bg-neutral-light/50 p-item text-caption-sm text-text-secondary">
          {t('anh.album.nhomChuaCoAnh')}
        </p>
      ) : (
        <div className="mt-item grid grid-cols-5 gap-item">
          {group.photos.map((photo) => (
            <button
              key={photo.id}
              type="button"
              onClick={() => onChon(photo.id)}
              className="flex flex-col text-left"
            >
              <span
                className={cn(
                  'flex h-[94px] items-center justify-center rounded-card border-2 bg-neutral-light/60',
                  photo.id === maAnh ? 'border-primary' : 'border-transparent',
                )}
              >
                <img
                  src={photo.url}
                  alt={t('anh.album.tieuDe')}
                  className="h-full w-full rounded-[12px] object-cover"
                />
              </span>
              <span className="mt-label text-caption-sm text-text-secondary">
                {formatTime(photo.takenAt)}
              </span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
