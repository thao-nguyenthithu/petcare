import { useTranslation } from 'react-i18next';
import { AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';

type ErrorStateProps = {
  message?: string;
  onRetry?: () => void;
};

export function ErrorState({ message, onRetry }: ErrorStateProps) {
  const { t } = useTranslation();
  return (
    <div className="flex flex-col items-center justify-center gap-item px-card py-edge text-center">
      <AlertCircle className="h-10 w-10 text-error" strokeWidth={1.6} />
      <p className="max-w-96 text-body text-text-secondary">
        {message ?? t('chung.khongTaiDuocDuLieu')}
      </p>
      {onRetry ? (
        <Button variant="secondary" size="sm" onClick={onRetry}>
          {t('chung.thuLai')}
        </Button>
      ) : null}
    </div>
  );
}
