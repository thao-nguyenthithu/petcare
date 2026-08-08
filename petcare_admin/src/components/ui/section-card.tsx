import type { ReactNode } from 'react';
import { cn } from '@/lib/utils';

type SectionCardProps = {
  title: string;
  subtitle?: string;
  action?: ReactNode;
  children: ReactNode;
  className?: string;
  bodyClassName?: string;
};

export function SectionCard({
  title,
  subtitle,
  action,
  children,
  className,
  bodyClassName,
}: SectionCardProps) {
  return (
    <section
      className={cn('flex flex-col rounded-card border border-neutral-light bg-surface', className)}
    >
      <div className="flex items-start justify-between gap-item px-block pb-stack pt-block">
        <div className="min-w-0">
          <h2 className="truncate text-h3">{title}</h2>
          {subtitle ? (
            <p className="mt-text truncate text-caption-sm text-text-secondary">{subtitle}</p>
          ) : null}
        </div>
        {action ? <div className="shrink-0">{action}</div> : null}
      </div>
      <div className={cn('flex-1 px-block pb-block', bodyClassName)}>{children}</div>
    </section>
  );
}
