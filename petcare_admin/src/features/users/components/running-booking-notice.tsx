import { useTranslation } from 'react-i18next';
import { AlertTriangle, Loader2 } from 'lucide-react';

type RunningBookingNoticeProps = {
  isPending: boolean;
  isError: boolean;
  count: number | undefined;
};

export function RunningBookingNotice({
  isPending,
  isError,
  count,
}: RunningBookingNoticeProps) {
  const { t } = useTranslation();

  if (isPending) {
    return (
      <p className="mb-item flex items-center gap-text rounded-card bg-neutral-light/60 p-item text-caption-sm text-text-secondary">
        <Loader2 className="h-4 w-4 shrink-0 animate-spin" strokeWidth={1.8} />
        {t('nguoiDung.dialog.dangKiemDonDangChay')}
      </p>
    );
  }
  if (isError) {
    return (
      <p className="mb-item flex items-start gap-text rounded-card bg-honey/15 p-item text-caption-sm text-text-primary">
        <AlertTriangle className="mt-text h-4 w-4 shrink-0 text-honey" strokeWidth={1.8} />
        <span>{t('nguoiDung.dialog.khongKiemDuocDonDangChay')}</span>
      </p>
    );
  }
  if (!count) return null;

  return (
    <p className="mb-item flex items-start gap-text rounded-card bg-honey/15 p-item text-caption-sm text-text-primary">
      <AlertTriangle className="mt-text h-4 w-4 shrink-0 text-honey" strokeWidth={1.8} />
      <span>{t('nguoiDung.dialog.canhBaoDonDangChay', { count })}</span>
    </p>
  );
}
