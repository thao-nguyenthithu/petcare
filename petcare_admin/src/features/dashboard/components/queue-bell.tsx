import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import * as Popover from '@radix-ui/react-popover';
import { Bell } from 'lucide-react';
import { QueueList } from '@/features/dashboard/components/queue-list';
import { useQueue } from '@/features/dashboard/hooks/use-dashboard';
import { Skeleton } from '@/components/state/skeleton';
import { ErrorState } from '@/components/state/error-state';
import { PATHS } from '@/routes/paths';

export function QueueBell() {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const { data, isPending, isError, refetch } = useQueue();
  const tong = data?.total ?? 0;

  return (
    <Popover.Root open={open} onOpenChange={setOpen}>
      <Popover.Trigger asChild>
        <button
          type="button"
          aria-label={t('chung.vieccanLam')}
          className="relative flex h-[42px] w-[42px] items-center justify-center rounded-card border border-neutral text-text-secondary hover:bg-card-mint"
        >
          <Bell className="h-[18px] w-[18px]" strokeWidth={1.8} />
          {tong > 0 ? (
            <span className="absolute -right-[6px] -top-[6px] flex h-5 min-w-5 items-center justify-center rounded-full bg-error px-[5px] text-caption-sm text-text-white">
              {tong > 99 ? '99+' : tong}
            </span>
          ) : null}
        </button>
      </Popover.Trigger>

      <Popover.Portal>
        <Popover.Content
          align="end"
          sideOffset={8}
          className="z-50 w-[380px] rounded-card border border-neutral-light bg-surface shadow-pop focus:outline-none"
        >
          <div className="flex items-center justify-between gap-item border-b border-neutral-light px-block py-stack">
            <h3 className="text-label">{t('queue.tieuDe')}</h3>
            <span className="text-caption-sm text-text-secondary">
              {t('queue.demViec', { count: tong })}
            </span>
          </div>

          <div className="px-block">
            {isPending ? (
              <div className="flex flex-col gap-item py-block">
                {Array.from({ length: 5 }).map((_, index) => (
                  <Skeleton key={index} className="h-[33px] w-full" />
                ))}
              </div>
            ) : isError ? (
              <ErrorState onRetry={() => void refetch()} />
            ) : (
              <QueueList items={data.items} onNavigate={() => setOpen(false)} />
            )}
          </div>

          <div className="border-t border-neutral-light px-block py-stack text-center">
            <Link
              to={PATHS.dashboard}
              onClick={() => setOpen(false)}
              className="text-label text-primary hover:underline"
            >
              {t('queue.moTrangTongQuan')}
            </Link>
          </div>
        </Popover.Content>
      </Popover.Portal>
    </Popover.Root>
  );
}
