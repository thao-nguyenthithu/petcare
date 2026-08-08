import type { LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

type StatCardProps = {
  label: string;
  value: string;
  icon?: LucideIcon;
  hint?: string;
  delta?: number;
  tone?: 'default' | 'accent';
  className?: string;
};

export function StatCard({
  label,
  value,
  icon: Icon,
  hint,
  delta,
  tone = 'default',
  className,
}: StatCardProps) {
  const coDauCard = Icon || delta !== undefined;

  return (
    <div className={cn('rounded-card border border-neutral-light bg-surface p-block', className)}>
      {coDauCard ? (
        <div className="mb-stack flex items-start justify-between gap-item">
          {Icon ? (
            <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-card bg-card-mint">
              <Icon className="h-5 w-5 text-primary" strokeWidth={1.8} />
            </span>
          ) : null}
          {delta !== undefined ? (
            <span className={cn('text-label-sm', delta < 0 ? 'text-error' : 'text-primary')}>
              {delta > 0 ? '+' : ''}
              {new Intl.NumberFormat('vi-VN', { maximumFractionDigits: 1 }).format(delta)}%
            </span>
          ) : null}
        </div>
      ) : null}

      <p className="text-label-sm uppercase text-text-secondary">{label}</p>
      <p
        className={cn(
          'mt-text break-words text-[32px] font-bold leading-[40px]',
          tone === 'accent' ? 'text-accent' : 'text-text-primary',
        )}
      >
        {value}
      </p>
      {hint ? <p className="mt-label text-caption-sm text-text-secondary">{hint}</p> : null}
    </div>
  );
}

export function StatCardSkeleton({ className }: { className?: string }) {
  return (
    <div className={cn('rounded-card border border-neutral-light bg-surface p-block', className)}>
      <div className="mb-stack flex items-start justify-between gap-item">
        <div className="h-10 w-10 animate-pulse rounded-card bg-neutral-light" />
        <div className="h-4 w-12 animate-pulse rounded bg-neutral-light" />
      </div>
      <div className="h-4 w-32 animate-pulse rounded bg-neutral-light" />
      <div className="mt-text h-10 w-28 animate-pulse rounded bg-neutral-light" />
      <div className="mt-label h-4 w-24 animate-pulse rounded bg-neutral-light" />
    </div>
  );
}
