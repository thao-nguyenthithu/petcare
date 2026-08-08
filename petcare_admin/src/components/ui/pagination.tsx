import { useTranslation } from 'react-i18next';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { cn } from '@/lib/utils';

type PaginationProps = {
  page: number;
  pageSize: number;
  total: number;
  onPageChange: (page: number) => void;
  className?: string;
};

function buildPages(current: number, totalPages: number): Array<number | 'gap'> {
  if (totalPages <= 7) return Array.from({ length: totalPages }, (_, i) => i + 1);
  const pages: Array<number | 'gap'> = [1];
  const from = Math.max(2, current - 1);
  const to = Math.min(totalPages - 1, current + 1);
  if (from > 2) pages.push('gap');
  for (let i = from; i <= to; i += 1) pages.push(i);
  if (to < totalPages - 1) pages.push('gap');
  pages.push(totalPages);
  return pages;
}

export function Pagination({ page, pageSize, total, onPageChange, className }: PaginationProps) {
  const { t } = useTranslation();
  const totalPages = Math.max(1, Math.ceil(total / pageSize));
  const from = total === 0 ? 0 : (page - 1) * pageSize + 1;
  const to = Math.min(page * pageSize, total);

  return (
    <div className={cn('flex items-center justify-between gap-item', className)}>
      <p className="text-caption-sm text-text-secondary">
        {t('chung.phanTrang', { from, to, total })}
      </p>
      <div className="flex items-center gap-text">
        <button
          type="button"
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
          aria-label={t('chung.trangTruoc')}
          className="flex h-9 w-9 items-center justify-center rounded-card border border-neutral text-text-secondary hover:bg-card-mint disabled:opacity-40 disabled:hover:bg-transparent"
        >
          <ChevronLeft className="h-4 w-4" strokeWidth={1.8} />
        </button>
        {buildPages(page, totalPages).map((item, index) =>
          item === 'gap' ? (
            <span key={`gap-${index}`} className="px-text text-text-secondary">
              ...
            </span>
          ) : (
            <button
              key={item}
              type="button"
              onClick={() => onPageChange(item)}
              className={cn(
                'h-9 min-w-9 rounded-card px-text text-label',
                item === page
                  ? 'bg-primary text-text-white'
                  : 'border border-neutral text-text-primary hover:bg-card-mint',
              )}
            >
              {item}
            </button>
          ),
        )}
        <button
          type="button"
          onClick={() => onPageChange(page + 1)}
          disabled={page >= totalPages}
          aria-label={t('chung.trangSau')}
          className="flex h-9 w-9 items-center justify-center rounded-card border border-neutral text-text-secondary hover:bg-card-mint disabled:opacity-40 disabled:hover:bg-transparent"
        >
          <ChevronRight className="h-4 w-4" strokeWidth={1.8} />
        </button>
      </div>
    </div>
  );
}
