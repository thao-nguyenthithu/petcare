import { Minus } from 'lucide-react';
import { formatMoney } from '@/lib/format';
import { cn } from '@/lib/utils';

export function MoneyPill({ value, className }: { value: number; className?: string }) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-label rounded-card bg-neutral-light px-item py-[5px] text-label',
        className,
      )}
    >
      <Minus className="h-3 w-3 shrink-0 text-text-secondary" strokeWidth={2} />
      {formatMoney(value)}
    </span>
  );
}
