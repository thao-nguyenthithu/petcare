import { Link } from 'react-router-dom';
import {
  AlertTriangle,
  ChevronRight,
  FileCheck,
  Gauge,
  Inbox,
  Wallet,
  type LucideIcon,
} from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { EmptyState } from '@/components/state/empty-state';
import type { QueueItem, QueueKey } from '@/features/dashboard/types';
import { cn } from '@/lib/utils';
import { PATHS } from '@/routes/paths';

const ICON: Record<QueueKey, LucideIcon> = {
  sitterPending: FileCheck,
  disputeReview: AlertTriangle,
  withdrawalPending: Wallet,
  penaltyReview: Gauge,
};

// Đường dẫn màn đích thuộc về web quản trị
const DUONG_DAN: Record<QueueKey, string> = {
  sitterPending: PATHS.sitterApprovals,
  disputeReview: PATHS.disputes,
  withdrawalPending: PATHS.finance,
  penaltyReview: PATHS.penalties,
};

type QueueListProps = {
  items: QueueItem[];
  onNavigate?: () => void;
};

export function QueueList({ items, onNavigate }: QueueListProps) {
  const { t } = useTranslation();

  if (items.length === 0) {
    return <EmptyState message={t('chung.chuaCoDuLieu')} />;
  }

  return (
    <ul className="flex flex-col">
      {items.map((item, index) => {
        const Icon = ICON[item.key] ?? Inbox;
        const duongDan = DUONG_DAN[item.key] as string | undefined;
        if (!duongDan) return null;
        const rong = item.count === 0;
        return (
          <li key={item.key} className={cn(index > 0 && 'border-t border-neutral-light')}>
            <Link
              to={duongDan}
              onClick={onNavigate}
              className={cn(
                'flex items-center gap-item py-item transition-colors hover:bg-card-mint/40',
                rong && 'opacity-50',
              )}
            >
              <span className="flex h-[33px] w-[33px] shrink-0 items-center justify-center rounded-card bg-card-mint">
                <Icon className="h-[17px] w-[17px] text-primary" strokeWidth={1.8} />
              </span>
              <div className="min-w-0 flex-1">
                <p className="truncate text-label">{item.label}</p>
                <p className="truncate text-caption-sm text-text-secondary">{item.hint}</p>
              </div>
              <span className="shrink-0 text-h3">{item.count}</span>
              <ChevronRight className="h-4 w-4 shrink-0 text-text-secondary" strokeWidth={1.8} />
            </Link>
          </li>
        );
      })}
    </ul>
  );
}
