import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import * as Popover from '@radix-ui/react-popover';
import { Check, ChevronDown } from 'lucide-react';
import { cn } from '@/lib/utils';

export type FilterOption<T extends string> = { value: T; label: string };

type FilterSelectProps<T extends string> = {
  placeholder: string;
  options: Array<FilterOption<T>>;
  value: T | null;
  onChange: (value: T | null) => void;
  clearLabel: string;
  disabled?: boolean;
  className?: string;
};

export function FilterSelect<T extends string>({
  placeholder,
  options,
  value,
  onChange,
  clearLabel,
  disabled = false,
  className,
}: FilterSelectProps<T>) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const dangChon = options.find((option) => option.value === value);

  const chon = (next: T | null) => {
    onChange(next);
    setOpen(false);
  };

  return (
    <Popover.Root open={open} onOpenChange={setOpen}>
      <Popover.Trigger asChild>
        <button
          type="button"
          disabled={disabled}
          className={cn(
            'flex h-[42px] items-center gap-label rounded-card border px-stack text-label transition-colors',
            dangChon
              ? 'border-primary bg-card-mint text-primary'
              : 'border-neutral bg-surface text-text-primary hover:bg-card-mint',
            disabled && 'cursor-not-allowed opacity-50 hover:bg-surface',
            className,
          )}
        >
          {dangChon?.label ?? placeholder}
          <ChevronDown className="h-4 w-4 text-text-secondary" strokeWidth={1.8} />
        </button>
      </Popover.Trigger>

      <Popover.Portal>
        <Popover.Content
          align="start"
          sideOffset={6}
          className="z-50 min-w-[200px] rounded-card border border-neutral-light bg-surface p-label shadow-pop focus:outline-none"
        >
          <button
            type="button"
            onClick={() => chon(null)}
            className="flex w-full items-center justify-between gap-item rounded-card px-item py-label text-label text-text-secondary hover:bg-card-mint"
          >
            {clearLabel}
            {value === null ? <Check className="h-4 w-4 text-primary" strokeWidth={2} /> : null}
          </button>
          {options.length === 0 ? (
            <p className="px-item py-label text-caption-sm text-text-secondary">
              {t('chung.chuaCoDuLieu')}
            </p>
          ) : null}
          {options.map((option) => (
            <button
              key={option.value}
              type="button"
              onClick={() => chon(option.value)}
              className="flex w-full items-center justify-between gap-item rounded-card px-item py-label text-label hover:bg-card-mint"
            >
              {option.label}
              {option.value === value ? (
                <Check className="h-4 w-4 text-primary" strokeWidth={2} />
              ) : null}
            </button>
          ))}
        </Popover.Content>
      </Popover.Portal>
    </Popover.Root>
  );
}
