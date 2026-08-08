import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useParams } from 'react-router-dom';
import { ImageViewer } from '@/components/ui/image-viewer';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { PageHeader } from '@/components/ui/page-header';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { AlbumGrid } from '@/features/evidence/components/album-grid';
import { AlbumPhotoPanel } from '@/features/evidence/components/album-photo-panel';
import { useBookingEvidence } from '@/features/evidence/hooks/use-evidence';
import type { AlbumPhoto } from '@/features/evidence/types';
import { PATHS } from '@/routes/paths';

export function BookingAlbumScreen() {
  const { t } = useTranslation();
  const { code = '' } = useParams();
  const album = useBookingEvidence(code);
  const [maAnh, setMaAnh] = useState<string | null>(null);

  const tatCaAnh = useMemo<AlbumPhoto[]>(
    () => (album.data?.groups ?? []).flatMap((group) => group.photos),
    [album.data],
  );
  const chiSoDangXem = Math.max(
    0,
    tatCaAnh.findIndex((item) => item.id === maAnh),
  );
  const anhDangXem = tatCaAnh[chiSoDangXem] ?? null;

  const xem = useImageViewer();
  const anhBamDuoc: AnhXem[] = tatCaAnh.map((item) => ({ url: item.url, nhan: code }));

  const moAnhLon = (url: string | undefined) => {
    const viTri = anhBamDuoc.findIndex((item) => item.url === url);
    if (viTri >= 0) xem.mo(viTri);
  };

  const doiAnh = (buoc: number) => {
    if (tatCaAnh.length === 0) return;
    const tiep = (chiSoDangXem + buoc + tatCaAnh.length) % tatCaAnh.length;
    setMaAnh(tatCaAnh[tiep].id);
  };

  const doiChon = (id: string) => {
    setMaAnh(id);
    moAnhLon(tatCaAnh.find((item) => item.id === id)?.url);
  };

  if (album.isError) {
    return <ErrorState onRetry={() => void album.refetch()} />;
  }

  return (
    <div className="flex flex-col gap-stack pb-block">
      <PageHeader
        backTo={PATHS.evidence}
        crumbs={[{ label: t('man.anhBangChung.title'), to: PATHS.evidence }, { label: code }]}
      />

      {album.isPending || !album.data ? (
        <div className="grid grid-cols-[1fr_368px] gap-stack">
          <Skeleton className="h-[620px] w-full rounded-card" />
          <Skeleton className="h-[620px] w-full rounded-card" />
        </div>
      ) : (
        <div className="grid grid-cols-[1fr_368px] items-start gap-stack">
          <AlbumGrid data={album.data} maAnh={anhDangXem?.id ?? null} onChon={doiChon} />
          <AlbumPhotoPanel
            photo={anhDangXem}
            code={code}
            chiSo={chiSoDangXem}
            tong={tatCaAnh.length}
            onTruoc={() => doiAnh(-1)}
            onSau={() => doiAnh(1)}
            onXem={() => moAnhLon(anhDangXem?.url)}
          />
        </div>
      )}

      <ImageViewer anh={anhBamDuoc} moTai={xem.moTai} onDong={xem.dong} />
    </div>
  );
}
