import { useTranslation } from 'react-i18next';
import { SectionCard } from '@/components/ui/section-card';
import { EmptyState } from '@/components/state/empty-state';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { AuditLogIcon } from '@/features/settings/components/audit-log-icon';
import { useAuditLogs } from '@/features/settings/hooks/use-settings';
import { formatDate, formatTime } from '@/lib/format';

const SO_DONG_TOM_TAT = 7;

export function AuditLogSummaryCard({ onXemTatCa }: { onXemTatCa: () => void }) {
  const { t } = useTranslation();
  const nhatKy = useAuditLogs({ page: 1, limit: SO_DONG_TOM_TAT });

  return (
    <SectionCard
      title={t('caiDat.nhatKy.tieuDe')}
      subtitle={t('caiDat.nhatKy.moTa')}
      action={
        <button type="button" onClick={onXemTatCa} className="text-label text-primary">
          {t('caiDat.nhatKy.xemTatCa')}
        </button>
      }
      bodyClassName="flex flex-col"
    >
      {nhatKy.isPending ? (
        <div className="flex flex-col gap-item">
          {Array.from({ length: SO_DONG_TOM_TAT }).map((_, index) => (
            <Skeleton key={index} className="h-[44px] w-full" />
          ))}
        </div>
      ) : null}
      {nhatKy.isError ? <ErrorState onRetry={() => void nhatKy.refetch()} /> : null}
      {!nhatKy.isPending && !nhatKy.isError && (nhatKy.data?.items ?? []).length === 0 ? (
        <EmptyState message={t('caiDat.nhatKy.chuaCo')} />
      ) : null}
      {(nhatKy.data?.items ?? []).map((row, index) => {
        const nhanHanhDong = t(`caiDat.hanhDong.${row.action}`, { defaultValue: row.action });
        return (
          <div
            key={row.id}
            className={
              index === 0
                ? 'flex items-start gap-item py-item pt-0'
                : 'flex items-start gap-item border-t border-neutral-light py-item'
            }
          >
            <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-card bg-card-mint text-primary">
              <AuditLogIcon action={row.action} className="h-4 w-4" />
            </span>
            <div className="min-w-0">
              <p className="truncate text-label">
                {row.targetCode ? `${nhanHanhDong} ${row.targetCode}` : nhanHanhDong}
              </p>
              <p className="mt-text truncate text-caption-sm text-text-secondary">
                {row.adminName} · {formatDate(row.createdAt)} · {formatTime(row.createdAt)}
              </p>
            </div>
          </div>
        );
      })}
    </SectionCard>
  );
}
