import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { CountTabs, type CountTab } from '@/components/ui/count-tabs';
import { ImageViewer } from '@/components/ui/image-viewer';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { Pagination } from '@/components/ui/pagination';
import { SectionCard } from '@/components/ui/section-card';
import { EmptyState } from '@/components/state/empty-state';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { AiScorePanel } from '@/features/evidence/components/ai-score-panel';
import { EvidencePhotoCard } from '@/features/evidence/components/evidence-photo-card';
import { nhanNguon, nhanTinhTrang } from '@/features/evidence/evidence-labels';
import { useEvidence, useEvidenceSourceCounts } from '@/features/evidence/hooks/use-evidence';
import type {
  EvidencePhoto,
  EvidenceQuery,
  EvidenceSource,
  EvidenceTabKey,
} from '@/features/evidence/types';
import { formatDateTime } from '@/lib/format';
import { PATHS } from '@/routes/paths';

const LIMIT = 9;

export function EvidenceScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [tab, setTab] = useState<EvidenceSource>('session');
  const [page, setPage] = useState(1);
  const [maAnhDangXem, setMaAnhDangXem] = useState<string | null>(null);

  const counts = useEvidenceSourceCounts();

  const query = useMemo<EvidenceQuery>(
    () => ({ source: tab, page, limit: LIMIT }),
    [tab, page],
  );
  const danhSach = useEvidence(query);

  const items = danhSach.data?.items ?? [];
  const anhDangXem: EvidencePhoto | null =
    items.find((item) => item.id === maAnhDangXem) ?? items[0] ?? null;

  const xem = useImageViewer();
  const anhBamDuoc: AnhXem[] = items.map((item) => ({
    url: item.url,
    nhan: item.bookingCode,
  }));
  const moAnhLon = (url: string | undefined) => {
    const viTri = anhBamDuoc.findIndex((a) => a.url === url);
    if (viTri >= 0) xem.mo(viTri);
  };

  const tabs: Array<CountTab<EvidenceTabKey>> = [
    { key: 'session', label: t('anh.tab.session'), count: counts.data?.session },
    { key: 'boarding', label: t('anh.tab.boarding'), count: counts.data?.boarding },
    { key: 'noShow', label: t('anh.tab.noShow'), count: counts.data?.noShow },
    { key: 'gpsFlagged', label: t('anh.tab.gpsFlagged'), count: counts.data?.gpsFlagged },
  ];

  const doiTab = (key: EvidenceTabKey) => {
    if (key === 'gpsFlagged') {
      void navigate(PATHS.gpsFlagged);
      return;
    }
    setTab(key);
    setPage(1);
  };

  return (
    <div className="flex flex-col gap-stack pb-block">
      <CountTabs
        tabs={tabs}
        value={tab}
        onChange={doiTab}
        className="rounded-card bg-neutral-light/50 p-text"
      />

      <div className="grid grid-cols-[1fr_392px] items-start gap-stack">
        <SectionCard title={t('anh.thuVien.tieuDe')} subtitle={t('anh.thuVien.moTa')}>
          {danhSach.isError ? (
            <ErrorState onRetry={() => void danhSach.refetch()} />
          ) : danhSach.isPending ? (
            <div className="grid grid-cols-3 gap-stack">
              {Array.from({ length: LIMIT }).map((_, index) => (
                <Skeleton key={index} className="h-[196px] w-full rounded-card" />
              ))}
            </div>
          ) : items.length === 0 ? (
            <EmptyState message={t('anh.chuaCoAnh')} />
          ) : (
            <>
              <div className="grid grid-cols-3 gap-stack">
                {items.map((photo) => (
                  <EvidencePhotoCard
                    key={photo.id}
                    photo={photo}
                    dangChon={photo.id === anhDangXem?.id}
                    onChon={() => {
                      setMaAnhDangXem(photo.id);
                      moAnhLon(photo.url);
                    }}
                  />
                ))}
              </div>
              <div className="mt-block border-t border-neutral-light pt-stack">
                <Pagination
                  page={page}
                  pageSize={LIMIT}
                  total={danhSach.data?.total ?? 0}
                  onPageChange={setPage}
                />
              </div>
            </>
          )}
        </SectionCard>

        <PanelAnhDangXem photo={anhDangXem} onXem={() => moAnhLon(anhDangXem?.url)} />
      </div>

      <ImageViewer anh={anhBamDuoc} moTai={xem.moTai} onDong={xem.dong} />
    </div>
  );
}

function PanelAnhDangXem({
  photo,
  onXem,
}: {
  photo: EvidencePhoto | null;
  onXem: () => void;
}) {
  const { t } = useTranslation();
  const navigate = useNavigate();

  if (!photo) {
    return (
      <SectionCard title={t('anh.dangXem.tieuDe')}>
        <EmptyState message={t('anh.dangXem.chuaChon')} />
      </SectionCard>
    );
  }

  return (
    <SectionCard
      title={t('anh.dangXem.tieuDe')}
      subtitle={`${photo.bookingCode} · ${nhanNguon(photo, t)}`}
    >
      <div className="flex h-[190px] items-center justify-center rounded-card bg-neutral-light/60">
        <button
          type="button"
          aria-label={t('xemAnh.moAnh')}
          onClick={onXem}
          className="h-full w-full"
        >
          <img
            src={photo.url}
            alt={photo.bookingCode}
            className="h-full w-full rounded-card object-cover"
          />
        </button>
      </div>

      <ul className="mt-stack flex flex-col gap-label">
        <li className="flex items-baseline justify-between gap-item">
          <span className="text-label font-normal text-text-secondary">
            {t('anh.thoiDiemChup')}
          </span>
          <span className="text-label">{formatDateTime(photo.takenAt)}</span>
        </li>
        <li className="flex items-baseline justify-between gap-item">
          <span className="text-label font-normal text-text-secondary">{t('anh.toaDo')}</span>
          <span className="text-label">
            {photo.photoLat === null || photo.photoLng === null
              ? // Ảnh thiếu toạ độ thì ghi rõ, KHÔNG đoán vị trí từ điểm hẹn
                t('anh.khongCoToaDo')
              : `${photo.photoLat}, ${photo.photoLng}`}
          </span>
        </li>
        {photo.conditions.length > 0 ? (
          <li className="flex flex-wrap items-center gap-label">
            {photo.conditions.map((item) => (
              <span
                key={item}
                className="rounded-card bg-card-mint px-label py-text text-caption-sm text-primary"
              >
                {nhanTinhTrang(item, t)}
              </span>
            ))}
          </li>
        ) : null}
      </ul>

      <div className="mt-stack border-t border-neutral-light pt-stack">
        <AiScorePanel diem={photo} />
      </div>

      <Button
        variant="secondary"
        className="mt-stack w-full"
        onClick={() => void navigate(`${PATHS.evidence}/${photo.bookingCode}`)}
      >
        {t('anh.xemAlbum')}
      </Button>
    </SectionCard>
  );
}
