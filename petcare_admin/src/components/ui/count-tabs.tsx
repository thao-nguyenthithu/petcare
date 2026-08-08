import { cn } from '@/lib/utils';

export type CountTab<T extends string> = {
  key: T;
  label: string;
  count?: number;
};

type CountTabsProps<T extends string> = {
  tabs: Array<CountTab<T>>;
  value: T;
  onChange: (key: T) => void;
  className?: string;
};

export function CountTabs<T extends string>({
  tabs,
  value,
  onChange,
  className,
}: CountTabsProps<T>) {
  return (
    <div className={cn('flex items-center gap-label', className)}>
      {tabs.map((tab) => {
        const dangChon = tab.key === value;
        return (
          <button
            key={tab.key}
            type="button"
            onClick={() => onChange(tab.key)}
            className={cn(
              'flex items-center gap-label rounded-card px-stack py-label text-label transition-colors',
              dangChon
                ? 'bg-surface font-bold text-primary shadow-card'
                : 'text-text-secondary hover:text-text-primary',
            )}
          >
            {tab.label}
            {tab.count !== undefined ? (
              <span
                className={cn(
                  'rounded-card px-label py-[1px] text-label-sm',
                  dangChon ? 'bg-card-mint text-primary' : 'bg-neutral-light text-text-secondary',
                )}
              >
                {new Intl.NumberFormat('vi-VN').format(tab.count)}
              </span>
            ) : null}
          </button>
        );
      })}
    </div>
  );
}
