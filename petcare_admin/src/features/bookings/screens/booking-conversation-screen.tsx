import { useTranslation } from 'react-i18next';
import { useParams } from 'react-router-dom';
import { Images, Info, ShieldAlert } from 'lucide-react';
import { ErrorState } from '@/components/state/error-state';
import { EmptyState } from '@/components/state/empty-state';
import { Skeleton } from '@/components/state/skeleton';
import { PageHeader } from '@/components/ui/page-header';
import { SectionCard } from '@/components/ui/section-card';
import { useBookingConversation } from '@/features/bookings/hooks/use-bookings';
import type { BookingConversation, BookingConversationEntry } from '@/features/bookings/types';
import { formatDateTime } from '@/lib/format';
import { cn } from '@/lib/utils';
import { PATHS } from '@/routes/paths';

export function BookingConversationScreen() {
  const { t } = useTranslation();
  const { code = '' } = useParams();
  const hoiThoai = useBookingConversation(code);

  if (hoiThoai.isError) {
    return <ErrorState onRetry={() => void hoiThoai.refetch()} />;
  }

  const data = hoiThoai.data;

  return (
    <div className="flex flex-col gap-stack pb-block">
      <PageHeader
        backTo={`${PATHS.bookings}/${code}`}
        crumbs={[
          { label: t('man.donDatLich.title'), to: PATHS.bookings },
          { label: code, to: `${PATHS.bookings}/${code}` },
          { label: t('don.hoiThoai.tieuDe') },
        ]}
      />

      {hoiThoai.isPending || !data ? (
        <Skeleton className="h-[560px] w-full rounded-card" />
      ) : (
        <SectionCard
          title={t('don.hoiThoai.tieuDe')}
          subtitle={[
            data.ownerName,
            data.sitterName,
            data.openedAt ? t('don.hoiThoai.moLuc', { value: formatDateTime(data.openedAt) }) : null,
          ]
            .filter(Boolean)
            .join(' · ')}
        >
          <p className="flex items-start gap-label rounded-card bg-card-mint p-item text-caption-sm text-text-secondary">
            <Info className="mt-text h-4 w-4 shrink-0 text-primary" strokeWidth={1.8} />
            {t('don.hoiThoai.chiDoc')}
          </p>

          {data.truncated ? (
            <p className="mt-item rounded-card bg-honey/15 p-item text-caption-sm text-honey">
              {t('don.hoiThoai.daCat')}
            </p>
          ) : null}

          {data.entries.length === 0 ? (
            <EmptyState message={t('don.hoiThoai.chuaCoTin')} />
          ) : (
            <ol className="mt-stack flex flex-col gap-item">
              {data.entries.map((entry) => (
                <DongTin key={entry.id} entry={entry} data={data} />
              ))}
            </ol>
          )}

          {data.closedAt ? (
            <p className="mt-stack text-center text-caption-sm text-text-secondary">
              {t('don.hoiThoai.daKhoa', { value: formatDateTime(data.closedAt) })}
            </p>
          ) : null}
        </SectionCard>
      )}
    </div>
  );
}

function DongTin({ entry, data }: { entry: BookingConversationEntry; data: BookingConversation }) {
  const { t } = useTranslation();

  if (entry.sender === 'SYSTEM') {
    return (
      <li className="px-block text-center text-caption-sm text-text-secondary">
        {entry.content} · {formatDateTime(entry.sentAt)}
      </li>
    );
  }

  const laChuNuoi = entry.sender === 'OWNER';
  const tenNguoiGui = laChuNuoi ? data.ownerName : data.sitterName;
  const noiDung =
    entry.content || (entry.kind === 'LOCATION' ? t('don.hoiThoai.viTri') : '');

  return (
    <li className={cn('flex', laChuNuoi ? 'justify-start' : 'justify-end')}>
      <div className="max-w-[520px] rounded-card border border-neutral-light p-item">
        <p className="text-caption-sm text-text-secondary">
          {tenNguoiGui} · {t(`nguoiDung.vaiTro.${laChuNuoi ? 'OWNER' : 'PROVIDER'}`)} ·{' '}
          {formatDateTime(entry.sentAt)}
        </p>
        <p className="mt-text text-label font-normal">{noiDung}</p>

        {entry.photoCount > 0 ? (
          <p className="mt-text flex items-center gap-label text-caption-sm text-text-secondary">
            <Images className="h-[14px] w-[14px]" strokeWidth={1.8} />
            {t('don.hoiThoai.soAnh', { count: entry.photoCount })}
          </p>
        ) : null}

        {entry.masked ? (
          <p className="mt-text flex items-center gap-label text-caption-sm text-honey">
            <ShieldAlert className="h-[14px] w-[14px]" strokeWidth={1.8} />
            {t('don.hoiThoai.daChe')}
          </p>
        ) : null}
      </div>
    </li>
  );
}
