import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import * as Popover from '@radix-ui/react-popover';
import { Check, ChevronDown } from 'lucide-react';
import { khoaChuoi, nhanGiaTriChon, nhanNguoiDoi } from '@/features/settings/param-labels';
import type { OperatingSetting } from '@/features/settings/types';

export function ParamChoiceRow({
  item,
  disabled,
  onChon,
}: {
  item: OperatingSetting;
  disabled: boolean;
  onChon: (giaTri: string) => void;
}) {
  const { t } = useTranslation();
  const [moDanhSach, setMoDanhSach] = useState(false);

  const dsChon = item.luaChon ?? [];
  const dangChon = typeof item.giaTri === 'string' ? item.giaTri : '';
  const rieng = t(`caiDat.luaChon.rieng.${khoaChuoi(item.key)}`, { defaultValue: '' });

  const chon = (giaTri: string) => {
    setMoDanhSach(false);
    if (giaTri !== dangChon) onChon(giaTri);
  };

  return (
    <div className="flex items-start justify-between gap-item border-b border-neutral-light py-item first:pt-0">
      <div className="min-w-0">
        <p className="truncate text-label">{item.nhan}</p>
        <p className="mt-text truncate text-caption-sm text-text-secondary">
          {t('caiDat.luaChon.goiY', { macDinh: nhanGiaTriChon(t, String(item.macDinh)) })}
        </p>
        {rieng ? <p className="mt-text text-caption-sm text-text-secondary">{rieng}</p> : null}
        <p className="mt-text truncate text-caption-sm text-text-secondary">
          {nhanNguoiDoi(t, item)}
        </p>
      </div>

      <Popover.Root open={moDanhSach} onOpenChange={setMoDanhSach}>
        <Popover.Trigger asChild>
          <button
            type="button"
            aria-label={item.nhan}
            disabled={disabled || dsChon.length === 0}
            className="flex h-[42px] w-[168px] shrink-0 items-center justify-between gap-label rounded-card border border-neutral bg-surface px-item text-label text-text-primary transition-colors hover:bg-card-mint disabled:cursor-not-allowed disabled:opacity-50 disabled:hover:bg-surface"
          >
            <span className="min-w-0 truncate">
              {dangChon ? nhanGiaTriChon(t, dangChon) : t('chung.chuaCoDuLieu')}
            </span>
            <ChevronDown className="h-4 w-4 shrink-0 text-text-secondary" strokeWidth={1.8} />
          </button>
        </Popover.Trigger>

        <Popover.Portal>
          <Popover.Content
            align="end"
            sideOffset={6}
            className="z-50 min-w-[168px] rounded-card border border-neutral-light bg-surface p-label shadow-pop focus:outline-none"
          >
            {dsChon.map((giaTri) => (
              <button
                key={giaTri}
                type="button"
                onClick={() => chon(giaTri)}
                className="flex w-full items-center justify-between gap-item rounded-card px-item py-label text-label hover:bg-card-mint"
              >
                {nhanGiaTriChon(t, giaTri)}
                {giaTri === dangChon ? (
                  <Check className="h-4 w-4 text-primary" strokeWidth={2} />
                ) : null}
              </button>
            ))}
          </Popover.Content>
        </Popover.Portal>
      </Popover.Root>
    </div>
  );
}
