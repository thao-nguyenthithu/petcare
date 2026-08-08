import { useTranslation } from 'react-i18next';
import { cn } from '@/lib/utils';

export function KhongCoDuLieu({ className }: { className?: string }) {
  const { t } = useTranslation();
  return (
    <span className={cn('text-caption-sm text-text-secondary', className)}>
      {t('chung.khongCoDuLieu')}
    </span>
  );
}
