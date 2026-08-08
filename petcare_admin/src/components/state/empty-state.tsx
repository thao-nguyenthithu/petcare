import { useTranslation } from 'react-i18next';
import { Inbox, SearchX, type LucideIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';

type EmptyStateProps = {
  variant?: 'no-data' | 'no-match';
  message: string;
  icon?: LucideIcon;
  actionLabel?: string;
  onAction?: () => void;
};

export function EmptyState({
  variant = 'no-data',
  message,
  icon,
  actionLabel,
  onAction,
}: EmptyStateProps) {
  const { t } = useTranslation();
  const Icon = icon ?? (variant === 'no-match' ? SearchX : Inbox);
  const label = actionLabel ?? (variant === 'no-match' ? t('chung.xoaBoLoc') : undefined);

  return (
    <div className="flex flex-col items-center justify-center gap-item px-card py-edge text-center">
      <Icon className="h-10 w-10 text-neutral" strokeWidth={1.6} />
      <p className="max-w-96 text-body text-text-secondary">{message}</p>
      {label && onAction ? (
        <Button variant="secondary" size="sm" onClick={onAction}>
          {label}
        </Button>
      ) : null}
    </div>
  );
}
