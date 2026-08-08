import type { ReactNode } from 'react';
import { KhongCoDuLieu } from '@/components/ui/empty-value';
import { cn } from '@/lib/utils';

type DongThongTinProps = {
  label: string;
  value?: ReactNode;
  className?: string;
  valueClassName?: string;
};

export function DongThongTin({
  label,
  value,
  className,
  valueClassName,
}: DongThongTinProps) {
  const trong = value === null || value === undefined || value === '';
  return (
    <li className={cn('flex items-baseline justify-between gap-item', className)}>
      <span className="shrink-0 text-label font-normal text-text-secondary">{label}</span>
      {trong ? (
        <KhongCoDuLieu />
      ) : (
        <span className={cn('min-w-0 break-words text-right text-label', valueClassName)}>
          {value}
        </span>
      )}
    </li>
  );
}
