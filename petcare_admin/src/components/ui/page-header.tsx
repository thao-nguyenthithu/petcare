import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { ChevronLeft } from 'lucide-react';
import { cn } from '@/lib/utils';

export type Crumb = { label: string; to?: string };

type PageHeaderProps = {
  // Đường dẫn dạng Cụm / Mã
  crumbs: Crumb[];
  backTo: string;
  actions?: ReactNode;
  className?: string;
};

export function PageHeader({ crumbs, backTo, actions, className }: PageHeaderProps) {
  const { t } = useTranslation();

  return (
    <div className={cn('flex items-center justify-between gap-item', className)}>
      <div className="flex min-w-0 items-center gap-item">
        <Link
          to={backTo}
          aria-label={t('chung.quayLai')}
          className="flex h-9 w-9 shrink-0 items-center justify-center rounded-card border border-neutral bg-surface text-text-secondary hover:bg-card-mint"
        >
          <ChevronLeft className="h-4 w-4" strokeWidth={1.8} />
        </Link>
        <nav className="flex min-w-0 items-center gap-label text-label">
          {crumbs.map((crumb, index) => (
            <span key={crumb.label} className="flex min-w-0 items-center gap-label">
              {index > 0 ? <span className="text-text-secondary">/</span> : null}
              {crumb.to ? (
                <Link to={crumb.to} className="truncate text-text-secondary hover:text-primary">
                  {crumb.label}
                </Link>
              ) : (
                <span className="truncate">{crumb.label}</span>
              )}
            </span>
          ))}
        </nav>
      </div>
      {actions ? <div className="flex shrink-0 items-center gap-item">{actions}</div> : null}
    </div>
  );
}
