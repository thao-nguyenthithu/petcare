import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { buttonVariants } from '@/components/ui/button-variants';
import { PATHS } from '@/routes/paths';

export function NotFoundPage() {
  const { t } = useTranslation();
  return (
    <div className="flex h-full flex-col items-center justify-center gap-item bg-canvas text-center">
      <p className="text-h2">{t('chung.khongTimThayTrang')}</p>
      <p className="text-body text-text-secondary">{t('chung.duongDanKhongTonTai')}</p>
      <Link to={PATHS.dashboard} className={buttonVariants({ variant: 'secondary', size: 'sm' })}>
        {t('chung.veTrangTongQuan')}
      </Link>
    </div>
  );
}
