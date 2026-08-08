import { useTranslation } from 'react-i18next';
import { Link, useNavigate } from 'react-router-dom';
import { ArrowUpRight, Info } from 'lucide-react';
import { EmptyState } from '@/components/state/empty-state';
import { ErrorState } from '@/components/state/error-state';
import { Skeleton } from '@/components/state/skeleton';
import { SettingsTabs, type SettingsTabKey } from '@/features/settings/components/settings-tabs';
import { useLimitGroups } from '@/features/settings/hooks/use-settings';
import type { LimitGroup } from '@/features/settings/types';
import { PATHS } from '@/routes/paths';
import { cn } from '@/lib/utils';

export function LimitsScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const nhom = useLimitGroups();

  const doiTab = (key: SettingsTabKey) => {
    void navigate(key === 'nhatKy' ? `${PATHS.settings}?tab=nhat-ky` : PATHS.settings);
  };

  const groups = nhom.data ?? [];
  const trai = groups.filter((item) => item.cot === 'trai');
  const phai = groups.filter((item) => item.cot === 'phai');

  return (
    <div className="flex flex-col gap-stack pb-block">
      <SettingsTabs value="gioiHan" onChange={doiTab} />

      <p className="flex items-start gap-item rounded-card bg-honey/15 p-card text-caption-sm text-honey">
        <Info className="mt-[1px] h-4 w-4 shrink-0" strokeWidth={1.8} />
        {t('gioiHan.ghiChuChiDeTra')}
      </p>

      {nhom.isError ? (
        <div className="rounded-card border border-neutral-light bg-surface">
          <ErrorState onRetry={() => void nhom.refetch()} />
        </div>
      ) : null}

      {nhom.isPending ? (
        <div className="grid grid-cols-2 gap-group">
          {Array.from({ length: 4 }).map((_, index) => (
            <Skeleton key={index} className="h-[420px] rounded-card" />
          ))}
        </div>
      ) : null}

      {!nhom.isPending && !nhom.isError && groups.length === 0 ? (
        <div className="rounded-card border border-neutral-light bg-surface">
          <EmptyState message={t('chung.chuaCoDuLieu')} />
        </div>
      ) : null}

      <div className="grid grid-cols-2 items-start gap-group">
        <div className="flex flex-col gap-group">
          {trai.map((group) => (
            <NhomCard key={group.key} group={group} />
          ))}
        </div>
        <div className="flex flex-col gap-group">
          {phai.map((group) => (
            <NhomCard key={group.key} group={group} />
          ))}
        </div>
      </div>
    </div>
  );
}

function NhomCard({ group }: { group: LimitGroup }) {
  const { t } = useTranslation();
  return (
    <section
      className={cn(
        'flex flex-col rounded-card border bg-surface',
        group.chuaCoTrongCode ? 'border-honey/40 bg-honey/[0.06]' : 'border-neutral-light',
      )}
    >
      <div className="flex items-start justify-between gap-item px-block pb-stack pt-block">
        <div className="min-w-0">
          <h2 className="truncate text-h3">{group.title}</h2>
          <p className="mt-text text-caption-sm text-text-secondary">{group.source}</p>
        </div>
        {group.coDongDaChuyen ? (
          <Link
            to={PATHS.settings}
            className="flex h-[30px] shrink-0 items-center gap-label rounded-card border border-neutral-light bg-surface px-label text-label-sm text-text-secondary hover:bg-card-mint hover:text-primary"
          >
            {t('gioiHan.xemThamSoSuaDuoc')}
            <ArrowUpRight className="h-[14px] w-[14px]" strokeWidth={1.8} />
          </Link>
        ) : null}
      </div>

      <div className="flex flex-col px-block pb-block">
        {group.items.map((item, index) => (
          <div
            key={item.label}
            className={cn(
              'flex items-center justify-between gap-item py-item',
              index > 0 && 'border-t border-neutral-light',
            )}
          >
            <div className="min-w-0">
              <p className="truncate text-label">{item.label}</p>
              <p className="mt-text truncate text-caption-sm text-text-secondary">{item.desc}</p>
            </div>
            <div className="flex min-h-[38px] w-[152px] shrink-0 items-center justify-between gap-label rounded-card border border-neutral-light bg-canvas px-item py-label">
              <span className="min-w-0 text-label">{item.value}</span>
              {item.unit ? (
                <span className="shrink-0 text-caption-sm text-text-secondary">{item.unit}</span>
              ) : null}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
